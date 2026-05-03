# Presets

预置的规则模板，`/project-setup init` 按项目类型选装到 `.claude/rules/`。

## 目前有哪些

- **`coding-general.md`** — 通用编码防坑（最小改动 / 假设显式化 / 可验证成功 / 实证 > 推测）

## 装 preset 还是指向全局 skill？

**两条路选一条**：

**路径 A（推荐本地用户）**：指向已有全局 skill

如果你机器上已装 `andrej-karpathy-skills:karpathy-guidelines` 或类似全局 skill，不需要装 preset —— 只要在项目 `CLAUDE.md` "关键资源索引"段加一行，让 Claude 知道写代码时去查它：

```markdown
- **写代码**：参考 karpathy-guidelines skill（防 LLM 常见编码错误）
```

全局 skill 的触发机制更精准、升级有版本，比本地拷贝好。

**路径 B（推荐开源用户）**：装 preset 到本项目

没有上述全局 skill（比如 clone 了本 skill 但没装 karpathy-guidelines），`init` 时选装 preset：

```bash
cp assets/presets/coding-general.md <project-root>/.claude/rules/
```

preset 自带 paths 作用域，写代码类文件时自动触发。

## 不做的事

- **不堆 preset**。目前只有 1 份通用编码的，其他类型（写作 / 研究 / 数据）按需加，不凭空造
- **preset 不是本项目规则**。preset 的位置本应是全局 rules，放这里是开源场景的 fallback。正式工作推荐走路径 A

## 添加新 preset

如果你觉得某类项目（比如数据管道、前端 UI）需要一份 preset，PR 欢迎。要求：
- 内容**通用**（不含任何公司 / 项目特定业务）
- 带 `paths:` 作用域（精准限定触发文件类型）
- 结构符合 `references/rules.md` 标准：命令式 + why + 示例
