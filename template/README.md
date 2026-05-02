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

## 预置 hook

`.claude/hooks/journal-turn-counter.sh` — 每 5 轮对话后提醒 Claude 考虑 append journal。通过 `settings.local.json` 的 `hooks.Stop` 启用；不想要时删 `hooks` 段即可。阈值在脚本顶部 `THRESHOLD` 改。
