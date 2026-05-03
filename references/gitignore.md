# .gitignore 写作标准

Claude Code 项目的 `.gitignore` 有几条**非直觉**的约束，不配好整个协作层会退化。不是通用 gitignore 教程，是针对 Claude Code 这套协作层设计的配置 —— 核心是"某些文件必须入 git 保骨架、某些文件必须忽略防污染"，边界很具体。

这套约束背后的共同逻辑：**骨架要跨 clone 传递、本机状态要各自独立**。骨架（MEMORY.md 索引 / settings.local.json.example / hooks 脚本 / .gitkeep 等）新 clone 必须拿到才能启动协作；本机状态（memory 主题文件 / settings.local.json / turn-counter / workspace 临时产物）每个 clone 要独立维护，commit 它们会让你的本机状态污染所有人。

理解这一层分界，下面每条规则都能推出来。

---

## memory 用白名单保骨架

```gitignore
.claude/memory/*
!.claude/memory/MEMORY.md
!.claude/memory/archive/
.claude/memory/archive/*
!.claude/memory/archive/.gitkeep
```

memory 主题文件（`reference_*.md` / `project_*.md` / `user_*.md`）是 Claude 在对话中自动写入的**项目内部事实**，每个 clone 要独立维护。你的服务器地址 / API 密钥 / 账号信息 commit 上去就是泄露 + 干扰别人。所以默认忽略所有主题文件。

但 `MEMORY.md` 是索引骨架 —— 没有它新 clone 的项目启动时 Claude 找不到索引入口，memory 系统事实上不工作。所以 `MEMORY.md` 必须白名单保留入 git，作为空骨架（或默认索引条目）让 clone 的人有个起点往里加。

同样 `archive/` 作为废弃 memory 的归档位置也要保结构（用 `.gitkeep`）。

你可能想简单写 `.claude/memory/` 了事 —— 但这样整个目录被忽略，MEMORY.md 和 archive/ 骨架一起丢 → clone 的项目 Claude 找不到 memory 索引 → 协作层崩。白名单写法是唯一兼顾"隐私 + 骨架"的解。

---

## settings.local.json 必须忽略，.example 必须 commit

```gitignore
.claude/settings.local.json
```

`settings.local.json` 里含几样**本机绑定**的东西：`autoMemoryDirectory` 的绝对路径（每人机器不同）、本机 hook 开关、个人 permission 配置。commit 它会给每个 clone 带上上游用户的本机路径，等于坏掉所有人的 memory 位置（他们的 `/Users/上游用户/...` 路径在自己机器上不存在）。

**但 `settings.local.json.example` 必须 commit**（不能写进 gitignore）。它是配置模板，让 clone 的人知道"这个文件该存在、里面应该配哪些字段、哪些值要改成自己的绝对路径"。没有 example，clone 的人不知道要建这个文件。

这组"忽略本体 + commit 模板"是协作层配置类文件的通用模式：真实配置每人独立，模板要跟随项目走。

---

## hooks 运行时状态要忽略

```gitignore
.claude/.turn-counter
.claude/hooks/.state/
```

`.turn-counter` 是 `turn-reflect` hook 的计数文件，每次 Stop 事件加 1。`hooks/.state/` 是其他 hook 可能用的持久状态目录（约定俗成的命名）。这些都是本地运行时产物，每次 session 会变，commit 会让 git 每次 hook 触发都冒出 diff。

但 `.claude/hooks/*.sh` 脚本本身要 commit（作为骨架跟项目走），这是 hook 功能的前提。所以忽略的是 "状态目录 / 计数文件"，不是整个 hooks 目录。

---

## workspace 子目录忽略

```gitignore
workspace/tmp/
workspace/bak/
workspace/scratch/
```

或粗暴写法：`workspace/*` + `!workspace/.gitkeep`（整个忽略 + 保留占位 let 目录入 git）。

精细写法的好处是将来有人想把某个 `workspace/designs/` 纳入 git 还能做到；粗暴写法简单。模板默认用精细写法。

`workspace/` 本身必须作为空目录入 git（用 `.gitkeep`），因为它是约定好的临时产物位置，新 clone 的项目需要这个位置。

---

## 敏感项和常见产物

```gitignore
# 敏感
.env
.env.local

# OS
.DS_Store
Thumbs.db

# 语言产物
node_modules/
__pycache__/
*.pyc
.venv/
venv/
```

`.env` 忽略不需要解释，泄密性高。但注意：`.env` 如果已经进过 git 历史，gitignore 不能回溯 —— 需要 `git filter-repo` 清除历史，然后立即轮换所有泄露的凭据。commit 密钥一秒都是泄露。

语言特定产物按项目技术栈加（Node / Python / Go / Rust 各有各的）。这部分不是 Claude Code 特有，但漏了会让 repo 又大又脏。

---

## 审视 .gitignore

核心判断：**入 git 的文件都是骨架（跨 clone 要传递），忽略的文件都是本机状态（每 clone 要独立）**。错位的地方就是要改的地方。

具体看：memory 白名单是否完整 → 只有 `.claude/memory/*` 没有 `!MEMORY.md` 的话索引骨架会丢。`settings.local.json` 是否忽略 → 没忽略就是本机路径泄露给所有人。`settings.local.json.example` 是否误入忽略 → 入了 clone 的人没配置模板。`.turn-counter` / `hooks/.state/` 是否忽略 → 没忽略每次 hook 触发都冒 diff。`workspace/tmp` 等子目录是否忽略 → 没忽略临时文件进 git 历史。骨架文件是否误忽略（`CLAUDE.md` / `journal.md` / `.claude/hooks/*.sh` / `.gitkeep` 等）→ 误忽略就是协作层骨架丢。敏感项（`.env` / 密钥文件）是否覆盖 → 没覆盖是定时炸弹，commit 一次就是永久泄露（git filter-repo 补救 + 轮换凭据）。

共同根因：**gitignore 健康 = 骨架 vs 本机的分界清晰**。分不清 = 要么骨架丢（协作层崩）要么隐私漏（本机路径 / 密钥泄露）。

---

## 反面长什么样

最常见的失败是**粗暴地忽略一整个目录**，结果把骨架一起忽略掉。共同根因是没看清"入 git 的骨架"和"忽略的本机状态"混在同一个父目录里。

**整个 `.claude/` 忽略**：CLAUDE.md / rules / hooks 骨架、memory 索引全丢。等于没有 Claude Code 协作层。

**只写 `.claude/memory/` 不写白名单**：`MEMORY.md` 索引骨架和 archive/ 占位一起丢。新 clone 的项目 memory 系统不工作。

**`settings.local.json.example` 被误忽略**：clone 的人没有配置模板，不知道该建 settings.local.json，不知道字段格式。

**`settings.local.json` 没忽略（commit 进去）**：本机绝对路径污染所有 clone。

**`.claude/settings.json` 也被忽略**：这是项目共享 settings（policy 层），不该忽略（只忽略 `.local` 后缀的）。

**用 `*.md` 粗暴忽略 markdown**：CLAUDE.md / journal.md / README.md 全被忽略，项目 commit 出去什么都没有。

**commit `.env` 再 gitignore**：历史里已经有，gitignore 不能回溯。需要 `git filter-repo` 清除 + 立即轮换凭据。

**gitignore 无尾换行**：某些 git 工具对无换行的最后一条规则识别异常 —— 文件末尾留一行空行。

---

## 完整合规示例

```gitignore
# Claude Code：memory 主题文件每 clone 独立，但骨架要保留
.claude/memory/*
!.claude/memory/MEMORY.md
!.claude/memory/archive/
.claude/memory/archive/*
!.claude/memory/archive/.gitkeep

# 本地运行时产物
.claude/.turn-counter
.claude/hooks/.state/
.claude/settings.local.json

# Workspace 临时
workspace/tmp/
workspace/bak/

# OS
.DS_Store
Thumbs.db

# 常见语言产物
node_modules/
__pycache__/
*.pyc
.venv/
venv/

# 敏感
.env
.env.local
```

每一段都有明确职责：memory 段保骨架 + 忽略主题；本地运行时段忽略变化频繁的状态；workspace 段忽略临时产物；OS / 语言产物 / 敏感各自独立。分段注释让后来者看得懂每条的意图，修改时不会误删关键规则。
