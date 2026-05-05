---
name: project-setup
description: >
  对话式初始化新项目（多轮对话收集事实 → 生成 CLAUDE.md / memory / rules / hooks / journal 协作骨架 + 事实层文件，
  规则层留空等踩坑后填）、按标准深度审查现有项目协作层（带原文引用 + 项目实证的诊断报告）、
  按报告逐条改造项目、对 CLAUDE.md 和 rules/ 做规则层 review（去重 / 合并 / 升级 / archive）。
  用户说新建项目、项目骨架、项目健康检查、规不规范、按标准改项目、应用审查建议、规则优化、规则去重时都要触发，
  即使只是随口说"建个项目"或"扫一下这项目"或"看看我的规则还有啥问题"。项目缺少 CLAUDE.md 或目录结构混乱时也主动建议使用。
user-invocable: true
argument-hint: [init <name> <desc> <abs_path> | audit [path] | apply [path] | review [path]]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# project-setup

这个 skill 的主要产物是**一套项目协作层标准** —— 记在 `references/` 的 8 份文档里（claudemd / journal / memory / rules / lessons / docs / workspace / gitignore 各一份）。标准本身定义了"合格的 Claude Code 项目长什么样"，三个动作围绕同一份标准展开：

**init** 不是简单拷贝空骨架，而是**通过对话收集项目事实 → 生成事实层内容 + 协作骨架**。生成的 memory / README / journal 第一条都有实内容（用户口述的事实），而规则层（项目硬规则 / rules 内容 / lessons）保留空骨架 —— 规则来自踩坑，init 时没踩过坑，凭空生成的规则是伪规则，会稀释真规则的可见性。

**audit** 是**基于 references 标准 + 项目实证的深度诊断**。Claude Read 标准 + Read 项目文件 + Grep 代码，做主观判断，每条发现带原文引用、每条建议带项目内实证（不凭通用经验推）。输出报告不改文件。

**apply** 是 audit 报告的**逐条执行**。用户看完报告决定接受哪些，Claude 按 references 标准做改动。

三者共用同一份 `references/`，init 按它建、audit 按它比、apply 按它改 —— 这保证了整条 skill 的输出一致性。

---

## 用户输入

$ARGUMENTS

---

## 路由判断

用户说"建 / 初始化 / 新项目 / 从模板 / init"走 init；说"审查 / 扫 / 规不规范 / 健康检查 / audit"走 audit；说"apply / 按建议改 / 接受报告 / 应用改动"走 apply；说"review / 规则优化 / 规则去重 / 规则冲突 / 规则升级"走 review。拿不准时直接问用户 "你是想建新项目 / 审视已有项目 / 按上次 audit 报告改 / 只做规则层 review？"，不要猜 —— 这四个场景做的事完全不同，猜错代价大（init 新建 vs audit 只读 vs apply 动文件 vs review 规则层诊断）。

**review 和 audit 的差别**：audit 是全项目协作层审查（8 个维度覆盖 CLAUDE.md / journal / memory / rules / lessons / docs / workspace / gitignore），重在结构与标准合规；review 聚焦**规则层质量**（只看 CLAUDE.md 和 rules/），找重复 / 冲突 / 可合并 / 可升级 / 过期的规则。review 更轻、更常用（turn-reflect hook 每 30 轮自动触发），适合项目跑起来后定期做；audit 更重、更宏观，适合阶段性体检或转交项目时做。

---

## references/ 作为判断依据

所有三个动作的判断都来自 `references/*.md` 这 8 份标准。每份结构统一：首段讲本文件在协作链里的位置 → 散文化讲规则 + 为什么 + 反面 → 审视段讲怎么判断健康 → 反模式段讲共同根因 → 示例。

| 文件 | 管什么 |
|------|-------|
| [claudemd.md](references/claudemd.md) | `CLAUDE.md` 瘦骨架 / 规则 vs 事实边界 / 写作命令式 |
| [journal.md](references/journal.md) | `journal.md` 倒序 / 三段式 / session 开头读顶部钩子 |
| [memory.md](references/memory.md) | `.claude/memory/` 命名 / frontmatter / 索引一致性 / autoMemoryDirectory |
| [rules.md](references/rules.md) | `.claude/rules/` 命令式 / paths 作用域 / 蒸馏来源 |
| [lessons.md](references/lessons.md) | `lessons/` 叙事 + 可复用规则段 / 蒸馏链位置 |
| [docs.md](references/docs.md) | `docs/` 给人读而非给 Claude / 编号 / archive |
| [workspace.md](references/workspace.md) | `workspace/` 纯临时语义 / 和耗时产物目录的边界 |
| [gitignore.md](references/gitignore.md) | `.gitignore` memory 白名单 / settings.local.json 必须忽略 |

**用这些标准的方式**：做判断前 Read 对应标准，不凭记忆。标准会演化，记忆会漂移 —— 当下 Read 是唯一不会出错的做法。

---

## init 子场景

### 本质

init 的核心是**把空项目带到"有协作骨架 + 有项目事实"的起点**，而不是带到"有完整规则"的成熟状态。成熟状态靠项目跑起来后的蒸馏链（journal → lesson → rules），init 跳不过这个过程。

所以 init 做两类事：**生成事实层内容**（用户口述就能落字、零推理空间的东西 → memory / README / journal 第一条 / 产物目录）、**搭建协作骨架**（CLAUDE.md 瘦骨架、rules 空骨架文件带 paths、hooks、gitignore）。

不做的一类事：**凭空生成规则内容**（项目硬规则 / lessons / rules 文件里的具体条款）。原因是这些东西的正当来源是真实踩坑、用户纠正、事故沉淀 —— init 阶段没有这些来源，生成的规则必是通用建议（"代码要清晰"、"测试覆盖率要高"这种），放进 CLAUDE.md 会稀释真规则的可见性。等项目跑起来、真踩了坑再蒸馏，这是蒸馏链该有的节奏。

### 必须从用户请求提取的三项

**project_name**（填 `{PROJECT_NAME}` 占位）、**description**（填 `{一句话项目描述}` 占位）、**target_path**（绝对路径，相对路径受 cwd 影响不可预测）。缺任一项就问，不编造默认值。

### 多轮对话收集事实（不超过 6-8 轮）

拿到三项后进入对话阶段，每轮问清一件事：

**第 1 轮：技术栈**。主语言（Python / TypeScript / Go / Rust / ...）、主要框架（FastAPI / Next.js / Django / ...）、项目类型（CLI 工具 / Web 应用 / 库 / eval / 爬虫 / ML 训练 / ...）。答案直接决定后续生成什么。

**第 2 轮：部署方式**。本地运行 / 云函数 / k8s / SaaS 平台 / 纯库（不部署）。决定 memory 里要不要建 `reference_deployment.md`。

**第 3 轮：团队情况**。个人 / 小团队；有没有协作规范要对齐。个人项目不需要某些团队约束。

**第 4 轮：产物类型**（关键，决定要不要建顶级产物目录）。项目会产出 eval 结果吗？LLM 生成内容吗？爬虫数据吗？embedding 缓存吗？有 → init 时建对应顶级目录（`eval-results/` / `llm-outputs/` / `scraped-data/` / `embeddings/`），配 gitignore；没有 → 不建，保持项目根干净。大部分项目只有 0-2 个产物类型，不会全中。

**第 5 轮：已做的关键决策**（可选，有就问）。选型决策（选 FastAPI 不选 Django / 选 Postgres 不选 MySQL / 选 npm 不选 pnpm）、放弃的方案、背后原因。这些答案会变成 journal 第一条的内容。

**第 6 轮：已知约束 / 风险点**（可选）。合规要求 / 性能目标 / 外部依赖。进 `project_constraints.md` 或直接在 journal 第一条提到。

每轮拿到答案立刻落笔到 TodoList（或内存记录），不攒到最后。攒到最后记忆会模糊、可能漏问。

### 生成阶段

校验目标路径非空 → 立即拒绝。这是硬边界，不自动覆盖、不合并、不备份 —— 用户现有文件不可推测是什么，擅自动等于破坏。

校验通过后：

```bash
mkdir -p "$TARGET_PATH"
cp -R "${CLAUDE_SKILL_DIR}/assets"/. "$TARGET_PATH/"
# presets/ 是 skill 的按需拷贝库，不是项目默认结构，拷完立即删
rm -rf "$TARGET_PATH/presets"
```

然后按对话答案**定向生成**：

**替换占位符**（只改两个明确占位 `{PROJECT_NAME}` 和 `{一句话项目描述}`，不做"智能替换" —— 自动填服务器 IP / 推断项目类型 / 加 boilerplate 都禁止，推断几乎必错）：

```bash
cd "$TARGET_PATH"
for f in README.md CLAUDE.md journal.md; do
  [ -f "$f" ] && perl -i -pe "s/\{PROJECT_NAME\}/$PROJECT_NAME/g; s/\{一句话项目描述\}/$DESCRIPTION/g" "$f"
done
```

用 perl 而不是 sed：mac / Linux 的 `sed -i` 参数行为不一致，perl 跨平台。

**生成 memory 事实文件**（按对话收集到的技术栈 / 部署 / 约束，Write 对应 `reference_*.md` / `project_*.md` 文件，同步 MEMORY.md 索引加条目）：

```
.claude/memory/
├── MEMORY.md                       ← 加索引条目
├── project_stack.md                 ← 写入技术栈事实
├── reference_deployment.md          ← 如果有部署目标
└── project_constraints.md           ← 如果有已知约束
```

**生成 journal 第一条**（基于对话里的"关键决策"，不是"今天建了项目"这种凑数条目）：

```markdown
## 2026-XX-XX 项目起手 + 关键选型

- **做了**：从 project-setup 骨架建项目，初步定了 X / Y / Z
- **坑了**：-
- **学到**：-
- **决策**：选 X 不选 Y | 因为 {用户口述的原因} | 替代方案是 Z
```

**生成 rules/ 空骨架**（根据技术栈预装带 paths 的空文件，内容只写一行注释提醒等踩坑后填）：

```markdown
---
paths:
  - "**/*.py"
---

# {项目名} Python 规则

<!-- 等项目真实暴露问题后填。别凭空写通用建议。 -->
```

**按项目类型装 preset（可选，代码项目推荐）**：如果第 1 轮答案是代码项目（Python / TS / Go / Rust 等），检查 session 的 available skills 里有没有 `andrej-karpathy-skills:karpathy-guidelines` 或等同编码规则 skill：

- **有** → 在 `CLAUDE.md` "关键资源索引"段加一行 `- **写代码**：参考 karpathy-guidelines skill（防 LLM 常见编码错误）`。不复制内容（全局 skill 触发更精准、升级有版本）
- **无** → 从 `${CLAUDE_SKILL_DIR}/assets/presets/coding-general.md` 拷到 `$TARGET_PATH/.claude/rules/coding-general.md`（preset 自带 paths，写代码类文件时自动触发）

非代码项目（纯写作 / 研究 / 聊天脚本）跳过此步。presets 目前只有 `coding-general.md` 一份，其他类型按需再加。

**按产物类型建顶级目录**（根据第 4 轮答案，只建用户确认会有的）：

```bash
[ "$HAS_EVAL" = "yes" ] && mkdir -p eval-results
[ "$HAS_LLM_OUTPUT" = "yes" ] && mkdir -p llm-outputs
[ "$HAS_SCRAPE" = "yes" ] && mkdir -p scraped-data
```

**更新 gitignore**（按建的产物目录加对应规则 —— 小的 summary 入 git、大的原始输出忽略）。

**配 autoMemoryDirectory**：

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
perl -i -pe "s|/绝对路径/到项目/\.claude/memory|$TARGET_PATH/.claude/memory|g" .claude/settings.local.json
```

**git init**（如果 target_path 不在 git repo 内）：

```bash
if ! git rev-parse --show-toplevel > /dev/null 2>&1; then
  git init -b main && git add . && git commit -m "chore: 从 project-setup 初始化"
fi
```

已在 repo 里（monorepo 子目录场景）**不要**再 git init —— 会在子目录建独立 repo 造成混乱。

### 汇报下一步

生成完告诉用户：

```
✓ 项目已初始化：{TARGET_PATH}

事实层已写入：
- memory/project_stack.md（技术栈）
- memory/reference_deployment.md（部署方式）
- journal.md 首条（项目起手 + 关键选型）
- README.md（项目背景）

协作骨架：
- CLAUDE.md 瘦骨架（项目硬规则段留空，等踩坑填）
- .claude/rules/ 按技术栈预装空文件（带 paths）
- .claude/hooks/turn-reflect.sh + session-brief.sh 默认启用（跨 session 同步 + 每 5/10/30 轮三级维护提醒）

产物目录：
- eval-results/  ← 按你说有 eval 建的
- llm-outputs/   ← 按你说有 LLM 生成建的

下一步：
1. 第一次真实踩坑后给 CLAUDE.md "项目硬规则"段加第一条
2. 想推 GitHub：gh repo create <org>/<name> --source=. --public --push
3. 不要某个 hook 就删 .claude/settings.local.json 里对应 hooks 子段（SessionStart / Stop）
4. 新开 Claude session 验证 CLAUDE.md 自动加载
```

---

## audit 子场景

### 本质

audit 是 **AI 驱动的深度诊断**，不是文件名清单检查。Claude 要真读项目内容、按 `references/` 标准做**主观判断**、每个判断带**原文引用 + 项目实证**。

和传统"机械扫结构"的区别：机械扫是"有没有 X 文件、行数超没超"，主观判断是"这份 CLAUDE.md 里有没有规则被写糊了 / 有没有事实混进来 / 有没有索引路径失效 / journal 的'坑了'字段最近出现了什么重复模式"。主观判断能命中机械扫不到的深层问题，代价是 Claude 要读、要思考、要引原文。

**硬约束**：

- **只读**。禁止用 Write / Edit / Bash mv/cp/rm 改目标项目任何文件。audit 的价值是"第三方视角诊断"，自动改会破坏这个定位，要改走 apply。
- **基于原文**。不说"我看到" / "我印象中"，每个判断带文件路径 + 行号 + 原文片段。
- **基于 references**。判断依据必须来自 `references/*.md` 条款，不凭记忆编标准。
- **规则建议必须带实证**。建议新增 / 改写规则时必须说明来源（journal 某条 / lesson 某段 / memory 某事实 / 代码 grep 证据）。不凭通用经验推（"一般 Python 项目都该有 X 规则"这类禁止）。
- **不扩展职责**。用户要求 "顺便清一下废弃文件" / "自动迁移" 时礼貌拒绝："audit 只给报告，改动走 `/project-setup apply`"。

### 输入

**target_path**（可选，默认当前项目根，未给则直接跑，不主动问）。

### 执行流程

**第一步：机械确认项目有什么**（Bash + Glob）。知道目录里实际存在哪些文件 / 目录 / memory / rules / lessons / hooks。这步不做判断，只给 Claude 一个"待审查清单"。

**第二步：逐维度深度审视**。8 个维度各自 Read 对应标准 + Read 项目文件 + 下判断。每个维度写一段散文说明问题，不是列清单。核心是：Claude 要先把 `references/` 对应标准读进来，然后问自己"这份项目的 X 文件在这个标准下表现如何"，答案带具体引用。

具体 8 个维度：

**CLAUDE.md 规则质量**：Read `claudemd.md` 标准 + Read 项目 CLAUDE.md。判断行数 / 段完整性 / 有没有规则和事实混入 / 柔化词 / 索引路径真不真实（Glob 验证）/ 占位符残留 / 待做时效。输出具体条款的原文引用 + 该怎么改。

**journal 活跃度 + 模式识别**：Read `journal.md` 标准 + Read 项目 journal（至少读前 150 行覆盖最近条目）。判断顶部条目距今天多久 / 倒序正不正确 / 三段式完整度 / 真实性 / **最近 7-14 天"坑了"字段有没有重复出现的词**（有 = 蒸馏信号，该抽 rule 或 lesson）。输出活跃度评级 + 具体重复模式 + 蒸馏建议。

**MEMORY 索引 ↔ 磁盘一致性 + description 质量**：Read `memory.md` 标准 + Bash 列磁盘 + Read MEMORY.md 索引。找 orphan（磁盘有索引无）/ dead link（索引有磁盘无）。检查每条 description 是否带具体关键词还是"关于 X 的事情"这种无效描述。有没有禁用的 `feedback_*.md` 或独立 `decisions.md`。输出具体 orphan / dead link 清单 + description 薄弱条目 + 重写建议。

**.claude/rules/ 效力**：Read `rules.md` 标准 + Read 项目每份 rules 文件。判断命令式还是原则式 / 有没有触发锚点 / 解释 why / 示例即规则 / paths 作用域合理性 / 和全局 `~/.claude/rules/` 有没有重复。输出具体规则原文 + 重写示例。

**lessons/ 蒸馏效率**：Read `lessons.md` 标准 + 逐份 Read 每个 lesson。判断每份结尾有没有"可复用规则"段 / 规则有没有抽到 rules/ / 有没有单薄到该降回 journal 的 / 过长该拆的 / 命名 5 秒能否看懂主题。输出哪些该抽 rule / 哪些该合并 / 哪些该 archive。

**docs/ 和 workspace/ 纪律**：Read `docs.md` + `workspace.md` 标准 + 扫两个目录。判断 docs 有没有误放 Claude 规则 / workspace 有没有误放耗时产物 / docs 归档纪律 / 顶级产物目录（`eval-results/` 等）有没有应该建但没建的。输出该挪的文件 + 目标位置。

**.gitignore 配置闭环**：Read `gitignore.md` 标准 + Read 项目 .gitignore。判断 memory 白名单是否完整 / `settings.local.json` 是否忽略 / `.env` 是否覆盖 / workspace/tmp 是否忽略 / 产物目录 gitignore 规则是否对应。输出缺失必须项 + 泄漏风险。

**hooks / autoMemoryDirectory 可用性**：这一维度的本质是"hook 层在这个项目能不能跑起来"，而不只是"已有配置对不对"。可用需要三件事同时成立：（a）`.claude/hooks/session-brief.sh` 和 `turn-reflect.sh` 存在且 `+x`；（b）`.claude/settings.local.json` 里 `hooks.SessionStart` / `hooks.Stop` 段指向这两个脚本；（c）`autoMemoryDirectory` 是指向真实存在目录的绝对路径。三者任一缺失 hook 就不会触发。Read `.claude/settings.local.json`（如果存在）+ Bash 列 hooks 目录 + 验证 autoMemoryDirectory 路径。**缺失时的建议统一是"从 `${CLAUDE_SKILL_DIR}/assets/.claude/hooks/` 拷脚本 + 从 `assets/.claude/settings.local.json.example` 初始化或合并 settings.local.json + 替换 autoMemoryDirectory 占位为项目绝对路径"** —— 已有项目没跑过 init 时 hook 本来就没装，这维度要把"补装"当正常建议给出，不是当特殊情况处理。

**第三步：规则内容建议（新）**。读完 journal 和 lessons 后，找**项目内实证**推规则：

- journal 里连续 3+ 条 "坑了" 提到同一模式 → 建议 "把这个抽成 `.claude/rules/{主题}.md` 的第 N 条规则"，附 journal 原文
- lesson 结尾"可复用规则"段但没抽到 `rules/` → 建议挪，附 lesson 原文
- 代码 grep 出多处反模式（比如 `bare except` / 裸 `await` 无超时 / 硬编码密钥）→ 建议加 rule 关闭，附 grep 证据
- CLAUDE.md 里模糊规则（"尽量 X"）→ 给命令式重写版

**硬约束**：每条规则建议必须配原文引用 / grep 证据 / lesson 出处。没实证的建议（"一般 Python 项目都该有 strict type hints" 这种）**禁止给**。

### 报告格式

固定 markdown 结构，便于不同时间对比：

```markdown
# {项目名} 深度审查报告（{YYYY-MM-DD}）

**路径**：$TARGET_PATH
**基于标准**：references/*.md（8 份）
**总评**：一句话项目协作层健康度判断（健康 / 一般 / 需整治）

---

## 1. CLAUDE.md 规则质量  🟢 / 🟡 / 🔴

### 发现
- （具体问题，带原文引用 `CLAUDE.md:12-15`）

### 建议
- （具体怎么改，可直接执行的粒度）

### 引用证据
- `CLAUDE.md:12` 原文：...

---

## 2-8. （每维度同上结构）

---

## 9. 规则内容建议  🟢 / 🟡 / 🔴

### 基于项目实证的新规则候选

- **候选规则**："写 SQL 时 JOIN 必须用显式 INNER JOIN"
- **实证来源**：`journal.md:45`（4/23 坑了 - 隐式 JOIN 误笛卡尔）+ `journal.md:78`（4/28 坑了 - 同类问题）
- **建议位置**：`.claude/rules/sql.md`（paths: migrations/**/*.sql）
- **建议形式**：命令式 + why + 示例

---

## 总结 + 下一步

- 🔴 阻塞级：N 个
- 🟡 需改进：N 个
- 🟢 健康：N 个

**建议行动**（按优先级）：
1. （具体操作）

如同意上述建议，运行 `/project-setup apply` 让 Claude 按本报告改动。
```

每个维度必须给 🟢/🟡/🔴 颜色标 + 原文引用 + 可执行建议。模糊的"建议考虑优化"不合格，必须精确到 "把 `CLAUDE.md:23` 的 '可能考虑使用 TypeScript' 改成 'TypeScript 必须启用 strict'" 这种粒度。

---

## apply 子场景

### 本质

**用户看完 audit 报告决定改**。Claude 按报告里的"建议"项，基于 `references/` 标准执行改动。apply 不决定改什么（决定权在用户），只负责忠实执行 + 每步验证。

### 输入

**target_path**（可选，默认当前项目根，未给则直接跑，不主动问）、上一次 audit 报告路径或内容（用户粘进来或指向项目根 `audit-report-YYYY-MM-DD.md`）。

### 流程

**第一步：加载报告 + 和用户确认范围**。Read 最近的 audit 报告，把"建议"项逐条列给用户：

```
本次 audit 建议执行的改动：
[1] CLAUDE.md 瘦身：把 L23-L45 的错误码表迁到 .claude/memory/reference_api_errors.md
[2] 补 MEMORY.md 索引缺失的 3 条
[3] 把 lessons/cache.md 的"可复用规则"段抽到 .claude/rules/caching.md
[4] 新增 rule：写 SQL 时 JOIN 必须用显式 INNER JOIN（实证：journal.md:45 + 78）
...

请选择：全部接受 / 选择性接受（列号）/ 跳过
```

**不要默认全改**。用户没看清就"全接受"的后果是大量不可逆改动，明确的选择是心理缓冲。

**第二步：按 references 标准逐条执行**。apply 可执行的改动类型有两类 —— 一类是**改项目现有文件**（Edit / Write 改 CLAUDE.md / memory / rules / journal / gitignore），这类改动每条前必须 Read 对应 `references/*.md` 作标准；另一类是**从 skill 自身补文件到目标项目**（hook 层、preset、settings 骨架这类），这些文件的正典在 `${CLAUDE_SKILL_DIR}/assets/` 下，audit 建议"补 hook / 装 preset / 初始化 settings.local.json"时走这条路径。

两类改动对每条都走同一个循环：

- 第一类（改现有文件）：Read 对应 `references/*.md` → Edit / Write → Read 改后文件验证 → 汇报
- 第二类（从 assets/ 补文件）：Bash `cp` 对应文件到目标项目（hook 脚本拷到 `.claude/hooks/` 并 `chmod +x`、preset 拷到 `.claude/rules/`、settings.local.json.example 拷成 settings.local.json 并用 perl 替换 autoMemoryDirectory 占位为项目绝对路径）→ Read 验证文件到位 + 权限对 → 汇报

每条完成后等用户确认再推进下一条，不连续跑一串。

**第三步：同步 journal**。改完按 `journal.md` 标准追加一条到顶部：

```markdown
## {YYYY-MM-DD} 项目协作层整改

- **做了**：执行 /project-setup apply，按 {报告日期} audit 报告改 N 项
- **坑了**：-（或具体踩的坑）
- **学到**：（如果这次整改揭示了什么模式，记这里；没有写"-"）
- **决策**：逐条接受 vs 批量 | 因为 X | 替代方案是 Y
```

### 硬约束

- **读标准不凭记忆**：每条改动前 Read 对应 `references/*.md`
- **用户授权才动**：没授权不改
- **可逆性优先**：能小步改的不大步改，每步完成后汇报
- **拒绝超出报告范围**：用户说"顺便也把 docs/ 重组一下吧"超出了 audit 范围 → 建议"重跑一次 audit 让我判断"

---

## review 子场景

### 本质

**review 是规则层的小范围审查**，聚焦 CLAUDE.md + `.claude/rules/` 的规则质量。和 audit 的差别：audit 是全项目结构审查（8 个维度），review 只看规则 —— 更轻、更常用、适合日常维护。

目的：**让规则集随项目演化而不是只增不减**。项目跑几周后规则会出现重复、冲突、过期、本该升级到全局但还留在项目的情况。这些问题 audit 也能发现但粒度粗，review 专门对付这类。

### 输入

**target_path**（可选，默认当前项目根，未给则直接跑，不主动问）

### 执行流程

**第一步：读项目规则层**。Read CLAUDE.md 全文 + Read 所有 `.claude/rules/*.md`（按 frontmatter paths 分组心里标记）+ Bash 列 `~/.claude/rules/` 看有哪些全局规则（如果可访问）。

**第二步：Read references 作标准**。必读 `references/claudemd.md` 和 `references/rules.md`（review 不需要读其他 references，聚焦规则层）。

**第三步：扫 8 类问题**。每类带原文引用：

1. **重复规则**：CLAUDE.md 和 rules/ 里有没有同意思的规则（措辞不同但语义重合）→ 建议合并或删一处
2. **冲突规则**：两处规则说的不一致（A 处"必须 X"，B 处"X 可选"）→ 建议协调，模型遇冲突会随机跳到训练先验
3. **可合并的规则**：rules/ 下多份文件各写一条同主题规则 → 建议合并到一份（按主题聚合 > 按来源分散）
4. **CLAUDE.md 里的长规则**：超过 3 行、内容专门 → 建议迁 `.claude/rules/{主题}.md`，CLAUDE.md 留一行索引
5. **rules/ 里的短规则**：只有 1-2 行、通用性强 → 建议上升到 CLAUDE.md 项目硬规则段
6. **可升级到全局的规则**：某条规则在本项目稳定有效且**明显跨项目都适用**（不是项目特有业务）→ 建议迁 `~/.claude/rules/{主题}.md`，项目侧保留或删除
7. **过期规则**：讲述的场景已完全不存在（技术栈换了 / API 废弃 / 团队规范变了）→ 建议 archive（不直接删，保留历史）
8. **柔化词规则**：含"尽量 / 可能 / 建议 / 大概率 / 一般来说" → 给命令式重写版

### 输出格式

```markdown
# {项目名} 规则层 review（{YYYY-MM-DD}）

**路径**：$TARGET_PATH
**规则文件**：CLAUDE.md + .claude/rules/*.md（N 份）
**总评**：X 项重复 / Y 项冲突 / Z 项可合并 / ... / 规则层健康度（健康 / 一般 / 需整治）

---

## 1. 重复规则  🟢 / 🟡 / 🔴

- **发现**：`CLAUDE.md:23` "API 调用必须设超时" 和 `.claude/rules/api-handling.md:12` "所有外部 API 必须配超时时间" 是同一条
- **建议**：删 CLAUDE.md:23，保留 rules 版本（更详细且带 paths 作用域）

## 2-8. （每类同上格式）

---

## 总结 + 下一步

**建议行动**（按优先级）：
1. 解决 🔴 冲突规则（会导致模型行为随机）
2. 合并 🟡 重复规则
3. ...

如同意上述建议，可运行 `/project-setup apply` 让 Claude 按本 review 报告改动；或自己手动逐条改。
```

### 硬约束

- **只读**。review 不改文件。要改走 apply 或手动。
- **不扩展到 audit 范围**。用户要求"顺便看看 journal / memory / docs"时礼貌拒绝："review 聚焦规则层，其他维度走 /project-setup audit"
- **带原文引用**。每条发现必须 `文件:行号 + 原文片段`，没引用不发现

---

## 四条硬边界（所有子场景共用）

这四条是 skill 不变成"项目毒瘤"的保险。理解它们比背命令重要。

**init 目标路径非空 → 立即拒绝**。不自动覆盖、不备份、不合并。用户现有文件不可推测，擅自改不可逆。

**audit / review 只读**。禁止用 Write / Edit / Bash 改任何文件。audit / review 的价值是第三方视角诊断，自动改破坏这个定位。

**占位符替换只改 2 个明确占位**。`{PROJECT_NAME}` 和 `{一句话项目描述}` 之外的"智能替换"禁止 —— 自动填服务器 IP / 推断项目类型 / 加 boilerplate 几乎必错，用户会信任看似自动填的内容然后基于错信息决策。

**拒绝扩展到 migrate / clean / 删"垃圾"**。用户要求"自动清理"、"批量归档"时礼貌拒绝。"垃圾"语义模糊（eval 数据 / LLM 产物 / 爬虫数据误删不可恢复），skill 不承担模糊语义下的破坏性动作。

---

## 模板来源

`assets/` 是 skill 自带子目录（遵循 Anthropic 官方 skill 约定 —— bundled resources 放 assets 下），init 通过 `${CLAUDE_SKILL_DIR}/assets/` 拷。不依赖外部路径（没有 `~/project-template/` 也没有远程模板 repo）。修改模板直接改本 skill 目录下的 `assets/`，PR 时一次性更新。

---

## 与其他开源 skill 的关系

**skill-creator**（Anthropic 官方）：写单个 skill 的方法。本 skill 的"项目层标准" + skill-creator 的"skill 层写作"互补，可以一起用。

**Claude Code 内置 `/init`**：生成 CLAUDE.md 初稿。可先用内置 `/init` 再用本 skill `/project-setup audit` 看生成的骨架是否合规。
