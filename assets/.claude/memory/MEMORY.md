# MEMORY.md

## 项目事实（按需查阅）

<!-- Claude 在对话中自动维护。新增 memory 主题文件后**立即**在这里加索引行（索引和磁盘不一致 = Claude 永不读 / 读死链）。

格式：`- [标题](文件名) — 带可命中关键词的描述`

命名约定 `{type}_{topic}.md`：
- **reference** = 外部世界事实（服务器 / 第三方 API / 账号 / 错误码表）
- **project** = 项目内部事实（当前部署状态 / 数据库结构 / 迭代阶段）
- **user** = 用户本人事实（角色 / 偏好 / 关注领域）
- ~~feedback~~ 已废弃 —— 规则类内容进 `.claude/rules/{主题}.md`
- ~~decisions~~ 已废弃 —— 决策进 journal.md，决策产生的"当前状态"进 `project_*.md`

description 要塞具体关键词（"生产 PostgreSQL 连接串 / 只读副本 / 迁移命令 / S3 备份桶"），不要写"关于 X 的事情"—— 后者 Claude 命中不到。

---

通用参考示例（写完第一条真实索引后删除本段占位）：

- [数据库访问](reference_database.md) — 生产 PostgreSQL 连接串 / 只读副本 / 迁移命令 / S3 备份桶
- [支付网关错误码](reference_payment_errors.md) — INSUFFICIENT_FUNDS / CARD_DECLINED / RATE_LIMIT / 重试策略 / 幂等键机制
- [已部署组件](project_deployed_services.md) — auth-service v2.3 / 用户 API / 后台任务队列 / 最后部署时间
-->
