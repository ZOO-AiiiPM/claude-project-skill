# claude-project-skill

[Claude Code](https://docs.claude.com/en/docs/claude-code) skill，给项目铺标准的协作骨架：`CLAUDE.md` / `journal.md` / `.claude/memory/` / `.claude/rules/` / `.claude/hooks/` / `lessons/` / `docs/`。

四个子命令：

- `/project-setup init <name> <desc> <abs_path>` — 对话式起新项目
- `/project-setup audit [path]` — 按标准扫已有项目，出带原文引用的诊断报告（只读）
- `/project-setup apply [path]` — 按 audit / review 报告改项目（逐条授权）
- `/project-setup review [path]` — 规则层质量审查（扫 CLAUDE.md + rules/ 去重 / 合并 / 升级 / archive）

四个动作共用同一份标准（`references/` 下 8 份文档）。audit 是全项目宏观体检，review 是规则层日常维护（hook 每 30 轮自动触发一次）。

---

## 安装

personal skill（当前账户所有项目可用）：

```bash
git clone https://github.com/ZOO-AiiiPM/claude-project-skill.git \
  ~/.claude/skills/project-setup
```

project skill（仅当前项目）：

```bash
git clone https://github.com/ZOO-AiiiPM/claude-project-skill.git \
  .claude/skills/project-setup
```

装完重启 Claude Code session。

---

## 用法

### 建新项目

```
/project-setup init notes-sync "把本地 Markdown 笔记增量同步到 S3 的 CLI" /Users/you/projects/notes-sync
```

也可以直接描述意图：

> 帮我在 /Users/you/projects/ 下建一个新项目 "notes-sync"，描述是"把本地 Markdown 笔记增量同步到 S3 的 CLI"

Claude 会走几轮对话问技术栈、部署方式、关键决策、会不会产出 eval / LLM / 爬虫数据等，然后：

- 拷 `assets/` 骨架到目标路径，替换占位符
- 根据对话内容写 `.claude/memory/project_stack.md`、`reference_deployment.md` 等事实文件（含 MEMORY.md 索引）
- `journal.md` 第一条写进对话里讲过的选型决策
- 按项目类型建产物目录（有 eval 就建 `eval-results/`、有爬虫就建 `scraped-data/` 等）
- 配好 `autoMemoryDirectory` 绝对路径 + git init

**规则层留空**：项目硬规则 / rules 内容 / lessons 都不会自动生成，要等真实踩坑后自己补。凭空生成的规则是伪规则，会稀释真规则的可见性。

### 审查已有项目

```
/project-setup audit /Users/you/projects/existing
```

或：

> 扫一下我这个项目结构健不健康

Claude 会按 8 个维度深度审视，每个维度 Read `references/` 对应标准 + Read 项目文件 + 带原文引用下判断，输出类似：

```markdown
# notes-sync 深度审查报告（2026-05-02）

## 1. CLAUDE.md 规则质量  🔴

### 发现
- L23-L45 是错误码表（事实），应该进 .claude/memory/
- L67 "尽量使用 TypeScript" 是柔化词，无约束力

### 建议
- 把 L23-L45 迁到 .claude/memory/reference_api_errors.md
- L67 改成 "写 TypeScript 必须启用 strict: true"

### 引用证据
- CLAUDE.md:67 原文："尽量使用 TypeScript 来增强类型安全"
```

还会找 journal 里反复出现的"坑了"模式、lessons 没抽到 rules 的可复用规则、代码里的反模式等，**基于项目内实证**给规则建议（不凭通用经验推）。

audit 只读，不改文件。

### 按报告改

```
/project-setup apply
```

Claude 会列出 audit / review 报告里的所有建议，让你选全部接受 / 选择性接受 / 跳过，按你授权的条目逐条改，每步 Read 对应 `references/*.md` 作标准、改完即时验证。

### 规则层 review

```
/project-setup review
```

或：

> 看看我的规则还有啥问题

只扫 CLAUDE.md + `.claude/rules/`，找重复规则 / 冲突规则 / 可合并 / 可升级到全局 / 过期 / 含柔化词的规则，输出建议清单。

**和 audit 的差别**：audit 是全项目 8 维度宏观体检，review 聚焦规则层、更轻、更常用。项目跑起来后规则会越写越多，review 负责定期"剪枝"—— 让规则集随项目演化而不是只增不减。

review 只读，不改文件；要改走 apply 或手动。

---

## 预置 hook：turn-reflect

init 默认装一个 `Stop` 事件 hook，每轮对话后触发：

- **每 5 轮** — journal 提醒：判断要不要 append journal（有决策 / 踩坑 / 学到就写，否则跳过）
- **每 10 轮** — 蒸馏提醒：判断要不要蒸馏成 lesson / rules / CLAUDE.md 硬规则（附带 lesson / rule 的写作标准，Claude 照着落地）
- **每 30 轮** — 规则层 review 提醒：扫 CLAUDE.md + rules/ 找重复 / 冲突 / 可合并 / 可升级 / 过期的规则（等同 `/project-setup review` 自动触发一次）

三级阈值对应三种粒度的维护：短周期记录、中周期蒸馏、长周期剪枝。Claude 自己判断，没值得记 / 没发现问题就静默跳过。

**配置**：

- 脚本 `.claude/hooks/turn-reflect.sh`
- 启用/关闭：`.claude/settings.local.json` 的 `hooks.Stop` 段
- 调阈值：改脚本顶部 `JOURNAL_EVERY` / `DISTILL_EVERY` / `REVIEW_EVERY`
- 想关某一级：对应阈值设为大值（如 `999999`）

---

## 标准

`references/` 下 8 份：

| 文件 | 管什么 |
|------|-------|
| `claudemd.md` | CLAUDE.md 瘦骨架、规则 vs 事实边界、写作命令式 |
| `journal.md` | journal.md 倒序、三段式、session 开头读顶部钩子 |
| `memory.md` | `.claude/memory/` 命名、frontmatter、索引一致性、autoMemoryDirectory |
| `rules.md` | `.claude/rules/` 命令式、paths 作用域、蒸馏来源 |
| `lessons.md` | `lessons/` 叙事 + 可复用规则段、蒸馏链位置 |
| `docs.md` | `docs/` 给人读而非给 Claude、编号、archive |
| `workspace.md` | `workspace/` 纯临时语义、和耗时产物目录的边界 |
| `gitignore.md` | `.gitignore` memory 白名单、settings.local.json 必须忽略 |

可以单独读这些标准当作写作参考，不一定要用 skill 本身。

---

## 目录结构

```
claude-project-skill/
├── SKILL.md              # init / audit / apply / review 路由
├── README.md
├── LICENSE               # MIT
├── references/           # 8 份标准文档
└── assets/               # init 时拷的骨架
    ├── CLAUDE.md
    ├── journal.md
    ├── README.md
    ├── .gitignore
    ├── docs/
    ├── lessons/
    ├── workspace/
    └── .claude/
        ├── settings.local.json.example
        ├── memory/MEMORY.md
        ├── rules/
        │   └── database-migration.md.example   # 规则文件样板
        └── hooks/turn-reflect.sh
```

---

## 不做的事

- **init 目标路径非空时直接拒绝**。不覆盖、不合并、不备份。用户现有文件不可推测。
- **audit / review 不改文件**。要改走 apply 或手动。
- **占位符只替换 `{PROJECT_NAME}` 和 `{一句话项目描述}`**。不推断项目类型、不自动填服务器 IP、不加 boilerplate。
- **不扩展到 migrate / clean / 删"垃圾"**。eval 数据、LLM 产物、爬虫数据误删不可恢复。

---

## 贡献

欢迎 PR 改 `references/*.md`、改 `assets/` 骨架，或开 issue 反馈 audit 的不合理判断。

## License

MIT，见 [LICENSE](LICENSE)。

## 相关

- [skill-creator](https://github.com/anthropics/skills)（Anthropic 官方）：写单个 skill 的方法
- Claude Code 内置 `/init`：生成 CLAUDE.md 初稿
