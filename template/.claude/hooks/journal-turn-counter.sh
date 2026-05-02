#!/bin/bash
# 每 N 轮对话后提醒 Claude 考虑 append journal。
# 阈值在下方 THRESHOLD 改（默认 5）。
# 计数文件在 $CLAUDE_PROJECT_DIR/.claude/.turn-counter（已在 .gitignore）。

COUNTER_FILE="$CLAUDE_PROJECT_DIR/.claude/.turn-counter"
THRESHOLD=5

count=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

if [ "$count" -ge "$THRESHOLD" ]; then
  echo 0 > "$COUNTER_FILE"
  cat <<MSG
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "已过 ${THRESHOLD} 轮对话。请自行判断本段有没有值得记的进展/踩坑/学到？\n\n判断标准：\n- 有实质决策、不可逆操作、踩坑 → 追加到 journal.md 顶部（倒序），格式：## YYYY-MM-DD + 做了/坑了/学到\n- 只是澄清/讨论/列方案 → 跳过，不写\n\n要写直接 Edit journal.md，不用问我。判断不用写也不用通知我。"
  }
}
MSG
fi
