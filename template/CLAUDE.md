# {PROJECT_NAME}

{一句话项目描述}

**事实进 `.claude/memory/`，查 MEMORY.md 索引。本文件只放规则。**

---

## 跨 Session 协作（硬规则）

| 文件 | 存什么 | 何时读/写 |
|------|-------|----------|
| `CLAUDE.md` | 规则 + 索引（< 80 行）| 每次 session 自动加载 |
| `.claude/rules/*.md` | 长规则 / 按主题拆 / 可带 `paths:` 作用域 | 自动加载 |
| `journal.md` | 时间线进度、反思、待办 | **Session 开头读顶 3 条**；里程碑 / 结束时 append 顶部 |
| `.claude/memory/` | 事实（服务器 / 账号 / API / 命令）| MEMORY.md 前 200 行自动加载；主题文件按需读 |

**写入分层规则**：
- 事实（地址 / ID / URL / 命令 / 字段）→ `.claude/memory/{project,reference}_*.md`
- 用户纠正 / 严重错误：短（1-3 行）→ 本 CLAUDE.md；长 → `.claude/rules/{主题}.md`。**禁止 `feedback_*.md`**
- 进度 / 反思 / 待办 → `journal.md`
- 案例叙事（复杂反转 / 多步踩坑）→ `lessons/`

---

## 项目硬规则

<!-- 项目特定规则写这里（删除本占位注释）。例如：
- 某个命令必须这样调
- 某个文件禁止直接改
- 某个 API 有特殊错误码规则
-->

---

## 关键资源索引

- **事实类**：`.claude/memory/MEMORY.md`（索引，再按主题读对应文件）
- **项目规则**：`.claude/rules/*.md`（自动加载）
- **跨项目规则**：`~/.claude/rules/`（全局，本项目不重复写）
- **跨项目参考**：`~/.claude/reference/`（模型 / 密钥 / 路径 / eval 方法论等）
- **复杂案例**：`lessons/`

---

## 待做

<!-- todo 放这里，完成勾掉。跨天的留着，只删真正完成的 -->

- [ ] 改完 README / CLAUDE.md / journal.md 里的 `{PROJECT_NAME}` 占位
- [ ] 建 `.claude/settings.local.json`（从 `.example` 复制，改绝对路径）
