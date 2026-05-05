#!/bin/bash
# 每轮对话（Stop 事件）后触发。三级提醒：
# - 每 JOURNAL_EVERY 轮（默认 5）：提醒 Claude 判断要不要 append journal
# - 每 DISTILL_EVERY 轮（默认 10）：提醒 Claude 判断要不要蒸馏到 lesson / rules
# - 每 REVIEW_EVERY 轮（默认 30）：提醒 Claude 做规则层 review（去重 / 合并 / 升级 / archive）
# 30 轮时三级同时触发。
#
# 阈值改下方变量。计数文件 $CLAUDE_PROJECT_DIR/.claude/.turn-counter（已 gitignore）。
# 完全关闭：.claude/settings.local.json 里删 hooks 段。
# 只想关其中一级：把对应阈值设成一个永远不会 % 命中的大值（比如 999999）。

COUNTER_FILE="$CLAUDE_PROJECT_DIR/.claude/.turn-counter"
JOURNAL_EVERY=5
DISTILL_EVERY=10
REVIEW_EVERY=30

count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

hit_journal=0
hit_distill=0
hit_review=0
[ $((count % JOURNAL_EVERY)) -eq 0 ] && hit_journal=1
[ $((count % DISTILL_EVERY)) -eq 0 ] && hit_distill=1
[ $((count % REVIEW_EVERY)) -eq 0 ] && hit_review=1

# 没到任何阈值 → 静默退出
if [ "$hit_journal" = 0 ] && [ "$hit_distill" = 0 ] && [ "$hit_review" = 0 ]; then
  exit 0
fi

msg=""

# ───────────── 第一级：journal 提醒 ─────────────
if [ "$hit_journal" = 1 ]; then
  msg="【第 ${count} 轮 — journal 提醒】\\n判断本段有没有值得记的进展 / 踩坑 / 学到：\\n- 有实质决策 / 不可逆操作 / 踩坑 → 追加到 journal.md 顶部（倒序），格式 '## YYYY-MM-DD 标题' + 做了 / 坑了 / 学到，可选 + 决策\\n- 只是澄清 / 讨论 / 列方案 → 跳过不写\\n\\n要写直接 Edit journal.md，不用问。跳过也不用通知。"
fi

# ───────────── 第二级：蒸馏提醒（带写作标准） ─────────────
if [ "$hit_distill" = 1 ]; then
  [ -n "$msg" ] && msg="${msg}\\n\\n"
  msg="${msg}【第 ${count} 轮 — 蒸馏提醒】\\n回看 journal 顶部 + 最近对话，判断要不要蒸馏。**蒸馏链：journal 一句话'坑了' → 重复 2+ 次或单次反转复杂 → lesson 叙事 → 规律稳定 → rules/ 命令式 → 跨项目有效 → ~/.claude/rules/ 全局**。\\n\\n触发信号与动作：\\n- journal 最近 7-14 天'坑了'出现重复关键词 → 升 lesson 或 rule\\n- 单次踩坑但有反转（方案 A→B→C 才成）或反直觉结论 → 升 lesson\\n- 用户明确纠正规则 2+ 次 → 抽 rule（短的 1-3 行进 CLAUDE.md 项目硬规则段，长的进 .claude/rules/{主题}.md）\\n- 写了 memory 主题文件但 MEMORY.md 没更新索引 → 立刻补，否则 Claude 永远命中不到\\n\\n**lesson 写作标准**（在 lessons/{主题}.md）：\\n- 结构：起点问题 → 走过的弯路（坑 1/2/3，现象 + 根因 + 教训）→ 最终方案 → **可复用规则段（必须，命令式 + why）** → 可选'用户的自我观察'\\n- 长度 100-300 行 / 3-8 KB。太短降回 journal 就够；太长该拆多份\\n- 命名 kebab-case 主题，文件名 5 秒能看懂主题\\n\\n**rule 写作标准**（在 .claude/rules/{主题}.md）：\\n- frontmatter 的 paths 精准限定（改 migration 时触发就写 migrations/**/*.sql），全局规则无 paths 要有合理性\\n- 命令式（禁止 X / 必须 Y / X 时做 Z），不用柔化词（尽量 / 可能 / 建议）\\n- 每条规则必须带 why（机制解释），有示例最好\\n- 关闭错误路径（'搜索永远拿不到 X'）比指向正确路径（'该调 Y 接口'）更有力\\n- 禁用 feedback_*.md 命名\\n\\n值得蒸馏就直接 Edit / Write 文件，完成后简单汇报一行。不需要蒸馏就跳过不提。"
fi

# ───────────── 第三级：规则 review（去重 / 合并 / 升级 / archive） ─────────────
if [ "$hit_review" = 1 ]; then
  [ -n "$msg" ] && msg="${msg}\\n\\n"
  msg="${msg}【第 ${count} 轮 — 规则 review 提醒】\\n做一次**规则层**质量审查（不是全项目 audit，只扫 CLAUDE.md + .claude/rules/）。目的：让规则集随项目演化而不是只增不减。\\n\\n扫这几类问题：\\n1. **重复规则**：CLAUDE.md 和 rules/ 里有没有同意思的规则（措辞不同但语义重合）→ 合并或删一处\\n2. **冲突规则**：两处规则说的不一致（A 处说'必须 X'，B 处说'X 可选'）→ 必须协调，模型遇冲突会随机跳到训练先验\\n3. **可合并的规则**：rules/ 下多份文件各写一条同主题规则 → 合并到一份（按主题聚合 > 按来源分散）\\n4. **CLAUDE.md 里的长规则**：超过 3 行、内容专门 → 迁到 .claude/rules/{主题}.md，CLAUDE.md 留一行索引\\n5. **rules/ 里的短规则**：只有 1-2 行、通用性强 → 上升到 CLAUDE.md 项目硬规则段\\n6. **可升级到全局的规则**：某条规则在本项目稳定有效且**明显跨项目都适用**（不是项目特有业务）→ 建议迁 ~/.claude/rules/{主题}.md\\n7. **过期规则**：讲述的场景已完全不存在（技术栈换了 / API 废弃）→ 建议 archive（不要直接删，保留历史）\\n8. **柔化词规则**：含'尽量 / 可能 / 建议 / 大概率' → 改命令式或删\\n\\n输出格式：简短的建议清单，每条带原文引用（文件路径 + 行号），让用户决定改不改。不要直接动文件 —— review 是诊断，改走 /project-setup apply 或用户手动。\\n\\n没发现问题就汇报一句'规则层本轮 review 未发现问题'即可，不用硬凑。"
fi

cat <<EOF
{
  "decision": "block",
  "reason": "$msg"
}
EOF
