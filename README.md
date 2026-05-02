# claude-project-skill

一个 [Claude Code](https://docs.claude.com/en/docs/claude-code) skill，给你的项目提供统一的**记忆协作层标准**：

- **init** — 按标准骨架建新项目，一次到位
- **audit** — AI 深度审查已有项目，出带原文引用的诊断报告（只读）
- **apply** — 按报告建议改项目（用户逐条授权）

三件事共享一份"项目协作层标准"（`references/` 下 8 份 spec），从 KOX-CLI 项目的 487 行 CLAUDE.md → 69 行整理经验抽出来，跑通后公开。

---

## 为什么要这个

Claude Code 原生支持 CLAUDE.md、auto-memory、hooks、slash commands，但**不告诉你怎么组织**：

- CLAUDE.md 该写什么？什么情况下会膨胀？
- journal / memory / rules / lessons 什么关系？怎么分工？
- 不同 session 之间怎么同步进度？
- 项目跑了几周后怎么判断"协作层还健康吗"？

这些问题的答案是**标准**（不是工具）。本 skill 做两件事：

1. **把标准写死在 `references/*.md`** —— 8 份 spec 各覆盖一个方面（CLAUDE.md / journal / memory / rules / lessons / docs / workspace / .gitignore），每份都说明"应该长什么样 / 为什么这样 / 判断标准 / 反模式 / 示例"
2. **用 Claude 自己做 init / audit / apply** —— 不是 bash 脚本检查文件名，是真读项目内容 + 读标准，做主观判断

---

## 安装

### 方式 1：personal skill（当前账户所有项目可用）

```bash
git clone https://github.com/ZOO-AiiiPM/claude-project-skill.git ~/.claude/skills/project-setup
```

装完重启 Claude Code session，输入 `/project-setup` 会自动识别。

### 方式 2：project skill（仅当前项目）

```bash
git clone https://github.com/ZOO-AiiiPM/claude-project-skill.git .claude/skills/project-setup
```

### 方式 3：手动拷贝（离线 / 内网）

克隆本 repo 后，把整个目录放到 `~/.claude/skills/project-setup/` 即可。

---

## 用法

### 建新项目

```
/project-setup init my-project "一句话描述" /Users/you/projects/my-project
```

或直接描述意图：

> 帮我在 /Users/you/projects/ 下建一个新项目 "KOX-CLI"，描述是 "把 KOX 营销平台封装成 Claude Code skill"

Claude 会：
1. 校验目标路径为空
2. 从 `template/` 拷完整骨架
3. 替换 `{PROJECT_NAME}` 和 `{一句话项目描述}` 占位符
4. 配好 `autoMemoryDirectory` 绝对路径
5. git init + 首次 commit
6. 给你下一步清单

### 审查已有项目

```
/project-setup audit /Users/you/projects/existing
```

或：

> 扫一下我这个项目结构健不健康

Claude 会按 8 个维度深度审视，输出类似：

```markdown
# {项目名} 深度审查报告（2026-05-02）

## 1. CLAUDE.md 规则质量  🔴

### 发现
- 行数 245（超 > 200 阈值）
- L23-L45 是错误码表（事实），应该进 .claude/memory/
- L67 "尽量使用 TypeScript" 是柔化词，无约束力

### 建议
- 把 L23-L45 迁到 .claude/memory/reference_api_errors.md，CLAUDE.md 留一行索引
- L67 改成 "写 TypeScript 必须启用 strict: true"

### 引用证据
- CLAUDE.md:23 原文：| 10001 | 参数错误 | ...
- CLAUDE.md:67 原文："尽量使用 TypeScript 来增强类型安全"

## 2. journal 活跃度  🟡

...
```

只读，不改你的文件。

### 按报告改项目

```
/project-setup apply
```

Claude 会把上一次 audit 报告里的建议逐条列出来让你选：全部接受 / 选择性接受 / 跳过。你授权哪条改哪条。

---

## 标准在哪里

所有判断依据都在 `references/`：

| 文件 | 管什么 |
|------|-------|
| `claudemd-spec.md` | CLAUDE.md 行数、段、规则 vs 事实边界 |
| `journal-spec.md` | journal.md 倒序、三段格式、活跃度阈值 |
| `memory-spec.md` | .claude/memory/ 命名、frontmatter、索引一致性 |
| `rules-spec.md` | .claude/rules/ 命令式、paths 作用域 |
| `lessons-spec.md` | lessons/ 叙事标准、蒸馏链位置 |
| `docs-spec.md` | docs/ 人读文档、编号、archive |
| `workspace-spec.md` | workspace/ 临时产物、gitignore 覆盖 |
| `gitignore-spec.md` | .gitignore 必须段、memory 白名单 |

每份结构一致：**应该长什么样 / 为什么这样 / 判断标准 / 反模式 / 示例**。

可以单独读这些 spec 作为写作参考，不一定要用 skill 本身。

---

## 目录结构

```
claude-project-skill/
├── SKILL.md                   # 主入口（init / audit / apply 路由）
├── README.md                  # 本文件
├── LICENSE                    # MIT
├── references/                # 8 份标准 spec
│   ├── claudemd-spec.md
│   ├── journal-spec.md
│   ├── memory-spec.md
│   ├── rules-spec.md
│   ├── lessons-spec.md
│   ├── docs-spec.md
│   ├── workspace-spec.md
│   └── gitignore-spec.md
└── template/                  # init 时拷贝的骨架
    ├── CLAUDE.md              # 瘦骨架（< 80 行）
    ├── journal.md             # 倒序时间线骨架
    ├── README.md              # 项目介绍模板
    ├── .gitignore             # 含 memory 白名单
    ├── docs/
    ├── lessons/
    ├── workspace/
    └── .claude/
        ├── settings.local.json.example   # autoMemoryDirectory + Stop hook
        ├── memory/MEMORY.md
        ├── rules/
        └── hooks/
            └── journal-turn-counter.sh   # 每 5 轮提醒 append journal
```

---

## 4 条硬边界（为什么不自动改更多）

1. **init 目标非空 → 立即拒绝**。不覆盖、不备份、不合并。用户现有文件不可推测。
2. **audit 只读**。第三方视角诊断是它的核心价值，自动改会破坏这个定位。要改走 apply。
3. **占位符替换只改 2 个明确占位**。不自动填服务器 IP、不推断项目类型、不加 boilerplate。推断必错。
4. **拒绝 migrate / clean / 删"垃圾"**。"垃圾"语义模糊，eval 数据、LLM 产物、爬虫数据误删不可恢复。

---

## 贡献

标准本身是最有价值的部分 —— 用到的人越多，spec 越容易被打磨。欢迎：

- PR 改进 `references/*.md`（补反模式、加示例、修改条款）
- Issue 报告你的项目 audit 出来觉得不合理的判断
- PR 改进 `template/` 骨架
- 在自己的项目里试 init / audit / apply，回来告诉我们哪些场景 skill 没接住

---

## License

MIT. 见 [LICENSE](LICENSE)。

---

## 相关 skill

- **[skill-creator](https://github.com/anthropics/skills)**（Anthropic 官方）：写单个 skill 的方法。本 skill 的"项目层标准" + skill-creator 的"skill 层写作"是互补关系。
- Claude Code 内置 `/init`：生成 CLAUDE.md 初稿。可先用内置 init 再用本 skill audit。

---

## 来源

整套标准从 KOX-CLI 项目整理经验抽出（CLAUDE.md 487 → 69 行，建立 journal/memory/rules/lessons 分工），跑通后公开。经历过的踩坑有多篇 lesson 案例作为 references 的实证支撑。
