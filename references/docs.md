# docs/ 写作标准

给**人类读者**看的文档目录。和 `.claude/` 里所有给 Claude 看的文件最大区别：docs 是**产品 / 研究 / 交接材料**，不追求让 Claude 高效定位，追求让人能读懂。

---

## 应该长什么样

### 目录结构

```
docs/
├── 01-调研报告.md           # 编号前缀保证阅读顺序
├── 02-PRD.md
├── 03-架构设计.md
├── 04-使用指南.md
├── 05-项目进展总结.md
├── archive/                 # 过期文档不删，迁这里
│   └── old-spec-v1.md
└── .gitkeep
```

### 命名约定

- **编号前缀**（`01-` / `02-`）：给相关文档排序，一眼看出阅读顺序
- **中文标题 OK**：这些是人读的，中文比英文自然
- **避免时间戳**（`2026-05-report.md` → 用 `05-` 前缀；时间在文档元信息里）
- **避免 underscore / 驼峰**：人读场景用"-"或中文空格自然

### 文档本身

- 用 Markdown
- 开头放简介（这份文档讲什么、适合谁读）
- 长文档加目录
- 引用代码 / 数据时直接贴片段，不要只写文件路径 —— 人读不像 Claude 能 Read 工具现查

---

## 为什么和 .claude/ 分开

- **读者不同**：docs 给老板 / 同事 / 未来入职的人看；`.claude/` 给 Claude 看
- **优化方向不同**：docs 优化"可读性"（长句 / 图 / 表格）；`.claude/` 优化"可命中"（命令式 / frontmatter / 短钩子）
- **生命周期不同**：docs 发布后基本不改（除非 archive）；`.claude/` 随项目迭代随时更新

把 PRD 塞进 memory = Claude 加载时吃爆 context；把 skill 规则塞进 docs = Claude 永远读不到。

---

## 判断标准（audit 时问的问题）

1. **是否误用了 docs**：有没有"给 Claude 看的规则 / 事实"写进 docs？（查标题和内容判断）应迁到 rules/ 或 memory/
2. **是否误用了 memory**：`.claude/memory/` 里有没有大段教程 / PRD 内容？应迁到 docs/
3. **归档纪律**：过期 / 废弃的文档有没有迁 `archive/`？还是混在主列表里让读者困惑哪份是现行
4. **编号一致性**：主文档有编号前缀吗？编号是否连续？（跳号说明有删除未同步）
5. **长度**：有没有 30KB+ 的巨型文档？应考虑拆分或加目录
6. **链接完整性**：文档间互相引用的路径 / 文件还在吗？有没有指向已 archive 文件的死链？

---

## 反模式

- **把 docs 当 changelog**：堆"第 N 次迭代记录"。迭代记录进 journal.md，不进 docs
- **把 docs 当 brainstorm 笔记**：思考过程写 `lessons/` 或 journal；docs 放**结论性**文档
- **docs 里写 Claude Code 指令 / skill 规则**：Claude 不会主动读 docs/。该写 CLAUDE.md / rules / SKILL.md
- **不归档直接删**：废弃的 PRD / 设计稿直接 `rm`。应 `mv docs/old.md docs/archive/`，保留历史
- **没编号就按字母序**：`api.md` / `pricing.md` / `research.md` 按字母排，读者不知道先读哪个
- **`README.md` 放 docs/ 下**：项目主 README 在根目录，docs/ 下的 README 会让人混淆

---

## 示例

### 好的 docs 目录

```
docs/
├── 01-产品需求.md
├── 02-技术方案.md
├── 03-API 设计.md
├── 04-数据模型.md
├── 05-上线 Checklist.md
├── api-reference.yaml         # OpenAPI 原始数据也放 docs/
└── archive/
    └── .gitkeep
```

编号清晰，内容按阶段演进（01 需求 → 02 方案 → 03 API → 04 数据 → 05 上线），原始数据文件也在这里而不是 memory。

### 坏的 docs 目录

```
docs/
├── notes.md
├── TODO.md              # 应该进 CLAUDE.md 或 journal
├── api_docs.md          # 小写下划线，不如中文
├── meeting_2026_04_23.md  # 会议记录进 journal 或合并到进展总结
├── random-thoughts.md   # 随笔 → 进 journal 或 lessons
└── old_prd.md           # 过期没归档
```

没排序、内容混杂、废弃未归档、TODO 乱放。
