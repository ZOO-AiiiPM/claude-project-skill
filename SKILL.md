---
name: project-setup
description: >
  Claude Code 项目骨架 + 深度审查 + 按标准改造。三个子场景：
  ① init — 用 template/ 骨架建新项目（CLAUDE.md / journal.md / .claude/memory+rules+hooks / lessons / docs / workspace 全套），填占位符 + 配 autoMemoryDirectory + 预置 journal 提醒 hook。
  ② audit — AI 驱动的深度审查，Claude 读 references/ 标准 + 读项目内容做主观判断，出带原文引用的诊断报告（不改文件）。
  ③ apply — 用户批准审查报告后，Claude 按 references/ 标准具体改项目。

  用户说以下任一内容时立刻触发：
  "初始化新项目"、"建新项目"、"新项目起手"、"帮我建个项目"、"从模板创建项目"、
  "铺项目骨架"、"init 项目"、"新项目要怎么搞"、
  "审查项目"、"audit 项目"、"项目健康检查"、"项目结构对不对"、"深度审查项目"、"项目规不规范"、
  "按标准改项目"、"应用审查建议"、"apply 改造"。
  即使用户只是随口说"建个项目"或"扫一下这个项目"也要触发。

user-invocable: true
argument-hint: [init <name> <desc> <abs_path> | audit [path] | apply [path]]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# project-setup — 项目结构脚手架、AI 深度审查、按标准改造

这个 skill 的产物是**一套项目协作标准**（记在 `references/` 的 8 份 spec 里），围绕它提供三件配套：

- **init** — 用 `template/` 建新项目，一次到位符合标准
- **audit** — Claude 读项目 + 读 `references/` → **主观判断** → 给带原文引用的深度报告（不改文件）
- **apply** — 用户批准审查结论后，Claude 按 `references/` 真正改项目

标准本身定义了"合格的 Claude Code 项目长什么样"。三件配套都围绕同一份标准跑，保证 init 出来的项目和 audit 判断的标准一致、apply 改完后的样子也在这个标准下。

---

## 用户输入

$ARGUMENTS

---

## 子场景路由

按用户输入判断：

- 含 "init / 建 / 初始化 / 新项目 / 从模板" → 走 [init](#init-子场景)
- 含 "audit / 审查 / 扫 / 规范不规范 / 健康检查" → 走 [audit](#audit-子场景)
- 含 "apply / 按建议改 / 接受报告 / 应用改动" → 走 [apply](#apply-子场景)

拿不准时直接问用户 "你是想建新项目、审视已有项目，还是按上次 audit 的报告改项目？"，不要猜。

---

## 标准来源（references/）

所有三个子场景的**判断依据**都在这 8 份 spec 里。init 按它们建、audit 按它们比、apply 按它们改。每份 spec 结构统一：应该长什么样 / 为什么这样 / 判断标准 / 反模式 / 示例。

| Spec | 管什么 |
|------|-------|
| [claudemd-spec.md](references/claudemd-spec.md) | `CLAUDE.md` 行数 / 段 / 规则 vs 事实边界 |
| [journal-spec.md](references/journal-spec.md) | `journal.md` 倒序 / 三段格式 / 活跃度阈值 |
| [memory-spec.md](references/memory-spec.md) | `.claude/memory/` 命名 / frontmatter / 索引一致性 / autoMemoryDirectory |
| [rules-spec.md](references/rules-spec.md) | `.claude/rules/` 命令式 / paths 作用域 / 和全局 rules 分工 |
| [lessons-spec.md](references/lessons-spec.md) | `lessons/` 叙事标准 / 蒸馏链位置 / 触发阈值 |
| [docs-spec.md](references/docs-spec.md) | `docs/` 人读文档 / 编号 / archive |
| [workspace-spec.md](references/workspace-spec.md) | `workspace/` 临时产物 / gitignore 覆盖 |
| [gitignore-spec.md](references/gitignore-spec.md) | `.gitignore` 必须段 / memory 白名单 / 敏感项 |

**用这些 spec 的方式**：在 audit / apply 前按需 Read 对应的 spec，不要凭记忆判断 —— 标准可能随项目演化，spec 才是权威。

---

## init 子场景

### 输入

三项必须从用户请求提取，缺一就问，不编造默认值：

- **project_name** — 填入 `{PROJECT_NAME}` 占位
- **description** — 填入 `{一句话项目描述}` 占位
- **target_path** — **绝对路径**（相对路径受 cwd 影响不可预测）

### 执行步骤

#### 1. 校验目标路径

```bash
[[ "$TARGET_PATH" = /* ]] || { echo "错误：target_path 必须绝对路径"; exit 1; }
if [ -e "$TARGET_PATH" ] && [ -n "$(ls -A "$TARGET_PATH" 2>/dev/null)" ]; then
  echo "错误：目标路径已存在且非空：$TARGET_PATH"
  echo "不自动覆盖。请用户决定：换路径 / 手动清空 / 换子路径"
  exit 1
fi
```

**硬规则**：目标非空立即拒绝。不合并、不覆盖、不备份。

#### 2. 拷 template 骨架

用官方 `${CLAUDE_SKILL_DIR}` 指向本 skill 目录：

```bash
mkdir -p "$TARGET_PATH"
cp -R "${CLAUDE_SKILL_DIR}/template"/. "$TARGET_PATH/"
```

skill 自带 `template/` 子目录，不依赖 `~/project-template/` 或远程仓库。

#### 3. 替换占位符

**只替换这 2 个占位**。不做"智能推断"（服务器 IP / 项目类型 / boilerplate 代码都禁止自动填）：

```bash
cd "$TARGET_PATH"
for f in README.md CLAUDE.md journal.md; do
  [ -f "$f" ] && perl -i -pe "s/\{PROJECT_NAME\}/$PROJECT_NAME/g; s/\{一句话项目描述\}/$DESCRIPTION/g" "$f"
done
```

`perl` 而不是 `sed`：macOS / Linux 的 `sed -i` 参数行为不一致，perl 跨平台。

#### 4. 配 autoMemoryDirectory

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
perl -i -pe "s|/绝对路径/到项目/\.claude/memory|$TARGET_PATH/.claude/memory|g" .claude/settings.local.json
```

验证：`grep autoMemoryDirectory .claude/settings.local.json` 显示实际绝对路径。

#### 5. git init（如果不在 repo 内）

```bash
if ! git rev-parse --show-toplevel > /dev/null 2>&1; then
  git init -b main && git add . && git commit -m "chore: 从 project-template 初始化"
fi
```

已在 repo 里（monorepo 子目录）**不要**再 `git init` —— 会在子目录建独立 repo。

#### 6. HTML 占位注释保留

`<!-- 删除本段占位 -->` 默认不删 —— 作为用户参考格式用。用户写完第一条 journal / 项目硬规则后自己手动删。

#### 7. 验证 + 告诉用户下一步

```
✓ 项目已初始化：{TARGET_PATH}

下一步：
1. 打开 CLAUDE.md 的"项目硬规则"段，填具体规则
2. 第一次有实质进展后给 journal.md 追加第一条
3. 推 GitHub：gh repo create <org>/<name> --source=. --public --push
4. 不要 5 轮 journal 提醒 hook 就删 .claude/settings.local.json 里的 hooks 段
5. 新开 Claude session，验证 CLAUDE.md 硬规则自动加载
```

---

## audit 子场景

**这是 AI 驱动的深度审查，不是文件名检查脚本**。Claude 要真读项目内容，按 `references/` 的标准做**主观判断**，给原文引用的证据。

### 输入

- **target_path**（可选，默认 `$(pwd)`）

### 执行流程

#### 1. 基础扫描（机械确认项目存在什么）

```bash
cd "$TARGET_PATH"
# 列出实际存在的文件，供后续精读决策
ls -la .
[ -d .claude ] && ls -la .claude/
[ -d .claude/memory ] && ls .claude/memory/
[ -d .claude/rules ] && ls .claude/rules/
[ -d lessons ] && ls lessons/
[ -d docs ] && ls docs/
wc -l CLAUDE.md journal.md 2>/dev/null
```

这一步**只是告诉 Claude"项目里实际有什么"**，不做判断。判断在下一步。

#### 2. 逐维度深度审视（AI 判断核心）

按下面 8 个维度一个个做。**每个维度都要 Read `references/` 对应 spec 和项目对应文件，带原文行号引用**：

##### 2.1 CLAUDE.md 规则质量

- Read `references/claudemd-spec.md` 作标准
- Read 项目 `CLAUDE.md`
- 判断：行数？段完整性？有没有规则 vs 事实混入？柔化词有几个？索引的路径都真实存在吗（用 Glob 验证）？待做时效？占位符残留？
- 输出：具体条款的原文引用（带行号），说明为什么它违反了 spec 的哪条

##### 2.2 journal 活跃度 + 模式识别

- Read `references/journal-spec.md`
- Read 项目 `journal.md`（至少读前 150 行覆盖最近条目）
- 判断：顶部条目多久前？倒序对吗？三段式完整吗？真实性如何（有没有凑数条目）？**最重要的**：最近 7-14 天的"坑了"字段里有没有**重复出现的词**？有 = 该抽成 rule 或 lesson
- 输出：活跃度评级，指出具体该蒸馏成 rule 的重复模式

##### 2.3 MEMORY 索引 ↔ 磁盘一致性 + description 质量

- Read `references/memory-spec.md`
- Bash 列磁盘：`ls .claude/memory/*.md | grep -v MEMORY.md | xargs -n1 basename`
- Read `.claude/memory/MEMORY.md` 取索引
- 判断：orphan（磁盘有索引无）/ dead（索引有磁盘无）？description 是否带具体关键词（还是"关于 X 的事情"这种无效描述）？有没有禁用的 `feedback_*.md` 或独立的 `decisions.md`？
- 输出：具体 orphan 文件名 + description 薄弱的条目 + 建议的重写描述

##### 2.4 .claude/rules/ 效力

- Read `references/rules-spec.md`
- Read 项目每份 `.claude/rules/*.md`
- 判断：命令式 vs 原则式？有触发锚点吗？解释 why 吗？paths 作用域合理吗？和 `~/.claude/rules/` 有没有重复？
- 输出：具体规则的原文 + 该怎么改（给重写示例）

##### 2.5 lessons/ 蒸馏效率

- Read `references/lessons-spec.md`
- 逐份 Read `lessons/*.md`
- 判断：每份 lesson 结尾有"可复用规则"段吗？规则有没有抽到 `.claude/rules/` 去？有单薄到该降级为 journal 的吗？有过长该拆的吗？命名能 5 秒猜出主题吗？
- 输出：哪些 lesson 该抽 rule / 哪些该合并 / 哪些该 archive

##### 2.6 docs/ 和 workspace/ 纪律

- Read `references/docs-spec.md` / `references/workspace-spec.md`
- 扫 `docs/` 和 `workspace/`
- 判断：docs 有没有误放 Claude 规则？workspace 有没有误放耗时产物（eval 结果 / LLM 生成）？docs 归档纪律？编号一致性？
- 输出：该挪的文件列表 + 目标位置

##### 2.7 .gitignore 配置闭环

- Read `references/gitignore-spec.md`
- Read 项目 `.gitignore`
- 判断：memory 白名单完整吗？`settings.local.json` 忽略吗？`.env` 覆盖吗？`workspace/tmp/` 吗？
- 输出：缺失的必须项 + 敏感泄漏风险

##### 2.8 hooks / autoMemoryDirectory 配置

- Read `.claude/settings.local.json`（如果存在）
- 判断：`autoMemoryDirectory` 是绝对路径吗？指向的目录存在吗？hooks 配置引用的脚本 `.claude/hooks/*.sh` 都存在且 `+x`？
- 输出：配置链断点

#### 3. 输出格式

固定 markdown 结构，便于不同时间 audit 对比：

```markdown
# {项目名} 深度审查报告（{YYYY-MM-DD}）

**路径**：$TARGET_PATH
**基于标准**：references/*.md（8 份 spec）
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

## 2. journal 活跃度 + 模式识别  🟢 / 🟡 / 🔴

（同上结构）

...

## 8. hooks / autoMemoryDirectory  🟢 / 🟡 / 🔴

---

## 总结 + 下一步

- 🔴 阻塞级问题：N 个
- 🟡 需改进：N 个
- 🟢 健康：N 个

**建议行动**（按优先级）：
1. （具体操作）
2. ...

如同意上述建议，可以运行 `/project-setup apply` 让 Claude 按本报告改动。
```

**每个维度都要给 🟢/🟡/🔴 颜色标、原文引用、可执行的建议**。模糊的"建议考虑优化"不合格，必须是"把 CLAUDE.md:23 的 '可能考虑使用 TypeScript' 改成 'TypeScript 必须启用 strict'"这种粒度。

### audit 硬约束

- **只读**。禁止用 Write / Edit / Bash mv/cp/rm 改目标项目任何文件
- **基于原文**。不许说"我看到"或"我印象中"—— 每个判断都带文件路径 + 行号 + 原文片段
- **基于 references/**。判断依据必须是 `references/*.md` 里的条款，不能凭记忆编标准
- **不扩展**。用户要求 "顺便清一下废弃文件" / "自动迁移" 时礼貌拒绝："audit 只给报告，你自己决定改不改，或用 `/project-setup apply`"

---

## apply 子场景

**用户看完 audit 报告后决定改**。Claude 按报告里具体的"建议"项，按 `references/` 标准执行改动。

### 输入

- **target_path**（可选，默认 `$(pwd)`）
- 上一次 audit 报告路径或报告内容（用户粘给 Claude 或项目根 `audit-report-YYYY-MM-DD.md`）

### 执行流程

#### 1. 加载报告 + 和用户确认改动范围

- Read 最近的 audit 报告
- 把报告里的"建议"项逐条列给用户：
  ```
  建议执行的改动：
  [1] CLAUDE.md 瘦身：把 L23-L45 的错误码表迁到 .claude/memory/reference_api_errors.md
  [2] 补 MEMORY.md 索引缺失的 3 条
  [3] 把 lesson/xxx.md 的规则抽到 .claude/rules/...
  ...
  ```
- 问用户：**全部接受 / 选择性接受（列号）/ 跳过**

不要默认全改。用户没看清就同意的后果是大量不可逆改动。

#### 2. 按 references/ 标准逐条执行

每条改动都要：

- Read 对应 references/*-spec.md（例如改 CLAUDE.md 前 Read `claudemd-spec.md`）
- 做改动（Edit / Write / Bash）
- 改完后立即验证（Read 改后文件 / 跑 Glob / 看行数）
- 向用户报告本条完成，等确认前不推进

#### 3. 改完同步 journal

按 `journal-spec.md` 格式追加一条到 `journal.md` 顶部：

```markdown
## {YYYY-MM-DD} 项目协作层整改

- **做了**：执行 /project-setup apply，按 {报告日期} audit 报告改动 N 项
- **坑了**：-（或具体坑）
- **学到**：（如果这次整改揭示了什么模式，记这里；没有就写 -）
- **决策**：逐条接受 vs 批量 | 因为 X | 替代方案是 Y
```

### apply 硬约束

- **读 spec 不凭记忆**：每条改动都要 Read 对应 spec 文件确认标准
- **用户逐条或批量授权**：没授权不改
- **可逆性优先**：能小步改的不大步改，每步完成后汇报
- **拒绝超出报告范围的扩展**：用户说"顺便也把 docs/ 重组一下吧"超出了 audit 范围 → 建议先重跑 audit 再决定

---

## 4 条硬边界（三场景都适用）

1. **init 目标路径非空 → 立即拒绝**。不自动覆盖、不备份、不合并。原因：用户现有文件不可推测是什么，擅自改动不可逆。

2. **audit 只读**。禁止用 Write / Edit / Bash 改任何文件。原因：audit 的价值是"第三方视角诊断"，自动改会破坏这个定位。要改走 apply 场景，经用户批准。

3. **占位符替换只改 2 个明确占位**。`{PROJECT_NAME}` 和 `{一句话项目描述}` 之外的"智能替换"禁止做（自动填服务器 IP、推断项目类型、加 boilerplate 都禁止）。原因：这类推断几乎必错，用户看到"自动填的"东西会信任它，基于错信息决策。

4. **拒绝扩展到 migrate / clean / 删"垃圾"**。要求"自动清理"、"把 docs 里过期的归档"时，礼貌拒绝："超出 skill 职责，audit 只报告差异，apply 只执行审查报告里的建议项。批量删 / 迁移你自己来，或把需求加进下一轮 audit 让我判断。"原因：这些动作语义模糊（什么是"垃圾"？），用户花时间产出的文件（eval 数据、LLM 产物、爬虫数据）误删不可恢复。

---

## 模板来源

`template/` 是 skill 自带子目录（和 `references/` / SKILL.md 并列），init 通过 `${CLAUDE_SKILL_DIR}/template/` 拷。**不再依赖外部路径**（`~/project-template/` 或远程模板 repo）。修改模板就直接改本 skill 目录下的 `template/`，提 PR 时一次性更新。

---

## 与其他开源 skill 的关系

- **skill-creator**：本 skill 的"写作标准"（references/）和 skill-creator 的"skill 创作方法"互补 —— 本 skill 负责"项目协作层该怎么建"，skill-creator 负责"单个 skill 该怎么写"。可以一起用。
- **init（Claude Code 内置）**：内置 `/init` 是生成 CLAUDE.md 初稿，本 skill 的 init 是完整骨架（含 journal / memory / rules / lessons / hooks 等整套）。可以先用内置 init 再用本 skill audit。
