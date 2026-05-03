#!/bin/bash
# 每轮对话（Stop 事件）后触发。两级提醒：
# - 每 JOURNAL_EVERY 轮（默认 5）：提醒 Claude 判断本段要不要 append journal
# - 每 DISTILL_EVERY 轮（默认 10）：额外提醒 Claude 回看最近，判断要不要蒸馏到 lesson / rules / CLAUDE.md
# 10 轮时两级同时触发。
#
# 阈值改下方变量。计数文件 $CLAUDE_PROJECT_DIR/.claude/.turn-counter（已 gitignore）。
# 不想要整个 hook：在 .claude/settings.local.json 里删 hooks 段。

COUNTER_FILE="$CLAUDE_PROJECT_DIR/.claude/.turn-counter"
JOURNAL_EVERY=5
DISTILL_EVERY=10

count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

hit_journal=0
hit_distill=0
[ $((count % JOURNAL_EVERY)) -eq 0 ] && hit_journal=1
[ $((count % DISTILL_EVERY)) -eq 0 ] && hit_distill=1

# 没到任何阈值 → 静默退出
if [ "$hit_journal" = 0 ] && [ "$hit_distill" = 0 ]; then
  exit 0
fi

msg=""

if [ "$hit_journal" = 1 ]; then
  msg="【第 ${count} 轮 — journal 提醒】\\n判断本段有没有值得记的进展 / 踩坑 / 学到：\\n- 有实质决策 / 不可逆操作 / 踩坑 → 追加到 journal.md 顶部（倒序），格式 '## YYYY-MM-DD 标题' + 做了 / 坑了 / 学到\\n- 只是澄清 / 讨论 / 列方案 → 跳过不写\\n\\n要写直接 Edit journal.md，不用问。跳过也不用通知。"
fi

if [ "$hit_distill" = 1 ]; then
  [ -n "$msg" ] && msg="${msg}\\n\\n"
  msg="${msg}【第 ${count} 轮 — 蒸馏提醒】\\n回看 journal 顶部 + 最近对话，判断要不要蒸馏：\\n- 反复出现的坑 / 重复关键词 → 抽成 lessons/{主题}.md（复杂反转带叙事）或 .claude/rules/{主题}.md（稳定命令式规则）\\n- 用户新给的硬规则 / 严重纠正 → 短的（1-3 行）append 到 CLAUDE.md 的'项目硬规则'段；长的 / 多条 → .claude/rules/{主题}.md\\n- 新写了 memory 文件却没更新 MEMORY.md 索引 → 补索引\\n\\n值得蒸馏就直接 Edit / Write 对应文件，写完简单汇报一行。不需要蒸馏就跳过不提。"
fi

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "$msg"
  }
}
EOF
