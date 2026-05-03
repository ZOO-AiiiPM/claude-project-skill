# docs/ 写作标准

`docs/` 是**给人类读者的文档家**。这是整个协作层里和其他所有文件最根本的区别 —— CLAUDE.md / rules / memory / journal / lessons 都是给 Claude 看的（优化模型可读性、可命中、可触发加载），docs/ 是给人看的（老板 / 同事 / 未来入职的人 / 自己一个月后）。读者不同，写法、结构、生命周期全都不同。

你可能觉得 markdown 都长一样，位置随便 —— 但错位放置的代价是目标读者永远读不到。把 PRD 塞进 `.claude/memory/` 会让 Claude 按需读时加载一大段非事实内容浪费 context；把 skill 的行为规则塞进 `docs/` 会让 Claude 永远读不到，因为 Claude 不主动读 docs。每类内容有专属读者和专属位置，这一层分工比单个文档的内容更重要。

---

## 读者不同，优化方向就不同

docs 优化**人类可读性**：长句可以长、图可以多、表格可以复杂、背景可以铺陈。人类读者能连贯读完一整份文档，容忍冗余；Claude 不会。

`.claude/` 优化**Claude 可命中和自动加载**：命令式 / frontmatter / 短钩子 / 按主题拆 / paths 作用域。这些对人类不好读（太跳跃、太结构化），但对 Claude 恰好。

**生命周期也不同**。docs 是阶段性产出 —— PRD / 架构设计 / 上线 Checklist，写完发布基本不再改（要改就版本升级并 archive 旧版）。`.claude/` 随项目迭代随时更新 —— rules 加条款、memory 加事实、journal 每周写新条目。

理解这组对比，放置位置自然清楚：给人读的稳定文档 → docs；给 Claude 读的动态规则和事实 → `.claude/`。

---

## 命名和编号

docs 主文档用**编号前缀**（`01-` / `02-` / `03-`），保证阅读顺序。没编号就按字母序排列，读者不知道先读哪份。

```
docs/
├── 01-产品需求.md       # 先读产品
├── 02-技术方案.md       # 再读方案
├── 03-API 设计.md       # 然后 API
├── 04-数据模型.md       # 数据
├── 05-上线 Checklist.md # 最后上线
├── api-reference.yaml   # OpenAPI 原始数据也放 docs/
└── archive/             # 过期归档
```

**中文标题 OK**。docs 是给人读的，中文标题比英文更自然，阅读顺序一眼可见。`.claude/` 下的文件反而用英文 / 下划线（文件命名规则，不是给人读）。

**避免时间戳命名**（`2026-05-02-report.md`）。时间信息写在文档元信息里，不进文件名 —— 否则后面要归档或版本升级时文件名要改，引用方跟着挂。用编号代表顺序，用文档内部标注时间。

**避免 underscore / 驼峰**（`api_docs.md` / `ApiDocs.md`）。给人读场景用连字符或中文空格更自然。

---

## docs 不放哪些东西

最常见的错配模式是**把给 Claude 的东西塞进 docs**。下面几类内容都不该进 docs：

**Claude 指令 / skill 规则 / 项目协作规则**：Claude 不会主动读 docs，这些东西的家是 CLAUDE.md / rules / SKILL.md。写进 docs = 规则事实上不存在。

**changelog 式迭代记录**（"第 N 次迭代做了什么"）：迭代记录进 journal（倒序时间线）。docs 不是时间线。

**brainstorm 笔记 / 随笔**：思考过程进 lessons（完整复盘）或 journal（简短反思）。docs 放**结论性**文档，不放思考过程。

**TODO.md 单独列在 docs 下**：待办进 CLAUDE.md 的"待做"段（全局 / 高优先级）或 journal 的行动项（按时间）。docs 不装 TODO。

**项目主 README 放 docs/ 下**：主 README 在项目根目录，docs/ 下的 README 会让人困惑 "docs/README 和根 README 哪个是主的"。docs/ 放具体主题文档就行，不需要 README。

共同根因：**docs 是给人读的正式、阶段性产出**。思考过程 / 时间线 / 规则都有别的家，混进 docs 会让 docs 失去"我看 docs 就是看产出"的简洁定位。

---

## 归档纪律

过期 / 废弃的文档**迁 `archive/`，不直接删**。

```
docs/
├── 01-产品需求.md
├── 02-技术方案.md      # v2 方案
└── archive/
    └── old-tech-spec-v1.md  # v1 方案，被 v2 取代
```

保留历史的理由：未来某次讨论可能需要回溯"当时为什么放弃方案 A"，或者新版本踩坑想看老版本有没有类似经验。删了就没这机会。archive/ 的成本是一个子目录，收益是历史可追溯。

反面：废弃文档混在主列表里不归档 —— 读者看到 `01-需求.md` 和 `old-prd.md` 两份不知道哪份是现行。归档不是整洁癖，是**防止读者读错版本**。

---

## 审视 docs/

核心判断：**docs 里每份文档都是给人读的阶段性产出、且现行版本一眼能识别**。不能的地方就是要改的地方。

具体看：有没有"给 Claude 读的规则 / 事实"误写进 docs → 迁回 rules / memory / CLAUDE.md，docs 里留一行指针即可。`.claude/memory/` 里有没有大段 PRD / 教程内容（给人读的）→ 迁到 docs/。过期文档有没有迁 `archive/` → 没迁的挪过去。编号前缀是否连续 → 跳号说明有删除未同步，重新编号或保留历史空档。30KB+ 巨型文档 → 拆分或加目录。文档间互相引用的路径有没有死链（引用的文件已 archive / 已删）→ 修链接或删引用。

共同根因：docs 健康 = **读者能快速定位现行、正确的阶段性文档**。做不到这点就在流失 docs 的价值。

---

## 反面长什么样

最常见的失败是**把 docs 和 .claude/ 边界搞混**。共同根因是没想清读者差异。

**把 docs 当 changelog**：堆"每次迭代记录"。迭代记录进 journal，不进 docs。

**把 docs 当 brainstorm 笔记**：思考过程写 lessons 或 journal。docs 放结论。

**docs 里写 Claude 指令**：Claude 不主动读 docs，这些指令写了等于没写。该进 CLAUDE.md / rules / SKILL.md。

**不归档直接删**：废弃 PRD / 设计稿直接 `rm` —— 丢了历史追溯能力。应 `mv docs/old.md docs/archive/`。

**没编号就按字母序**：读者不知道先读哪个。加编号前缀。

---

## 示例

### 好的 docs/

```
docs/
├── 01-产品需求.md
├── 02-技术方案.md
├── 03-API 设计.md
├── 04-数据模型.md
├── 05-上线 Checklist.md
├── api-reference.yaml
└── archive/
    └── .gitkeep
```

编号清晰表达阅读顺序（需求 → 方案 → API → 数据 → 上线），原始数据（OpenAPI）也放 docs（它是给人核对用的参考，不是给 Claude 按需查的事实）。

### 坏的 docs/

```
docs/
├── notes.md                      # 无主题命名
├── TODO.md                       # 应进 CLAUDE.md 或 journal
├── api_docs.md                   # underscore 不自然
├── meeting_2026_04_23.md         # 会议记录进 journal 或合并到进展总结
├── random-thoughts.md            # 随笔进 journal 或 lessons
└── old_prd.md                    # 过期没归档
```

每个命名都指向一种错配：没主题 / 时间戳 / 不是 docs 该装的 / 过期不归档。这种 docs/ 让读者无从下手 —— 哪个是现行？哪个该读？哪个是思考稿？docs 失去"打开就是正式产出"的价值。
