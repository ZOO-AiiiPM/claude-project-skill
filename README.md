# Never Re-explain Your Project to Claude

> A [Claude Code](https://docs.claude.com/en/docs/claude-code) skill that keeps your project context alive across sessions — auto-syncing state, evolving rules, and distilling every lesson learned.

Every project hits the same wall after a few weeks: Claude forgets what you did last session, rules bloat into noise, and hard-won lessons live nowhere reusable. This skill fixes that with 8 spec documents, 4 commands, and 2 built-in hooks.

---

每个项目跑起来几周后必然撞上同一堵墙：新 session 像白纸、规则越写越长失去效力、踩过的坑下次还踩。本 skill 用 8 份规范 + 4 个子命令 + 2 个预置 hook 解决这三类痛点：**跨 session 状态自动同步、规则集随项目演化自我维护、踩坑经 journal → lesson → rules 蒸馏链成为可复用资产**。

---

## Install / 安装

**Personal skill** — available across all your projects:

```bash
git clone https://github.com/ZOO-AiiiPM/claude-project-skill.git \
  ~/.claude/skills/project-setup
```

**Project skill** — scoped to current project only:

```bash
git clone https://github.com/ZOO-AiiiPM/claude-project-skill.git \
  .claude/skills/project-setup
```

Restart your Claude Code session after installing.

---

## Commands / 子命令

| Command | What it does |
|---------|-------------|
| `/project-setup init <name> <desc> <path>` | 对话式起新项目，生成协作骨架 + 事实层 |
| `/project-setup audit [path]` | 按 8 维标准深度审查，出带原文引用的诊断报告（只读）|
| `/project-setup apply [path]` | 按 audit / review 报告逐条改造（每条需授权）|
| `/project-setup review [path]` | 规则层质量审查：去重 / 合并 / 升级 / archive |

All four commands share the same 8 spec documents in `references/`. audit is a full project health check; review is lightweight rule maintenance (auto-triggered every 30 turns by the built-in hook).

---

## Usage / 用法

### Start a new project / 建新项目

```
/project-setup init notes-sync "把本地 Markdown 笔记增量同步到 S3 的 CLI" /Users/you/projects/notes-sync
```

Or just describe your intent in natural language — Claude will ask a few rounds of questions (tech stack, deployment, key decisions, artifact types), then generate a customized collaboration layer with real content, not placeholder templates.

**Rules layer stays empty on init.** Rules come from real mistakes. Generating rules upfront produces fake rules that dilute the real ones.

### Audit an existing project / 审查已有项目

```
/project-setup audit /Users/you/projects/existing
```

Claude reads each `references/` spec, reads your project files, and makes judgment calls with direct quotes — not generic advice. Example output:

```markdown
# notes-sync 深度审查报告（2026-05-02）

## 1. CLAUDE.md 规则质量  🔴

### 发现
- L23-L45 是错误码表（事实），应该进 .claude/memory/
- L67 "尽量使用 TypeScript" 是柔化词，无约束力

### 建议
- 把 L23-L45 迁到 .claude/memory/reference_api_errors.md
- L67 改成 "写 TypeScript 必须启用 strict: true"
```

audit is read-only. Nothing changes until you run `apply`.

---

## Built-in Hooks / 预置 Hook

Two Node.js hooks ship with `init`, wiring up automatic maintenance across sessions:

**`session-brief.js`** (SessionStart) — At the start of every new session, Claude reads your journal, memory index, and todo list, then delivers a 3–5 line brief: *"Last time we did X / current focus Y / pick up at Z."* No more re-explaining context.

**`turn-reflect.js`** (Stop, three-tier) — After each response:

| Every | Action |
|-------|--------|
| **5 turns** | Silently assess if anything is worth journaling. If yes, dispatch a background agent to write — main thread returns immediately with a brief `📝` notice |
| **10 turns** | Same pattern for distillation: check if a lesson or rule should be extracted, dispatch background if yes (`✨` notice) |
| **30 turns** | Rules layer review in main thread: scan for duplicates, conflicts, stale or upgradeable rules |

Claude judges whether to act. Nothing happens if there's nothing worth capturing.

**Configure:**
- Scripts: `.claude/hooks/session-brief.js` and `.claude/hooks/turn-reflect.js`
- Enable/disable: edit `hooks.SessionStart` / `hooks.Stop` in `.claude/settings.local.json`
- Adjust thresholds: change `JOURNAL_EVERY` / `DISTILL_EVERY` / `REVIEW_EVERY` at the top of `turn-reflect.js` (set to `999999` to disable a tier)

---

## Specs / 标准文档

8 documents in `references/` define what a healthy Claude project looks like. All four commands judge against these — not memory, not convention:

| File | Covers |
|------|--------|
| `claudemd.md` | CLAUDE.md lean skeleton, rules vs. facts boundary, imperative style |
| `journal.md` | Reverse-chronological entries, three-field format, session-start hook |
| `memory.md` | `.claude/memory/` naming, frontmatter, index consistency, autoMemoryDirectory |
| `rules.md` | `.claude/rules/` imperative style, paths scope, distillation source |
| `lessons.md` | Narrative + reusable rules section, position in distillation chain |
| `docs.md` | `docs/` for humans not Claude, numbering, archiving |
| `workspace.md` | `workspace/` as temporary-only, boundary with artifact directories |
| `gitignore.md` | memory whitelist, settings.local.json must be ignored |

You can read these as standalone writing guides, independent of the skill.

---

## Project Structure / 目录结构

```
claude-project-skill/
├── SKILL.md              # routing and full logic for all four commands
├── README.md
├── LICENSE               # MIT
├── references/           # 8 spec documents
└── assets/               # scaffold copied during init
    ├── CLAUDE.md
    ├── journal.md
    ├── README.md
    ├── .gitignore
    ├── docs/
    ├── lessons/
    ├── workspace/
    ├── presets/          # optional rule presets installed per project type
    │   ├── README.md
    │   └── coding-general.md
    └── .claude/
        ├── settings.local.json.example
        ├── memory/MEMORY.md
        ├── rules/
        └── hooks/
            ├── session-brief.js
            └── turn-reflect.js
```

---

## Contributing / 贡献

PRs welcome for `references/*.md` spec improvements, `assets/` scaffold updates, or issues flagging inaccurate audit judgments.

## License

MIT — see [LICENSE](LICENSE).

## Related / 相关

- [skill-creator](https://github.com/anthropics/skills) (Anthropic official) — how to build Claude Code skills
- Claude Code built-in `/init` — generates a CLAUDE.md first draft
