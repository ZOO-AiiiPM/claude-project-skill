# workspace/ 写作标准

项目的**临时工作区**。存放那些"暂时要用 / 中间产物 / 备份件"，明确区别于 `docs/` 的正式文档和 `.claude/memory/` 的事实记忆。被 gitignore 覆盖子目录，不污染 git 历史。

---

## 应该长什么样

### 目录结构

```
workspace/
├── tmp/              # 临时文件（被 gitignore）
├── bak/              # 备份文件（被 gitignore）
├── scratch/          # 随手草稿（被 gitignore）
└── .gitkeep          # 保证空目录进 git
```

或保留扁平：`workspace/` 下随便放，反正整个目录除 `.gitkeep` 以外都 gitignore。

### gitignore 配置

```
workspace/tmp/
workspace/bak/
workspace/scratch/
```

或粗暴：`workspace/*` + `!workspace/.gitkeep`。

### 典型用途

- **调试脚本**：一次性跑完就扔的 `check_xxx.py`
- **数据抓样本**：`sample_response.json` / `test_input.csv`
- **备份件**：大改前的旧版拷贝 `old_skill_backup.md`
- **中间产物**：embedding 缓存、下载的大文件、API 返回原始 JSON

---

## 为什么要有这个目录

### 不放 /tmp 的理由

`/tmp` 每次重启清空 —— 系统级别清理会销毁你还没看完的 LLM 生成结果或 embedding 产物。**耗时产物必须存项目目录**，`/tmp` 只放秒级用完的东西。

### 不放项目根的理由

不建 workspace/ 的项目会出现：根目录堆着 `test.py` / `sample.json` / `backup_old.md` —— 一眼看上去分不清哪个是正式代码、哪个是 Claude 调试脚本。

有了 workspace/ 这个"官方临时区"，Claude 生成调试脚本 / 中间产物时默认丢这里，项目根干净。

### 不放 docs/ 的理由

docs/ 是给人读的正式文档。`curl_test.sh` / `raw_api_response.json` 这类调试物进 docs 会稀释文档价值。

---

## 判断标准（audit 时问的问题）

1. **gitignore 覆盖**：`workspace/` 的子目录（tmp / bak / scratch）在 `.gitignore` 里吗？还是误 commit 了一堆临时文件？
2. **是否沦为垃圾场**：workspace/ 下有没有已经几个月没人碰的文件？该清理 / 归档
3. **是否误放耗时产物**：有没有"看起来重要"的文件（eval 结果 / LLM 生成 / embedding 数据）误放 workspace/？应迁到 docs/ 或专门目录
4. **是否缺位**：没有 workspace/ → 项目根是不是堆着调试脚本 / 样本数据？建议建
5. **.gitkeep 存在**：没 .gitkeep → 空目录不进 git，clone 后别人没这个位置用

---

## 反模式

- **workspace/ 没 gitignore 覆盖**：临时文件进 git 历史，污染 diff
- **把重要产物放 workspace/**：eval 结果 / LLM 生成内容 / 爬虫数据 —— 这些花钱花时间的不是"临时"
- **用 workspace/ 代替 docs/**：把正式文档放这儿 → gitignore 会把它们从 git 中抹掉
- **workspace/ 越长越大没人清**：应定期 archive 或清掉已确认无用的
- **delete workspace/ 下的"旧文件"没确认**：用户的 eval 中间产物可能看起来旧，其实还要用 → **删之前必须确认**

---

## 和 docs/ 的边界

| 内容 | 放哪 |
|------|------|
| PRD / 调研 / 使用指南 | `docs/` |
| 过期 PRD / 旧设计稿 | `docs/archive/` |
| 一次性调试脚本 | `workspace/` |
| API 返回原始 JSON（用完即扔）| `workspace/tmp/` |
| API 原始数据（要长期留）| `docs/{主题}.json` |
| 大改前的备份 | `workspace/bak/` |
| 已稳定版本的参考实现 | `docs/` 或项目源码 |

关键判据：**这东西下个月还有价值吗**？有 → docs 或代码；没有 → workspace。

---

## 示例

### 合理用法

```
workspace/
├── tmp/
│   ├── check_deploy.sh         # 今天写的检查脚本，跑完就扔
│   └── raw_response_403.json   # 某个报 403 的 API 原始返回，debug 用
├── bak/
│   └── kox.py.before-refactor  # 大重构前备份
└── scratch/
    └── eval_quick_test.py      # 快速验证想法的脚本
```

### 问题用法

```
workspace/
├── final_eval_results_2026-04-30.json   # "final"说明是成果，应该进 docs/ 或 evaluations/
├── embedding_cache/                      # 花钱算的向量，应该有专门目录并 gitignore 规则保护
├── important_design.md                   # 重要设计文档，应该进 docs/
└── old_notes.md                          # 已 3 个月没动，应 archive 或删
```
