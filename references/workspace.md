# workspace/ 写作标准

`workspace/` 是**项目临时产物的家**。它填的是一个很具体的空：系统 `/tmp` 会定期清空（耗时产物存进去就危险）、项目根要保持正式代码的干净（堆 `test.py` / `sample.json` 分不清正式和调试）、`docs/` 是正式文档（调试脚本进 docs 稀释文档价值）。介于这几者之间，需要一个**位于项目内、被 gitignore 覆盖、专门装临时产物**的隔离区 —— 这就是 workspace。

理解这个"填空位置"，后面所有规则都能推出来：gitignore 必须覆盖（否则污染 git 历史）、.gitkeep 要保留（否则空目录 clone 不过来）、耗时产物不能进（它们不是临时的）。

---

## 典型用途

**调试脚本**：一次性跑完就扔的 `check_health.sh` / `quick_test.py`。

**数据抓样本**：`sample_response.json` / `test_input.csv`，debug 时看看就行。

**备份件**：大改前的旧版拷贝 `main.py.before-refactor`。

**中间产物（短期的）**：API 返回原始 JSON 准备对比、下载的大文件即将处理完就扔。

三个子目录是约定：`workspace/tmp/` 装真正一次性的、`workspace/bak/` 装备份件、`workspace/scratch/` 装随手草稿。用户想扁平也行（workspace 下随便放整个目录被 gitignore 覆盖）。拆子目录的好处是用意清晰，扁平的好处是操作轻。选哪个看习惯。

---

## 不放耗时产物

这是 workspace 最容易踩的坑。"看起来是临时" 和 "实际是耗时产物" 有本质区别：

**耗时产物**：eval 结果 / 训练数据 / LLM 生成内容 / 爬虫数据 / embedding 缓存。这些花了**大量时间和 API 费用**产出，一旦删除不可恢复。放进 workspace 意味着哪天清理 workspace 时一起删掉，损失巨大。

**真正的临时产物**：几小时内会用完的 debug 脚本、已经处理完只等删的原始数据样本、随手想验证的小代码片段。这些删了没损失。

判断标准：**这东西下个月还有价值吗？** 有 → 不是临时，应该放 `docs/` 或专门目录（`eval-results/` / `llm-outputs/` / `scraped-data/`），独立起名独立保管；没 → 真临时，workspace。

你可能觉得 "eval 结果先放 workspace 之后再挪" —— 但"之后"往往不会发生，下次清 workspace 时顺手就带走了。一开始就放对位置比后来想挪更稳。

---

## gitignore 覆盖

workspace 子目录必须被 gitignore 覆盖：

```gitignore
workspace/tmp/
workspace/bak/
workspace/scratch/
```

或粗暴写法：`workspace/*` + `!workspace/.gitkeep`（整个忽略，保留 `.gitkeep` 让目录入 git）。

没 gitignore 覆盖的后果：临时脚本进 git 历史污染 diff，以后想清理要重写历史。

`.gitkeep` 是另一条必须 —— 空目录不进 git，clone 的人没这个位置用。workspace 作为约定好的临时区，位置必须随模板走。

---

## 删除边界（关键）

workspace 下看起来"旧"的文件，**删之前必须和用户确认**。

用户可能把 eval 中间产物、重要备份、还没看完的 LLM 生成内容放进 workspace（本不该放这，但人会这样做）。看起来 3 个月没动 ≠ 真的可以删 —— 它可能是用户花了 $50 API 费和一晚上时间跑出来的东西。

所以：workspace 不是 "任 Claude 清理的垃圾场"。即使职责上它是临时区，删除仍然要走"用户明确指示"这条铁律。宁可多问一句也不能擅自删。

---

## 审视 workspace/

核心判断：**workspace 是否在履行"项目临时产物隔离区"的职责，且没有误装不该装的东西**。

具体看：`workspace/` 子目录在 gitignore 里吗 → 没覆盖就是在污染 git。`.gitkeep` 存在吗 → 没有空目录不入 git。是否有几个月没碰的文件 → 可能是僵尸，或可能是用户重要产物，**问用户再决定**。有没有"看起来重要"的文件（final / important / benchmark / result 字样）误放 → 该迁到 `docs/` 或独立目录；但迁之前问用户这些是不是耗时产物。没有 workspace 目录但项目根堆着 `test.py` / `sample.json` → 建议建 workspace 并挪过去。

共同根因：**workspace 的健康 = 隔离职责清晰 + 内容归类正确**。gitignore 不覆盖 = 隔离失效；耗时产物混入 = 归类错误。两件事都要审。

---

## 反面长什么样

最常见的失败是**不分"临时"和"耗时但一次性"**，把所有非代码产物都塞 workspace。共同根因是把 workspace 当垃圾场而不是隔离区。

**把重要产物放 workspace**：eval 结果 / LLM 生成 / 爬虫数据。这些删了不可恢复，应放 `docs/` 或独立专门目录。

**用 workspace 代替 docs**：把正式文档（PRD / 设计稿 / 使用指南）放这儿。gitignore 会把它们从 git 抹掉，协作无从谈起。

**workspace 没 gitignore 覆盖**：临时脚本全进 git 历史，以后想清理要 filter-repo。

**workspace 越长越大没人清**：真临时的产物没做过清理，和耗时产物混在一起。应定期 archive 或删 —— 但删前按前述铁律问用户。

**不确定就盲删 workspace 下"旧文件"**：用户花钱花时间的产物可能看起来旧。删之前必须确认。

---

## 和 docs/ 的边界

边界判断的一句话：**下个月还有价值吗？**

有价值：PRD / 调研报告 / 使用指南 / 稳定版本的 API 参考 / 重要的 eval 结果 / 最终 benchmark → `docs/`（或 `docs/archive/` 装过期的、独立专门目录装大型产物）。

没价值（用完即扔）：一次性调试脚本 / API 返回原始 JSON / 大改前备份 / 快速验证的小脚本 → `workspace/`。

关键判据在"下个月还有价值吗"而不是"现在看起来是不是临时"，因为"现在觉得临时"很可能过一两周发现还要用，而那时文件已经在 workspace 里混进一堆真临时文件，找不回来。

---

## 示例

### 合理用法

```
workspace/
├── tmp/
│   ├── check_health.sh         # 今天写的健康检查，跑完就扔
│   └── raw_response_403.json   # 某个报 403 的 API 原始返回，debug 用
├── bak/
│   └── main.py.before-refactor # 大重构前备份
└── scratch/
    └── quick_test.py           # 快速验证想法
```

每个文件的生命周期都在几小时到几天，跑完就可以删。这是健康的 workspace。

### 问题用法

```
workspace/
├── final_benchmark_2026-05-02.json   # "final" = 成果，应进 docs/benchmarks/
├── model_cache/                       # 下载的大模型权重，应独立目录 + 独立 gitignore
├── important_design.md                # 重要设计文档，应进 docs/
└── old_notes.md                       # 3 个月没动，先问用户再决定
```

四个文件每个都是错配：成果混进临时区、巨大产物无独立管理、正式文档错位、长期不动但不能盲删。workspace 变成了混合了"重要"和"临时"的泥潭 —— 一旦清理就面临"都删 = 丢重要"、"都留 = 不清理"的两难。
