# .claude/memory/ 写作标准

Claude Code 自带的 auto-memory 系统。Claude 在对话中遇到值得持久化的事实时，自己写入这里。本 spec 定义：**目录位置 / 文件命名 / frontmatter / MEMORY.md 索引规则 / 哪些东西该进 / 哪些该去别处**。

---

## 应该长什么样

### 目录结构

```
.claude/memory/
├── MEMORY.md                  # 索引，前 200 行 / 25KB 自动加载（先到者）
├── reference_{topic}.md       # 外部事实（服务器、API、账号、密钥指针）
├── project_{topic}.md         # 项目内事实（决策记录、已部署组件、当前状态）
├── user_{topic}.md            # 用户信息（角色、偏好、关注点）
└── archive/                   # 废弃 memory 归档，不删
    └── .gitkeep
```

### 文件命名：`{type}_{topic}.md`

- **type**：`reference` / `project` / `user` 三选一
- **topic**：小写、下划线分隔、带关键词（`server_access` / `kox_api_rules` / `email_channel_id_resolution`）
- **禁止的 type**：~~`feedback`~~（用户纠正改进规则类用 `.claude/rules/{主题}.md`）、~~`decisions`~~（决策合并进 journal + `project_*.md`）

### Frontmatter（必须）

```yaml
---
name: 人类可读的标题
description: 一句话，带命中关键词（"SSH / 端口 / 部署路径"），决定 Claude 命中率
type: reference | project | user
---
```

`description` 是 Claude 判相关性的唯一依据。写"关于 X 的事情"是无效的 —— Claude 读完还是不知道什么时候用它。**描述里塞具体关键词**。

### MEMORY.md 索引

```markdown
# MEMORY.md

## 项目事实（按需查阅）

- [服务器访问](reference_server_access.md) — IP / SSH 密码 / Gateway 端口 / 部署路径
- [API 错误码](reference_api_errors.md) — 10001-10004 / 50002 / 空壳账号诊断
- [已部署组件](project_deployed_components.md) — 4 个 skill 清单 / 接口数 / 最后部署时间
```

每条一行，`[标题](文件名) — 带关键词的钩子`。总长度控制到 **前 200 行 / 25KB** 以内，因为这个上限一过自动加载就截断。

### autoMemoryDirectory 配置（关键）

在 `.claude/settings.local.json` 里：

```json
{
  "autoMemoryDirectory": "/绝对/路径/到项目/.claude/memory"
}
```

**必须绝对路径**。相对路径会因子目录启动 cwd 变化而分叉，中文路径在 Claude Code 编码规则变动时会分桶成幽灵目录。

---

## 为什么这样

### 为什么扁平而不是多级子目录

按主题拆子目录（`memory/api/`、`memory/server/`）听起来整洁，实际让 Claude 多一层查找成本，收益为 0。`{type}_{topic}.md` 命名已经自带分类信息，排序就等于分组。

### 为什么 description 要带关键词

MEMORY.md 前 200 行自动加载 ≠ 所有 memory 自动加载。主题文件（reference_server_access.md 等）**默认不加载**，Claude 读 MEMORY.md 的 description 决定要不要按需读。description 模糊 = Claude 永远命中不到 = 事实上没写。

**验证方法**：把 description 给陌生人看，他能猜出这个 memory 适用什么场景吗？不能就重写。

### 为什么禁止 `feedback_*.md`

feedback 类 memory 的问题：
- 零散写一堆规则等价于一本没目录的笔记 —— Claude 加载了不知道什么时候用
- 规则性内容应该**按主题聚合**，不是按"这是用户某次说的"分散
- rules/ 的 `paths:` 作用域机制比 memory 更精准（"写 skill 时触发" vs "可能会用到"）

用户纠正出的规则：
- 短（1-3 行）→ CLAUDE.md 项目硬规则段
- 长或多条 → `.claude/rules/{主题}.md`

### 为什么索引和磁盘必须一致

Claude 启动时只读 MEMORY.md 前 200 行，然后通过索引的 description 判定是否按需读主题文件。**索引里没写 = 事实上不存在**。反过来，索引里写了但文件不存在 = Claude 按建议读死链接。

每次新增 memory 后立即同步索引，是这个系统能活下去的唯一条件。

---

## 判断标准（audit 时问的问题）

1. **autoMemoryDirectory 配置正确吗**：值是绝对路径吗？路径指向的目录存在吗？是 `.claude/memory/` 吗？
2. **MEMORY.md 索引 ↔ 磁盘一致性**：orphan（磁盘有 / 索引无）= Claude 永不读；dead link（索引有 / 磁盘无）= 读会失败
3. **命名规范**：所有主题文件都是 `{type}_{topic}.md` 吗？有没有混进随意命名的文件？
4. **禁用 type**：有 `feedback_*.md` 吗？有 `decisions.md`（独立在 memory/ 下）吗？应迁走
5. **description 质量**：每条索引描述都带具体关键词吗？还是"关于 X 的事情"这种无效描述？
6. **frontmatter 完整性**：每个主题文件都有 name/description/type 三字段吗？
7. **过期 memory**：有没有明显过时的（比如记录了某版本 API，现已完全不用）？这类该 archive
8. **规则 vs 事实混入**：memory 里有没有条目是"规则 / 做法"而不是"事实"？应迁到 rules/ 或 CLAUDE.md

审查要带具体文件名 + 具体问题点，不要只说"memory 不合规"。

---

## 反模式

- **用 `feedback_*.md` 记规则**：已废弃，迁到 `.claude/rules/`
- **独立 `decisions.md`**：ADR 对个人项目是过度设计，决策合并进 journal + `project_*.md`
- **相对路径 autoMemoryDirectory**：`"./.claude/memory"` 看着好，子目录启动会分叉
- **description 写"关于 X 的事情"**：Claude 无法命中，等于没写
- **大事实堆一个文件**：`project_all_state.md` 含服务器 / API / 账号 / 部署全部信息 —— 一次读爆 context。按主题拆
- **把 memory 当 journal 用**：记时间线进度（"今天部署了 X"）进 journal，不进 memory
- **把 memory 当 docs 用**：长篇教程 / 人读文档进 docs/，memory 只放 Claude 按需查的事实

---

## 示例

### 好的 memory 文件

`reference_server_access.md`：

```markdown
---
name: 服务器 SSH 访问
description: 主服务器 45.78.192.23 SSH 连接、sshpass 密码、Gateway 端口 18789、skill 部署路径
type: reference
---

## SSH

- IP: 45.78.192.23
- User: admin
- Password: (查 ~/.claude/reference/keys.md)
- 推荐: `sshpass -p <pass> ssh admin@45.78.192.23`

## Gateway

- 端口 18789，HTTP 入口
- 重启命令：`sudo systemctl restart gateway`

## 部署路径

- /opt/skills/{skill-name}/
```

description 含 4 个关键词（IP、sshpass、端口、部署路径），Claude 在问 "怎么连服务器" / "skill 部署到哪" 时都能命中。

### 好的 MEMORY.md 索引段

```markdown
- [KOX API 错误码](reference_kox_api_rules.md) — 10001-10004 / 50002 子码 / 采集 vs 收录 / task_status / 空壳账号诊断
```

钩子里塞了 5 个可能被用户问起的具体词，命中面广。

### 坏的 description

```yaml
description: 一些关于 API 的记录
```

Claude 不知道这个 memory 管哪些接口、遇到错误码能不能查 —— 永远不读。

### 坏的命名

```
.claude/memory/
├── server.md           # 没 type 前缀
├── feedback_xxx.md     # 禁用 type
├── 2026-04-24 决策.md  # 带日期 / 中文 / 空格
```
