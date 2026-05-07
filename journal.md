# Journal — claude-project-skill

> 最新条目在顶部（**倒序**，session 开头 Claude 读前几条就知道最近状态）。
> 格式：`## YYYY-MM-DD 标题` + 做了 / 坑了 / 学到，可选 + 决策。
> **真实 > 完整**：没实质进展的日子空着比凑数好。
>
> 审视时机：每周回看上周条目的"坑了"字段，找**重复出现的词** —— 那就是该蒸馏成 rule 或 lesson 的模式。
>
> 写法标准与示例：skill 的 `references/journal.md`。

## 2026-05-07 项目协作层初始化

- **做了**：为 claude-project-skill 本身加 CLAUDE.md + .claude/ 协作骨架（用自己的 init 流程 init 自己）；确认 GitHub 与本地同步（最新 commit：`be31c66 fix(assets): 删除 4 处占位示例`）
- **坑了**：-
- **学到**：-
- **决策**：跳过 `cp assets/. .` 步骤，手动创建各协作文件 | 因为 target_path 就是 skill 本身，cp 会导致 assets/ 递归嵌套 | 替代方案是保留 cp 但加 exclude assets 参数（未采用，手动更精确）
