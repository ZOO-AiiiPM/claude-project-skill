# {PROJECT_NAME}

{一句话项目描述}

> 本项目从 [claude-project-template](https://github.com/ZOO-AiiiPM/claude-project-template) 创建。

## 快速开始

1. 改占位符：`CLAUDE.md` / `journal.md` / `README.md` 里的 `{PROJECT_NAME}` 和描述
2. 建本地 settings：
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   ```
3. 打开 `.claude/settings.local.json`，把 `autoMemoryDirectory` 改成当前项目的**绝对路径**（例如 `/Users/you/projects/my-project/.claude/memory`）
4. 读 `CLAUDE.md` 了解跨 session 协作规则（journal/memory/rules 分工）

## 目录说明

- `CLAUDE.md` — 每次 session 自动加载的规则和索引
- `journal.md` — 倒序时间线日志（进度/反思/待办）
- `.claude/memory/` — 事实（服务器/账号/API/命令），Claude 自动维护
- `.claude/rules/` — 项目规则（长规则按主题拆）
- `lessons/` — 复杂案例叙事（跟项目走）
- `docs/` — 人读产品文档
- `workspace/` — 临时工作区（gitignore 子目录）

详见 `CLAUDE.md` 的"跨 Session 协作"段。

## 预置 hook：turn-reflect（默认启用）

`.claude/hooks/turn-reflect.sh` 在每轮对话后触发，两级提醒：

- **每 5 轮** — 判断本段要不要 append journal（有决策 / 踩坑 / 学到就写，否则跳过）
- **每 10 轮** — 额外回看最近活动，判断要不要蒸馏成 lesson / rules / CLAUDE.md 硬规则

不用 Claude 问、不用你操作，它自己判断自己写。10 轮时两级同时触发。

**配置**：`.claude/settings.local.json` 的 `hooks.Stop` 段。阈值在 `turn-reflect.sh` 顶部 `JOURNAL_EVERY` / `DISTILL_EVERY` 改。关闭整个 hook：删 settings 里的 `hooks` 段。
