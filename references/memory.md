# .claude/memory/ 写作标准

`.claude/memory/` 是整套协作层里**所有事实的家**。在分工里，CLAUDE.md 放规则（每次加载）、`rules/` 放长规则（自动或按场景加载）、`journal.md` 放时间线（session 开头读顶部几条）—— 唯独事实类内容（地址 / 账号 / API / 错误码 / 字段 / 命令 / 已部署组件状态）没有其他位置，全部归 memory。

memory 的加载机制和其他文件不同：`MEMORY.md` 作为索引**前 200 行 / 25KB 自动加载**（先到者，这是 Claude Code 系统硬约束，不是我选的阈值），主题文件（`reference_*.md` / `project_*.md` / `user_*.md`）默认不加载，Claude 根据索引里的描述判断相关性，需要时按需 Read。理解这个"索引自动 + 主题按需"的分工，后面所有规则都能推出来。

---

## 只放事实，不放规则也不放叙事

事实 = Claude 在对话中可能要用、但不是每次都用的数据。"生产 DB 的连接串"是事实，"改 migration 前必须先跑 dry-run"是规则。

规则的家在 `rules/` 或 CLAUDE.md —— 它们有自动加载机制，能在正确时机触发。塞进 memory 意味着：Claude 看到索引里的描述不确定要不要读（规则不像事实有明确"查询时机"），多半不读 → 规则失效。你可能觉得"反正都是持久化内容，放一起方便"，但方便的是你写的时候；代价是 Claude 读的时候找不到 —— 每类内容有各自的加载时机，错位放置 = 该加载时没加载 / 不该加载时加载。

叙事（"上次重构的过程"）的家在 `lessons/`，时间线（"今天部署了 X"）的家在 `journal.md`。它们都不是"按需查"的事实，是"按顺序读 / 按故事读"的内容，塞进 memory 的按需机制里 Claude 不知道什么时候读。

判断一条内容属不属于 memory，问：*Claude 在未来某个具体对话里，会明确去"查"这个信息吗？* 会 → 是事实，进 memory；不会（它是做事方式 / 时间线 / 故事）→ 走别家。

---

## description 是命中钩子，不是文件简介

索引里每条 description 决定 Claude 会不会在对话中按需读对应主题文件 —— 这是**唯一**判据，不是文件名也不是正文。写"关于 API 的一些信息"这种概括性描述，Claude 读完不知道什么场景该读它，永远命中不到。

有效的 description 塞**具体关键词**：文件里会出现的函数名 / 错误码 / 表名 / 命令 / API 路径。比如 "生产 PostgreSQL 连接串 / 只读副本 / 迁移命令 / S3 备份桶位置" 一行，Claude 在问"怎么连库"、"怎么回滚迁移"、"备份在哪"时都能命中。

验证方法：把 description 给陌生人看，他能不能猜出"什么场景该读这个文件"？不能就重写。这条测试比任何抽象标准都直接。

你可能觉得 description 写简洁些更专业，但这里"简洁"等同于"不可命中"。宁可长一点堆关键词，不要短而空 —— description 不吃每次对话的预算（只在 MEMORY.md 索引里占一行），命中收益远大于这一行长度的代价。

---

## 命名自带分类，不用子目录

`{type}_{topic}.md` 里的 type（`reference` / `project` / `user` 三选一）已经做了分类：排序后自然聚合，所有 `reference_*` 在一起，所有 `project_*` 在一起。再建 `memory/api/`、`memory/server/` 子目录让 Claude 查找多一层路径，收益为 0。

三个 type 的边界：**reference** 是外部世界的事实（服务器 / 第三方 API / 账号信息 / 错误码表）；**project** 是项目内部的事实（已部署组件状态 / 当前数据库结构 / 迭代阶段）；**user** 是用户本人的事实（角色 / 偏好 / 关注领域）。

你可能想再加 `feedback_` 或 `decisions_` 类 —— 这两个已明确废弃，下面单独讲。

---

## 废弃的两类：feedback_ 和独立 decisions.md

**feedback_*.md** 废弃原因两条。第一，规则性内容要按**主题聚合**不是按"这是用户某次说的"分散 —— 散着写等于 Claude 要拼多个 feedback 文件才凑齐一组规则，大概率拼不齐。第二，`rules/` 有 `paths:` 作用域机制（"写 skill 时触发"、"改 migration 时触发"），比 memory 的"可能会用到"精准。

用户纠正出的规则：短的（1-3 行）进 CLAUDE.md 项目硬规则段，长或多条进 `.claude/rules/{主题}.md`。memory 不吸收规则。

**独立 decisions.md**（ADR 风格）废弃原因：ADR 对个人项目和小团队是过度设计。决策本身是时间线信息，家在 journal 的"决策"段；决策产生的"当前状态"（比如"最终选了 FastAPI"）进 `project_*.md` 作为事实。两处都有家，不需要第三个位置。

你可能觉得 ADR 看起来正式专业，但正式感不是标准 —— 能找到家的内容不需要新建类别，新建 = 让写入分层变模糊 = 下次又该放哪用户自己都不确定。

---

## 索引必须和磁盘一致

"索引里没写 = 事实上不存在"。Claude 启动时只读 MEMORY.md 前 200 行，主题文件通过索引的 description 判定是否按需读 —— 索引里没写的文件 Claude 永远不会发现。反过来索引里写了但磁盘没文件 = Claude 按建议去读碰到死链。

每次新增 memory 后**立即**同步索引。这不是"建议流程"，是**系统能工作的唯一条件** —— 丢了索引同步，memory 就退化成"Claude 写了但不知道存在的一堆孤岛文件"。

---

## autoMemoryDirectory 必须绝对路径

在 `.claude/settings.local.json` 里：

```json
{ "autoMemoryDirectory": "/绝对/路径/到项目/.claude/memory" }
```

相对路径（`./.claude/memory`）会因为 cwd 变化分叉 —— 在子目录启动 session 时指向错误位置；中文路径 / 含空格路径在编码规则变动时会分桶到幽灵目录。这两类故障都是"能跑但找不到东西"的静默失败，比直接报错更难排查。绝对路径是唯一稳定配置。

init 时就写死实际路径，clone 项目的人要改成自己机器的绝对路径（所以 `settings.local.json` 本身必须被 `.gitignore`，这块 `gitignore.md` 里讲）。

---

## 审视一份 memory

核心判断不是对照清单扫，而是读完后问：**这套 memory 能不能让 Claude 在未来对话中准确命中并读到正确的事实**。不能的地方就是要改的地方。

具体怎么表现为"不能"？autoMemoryDirectory 不是绝对路径或指向目录不存在 → 整套 memory 系统没在工作（最严重、静默故障，先查这个）。索引和磁盘不一致 → 磁盘有索引无（orphan）= Claude 永不读，索引有磁盘无（dead link）= 读死链 —— 这两类都是信任崩塌。description 模糊 → 永不命中。命名不符 `{type}_{topic}.md` → 混进随意命名的文件说明写入流程没建立、后续还会继续混乱。frontmatter（name / description / type）缺失 → 影响 Claude 相关性判断。有 `feedback_*.md` 或独立 `decisions.md` → 按上面讲的迁走。有明显过期内容（记录某版本 API 现已完全不用）→ archive 掉不删，保留历史。

memory 健康取决于**写入流程是否成熟**。写入流程规定了"写 memory 必同步索引、用 `{type}_{topic}.md` 命名、description 带关键词" —— 流程跑通整套就活，任一环节破就退化成孤岛。审视 memory 本质是在审视写入流程。

---

## 反面长什么样

最常见的失败是**把 memory 当别的文件用**。共同根因是没把"事实"和"规则 / 叙事 / 文档"的边界想清楚。

**当 rules 用**：记"做法"（"X 时必须做 Y"）。规则要在触发时机自动加载，memory 是按需查 —— 放错位置规则不会在需要时激活。

**当 journal 用**：记时间线进度（"今天部署 X、明天改 Y"）。时间线要按顺序读，memory 是按需查 —— Claude 不会因为看到"今天部署了"就去读 memory 里的所有历史。

**当 docs 用**：写长篇教程 / PRD / 完整架构解释。这些是给人读的，塞进 memory 会让 Claude 按需读时加载一大段非事实内容浪费 context。

**大事实堆一个文件**（`project_all_state.md` 含服务器 / API / 账号 / 部署全部信息）—— 一次读爆 context，还让 description 难写（涵盖太多关键词就不精准）。按主题拆，每个文件独立可命中。

这些失败的共同特征是**没把 memory 的加载机制（索引自动 + 主题按需）想清楚**。想清楚了自然知道什么该进、什么该走别家。

---

## 示例

### 好的主题文件

`reference_database.md`：

```markdown
---
name: 数据库访问
description: 生产 PostgreSQL 连接串、只读副本、迁移命令、备份 S3 桶位置
type: reference
---

## 主库

- Host: `db.internal.example.com`
- Port: 5432
- User: `app_prod`（密码查 1Password "prod-db"）
- SSL 必须开（ca 证书在 `~/.postgresql/root.crt`）

## 只读副本

- Host: `db-ro.internal.example.com`
- 只用于报表 / 数据导出，延迟 < 5s

## 迁移

- 项目根执行：`alembic upgrade head`
- 回滚：`alembic downgrade -1`

## 备份

- S3 桶：`s3://company-db-backup/prod/`
- 每日 03:00 UTC 自动备份
```

description 带 4 个关键词，Claude 在多种询问场景都能命中。正文按小节拆，每节独立完整。

### 好的索引条目

```markdown
- [支付网关错误码](reference_payment_errors.md) — INSUFFICIENT_FUNDS / CARD_DECLINED / RATE_LIMIT_EXCEEDED / 重试策略 / 幂等键机制
```

钩子里塞了 5 个可能被问起的具体词，命中面广。

### 坏的 description

```yaml
description: 一些关于 API 的记录
```

Claude 不知道这个 memory 管哪些接口 / 遇到错误码能不能查 —— 永远不读。
