# .gitignore 写作标准

Claude Code 项目的 `.gitignore` 有几条**非直觉**的约束。不配好会出现：memory 骨架丢失 / 临时文件污染仓库 / 密钥泄露 / hooks 状态被 commit 污染 diff。

---

## 应该长什么样

### 必须段

```gitignore
# Claude Code 本地状态
.claude/memory/*
!.claude/memory/MEMORY.md
!.claude/memory/archive/
.claude/memory/archive/*
!.claude/memory/archive/.gitkeep

.claude/.turn-counter
.claude/hooks/.state/
.claude/settings.local.json

# Workspace 临时
workspace/tmp/
workspace/bak/

# OS
.DS_Store
Thumbs.db
```

### 可选段（按项目语言加）

```gitignore
# Node
node_modules/

# Python
__pycache__/
*.pyc
.venv/
venv/

# Env
.env
.env.local
```

---

## 关键规则（白名单技巧）

### 为什么 `memory/*` + `!MEMORY.md`

memory 主题文件（`reference_*.md` / `project_*.md` / `user_*.md`）是 Claude 在对话中自动写入的**项目内部事实**，**每个 clone 应独立维护**，不进 repo。

但 `MEMORY.md` 是索引骨架，作为模板要保留，这样别人 clone 后有个空索引可以往里加。

实现：`memory/*` 忽略全部 → `!MEMORY.md` 白名单例外。同理给 `archive/` 保留骨架但忽略内容。

### 为什么 `settings.local.json` 必须忽略

`settings.local.json` 里含 `autoMemoryDirectory` 的**绝对路径**（每人机器不同）、本地 hook 开关、个人 permission 配置。commit 会给每个 clone 带上上游用户的本机路径，等于坏掉所有人的 memory 位置。

**而 `settings.local.json.example` 必须 commit**，作为配置模板让 clone 的人改绝对路径。

### 为什么 hooks/.state/ 和 .turn-counter

- `.claude/.turn-counter` — journal-turn-counter hook 计数器，单文件，每次 session 重置
- `.claude/hooks/.state/` — 其他 hook 可能用的持久状态目录（约定俗成的命名）

这些都是本地运行时产物，commit 会污染 diff 且每人机器产物不同。

### workspace/ 的忽略策略

两种写法：

1. **精细**：`workspace/tmp/` + `workspace/bak/` + `workspace/scratch/`（列举子目录）
2. **粗暴**：`workspace/*` + `!workspace/.gitkeep`（整个忽略，留占位）

模板默认用精细写法，给未来留余地（有人想把 `workspace/designs/` 纳入 git 还能做到）。

---

## 判断标准（audit 时问的问题）

1. **memory 白名单是否完整**：`!MEMORY.md` 和 `!archive/` 两条都有吗？只忽略 `memory/*` 会连 MEMORY.md 都丢
2. **settings.local.json 是否忽略**：没忽略就是**严重配置泄露**（绝对路径会污染所有人）
3. **turn-counter / hooks/.state 是否忽略**：没忽略 → 每次 hook 触发都让 git 冒出 diff
4. **workspace/tmp 是否忽略**：没忽略 → 调试脚本和原始响应数据进 git 历史，再想清理要重写历史
5. **是否误忽略了骨架**：有没有把 `CLAUDE.md` / `journal.md` / `.claude/hooks/*.sh` 等模板必要文件写进 gitignore？
6. **是否有敏感项泄露**：`.env` / `.env.local` / 密钥文件是否在忽略列表？或项目 commit 历史里是否已经混入？
7. **语言通用项**：按项目技术栈该忽略 `node_modules/` / `__pycache__/` 等常见产物没？

---

## 反模式

- **只写 `.claude/memory/`**：把整个目录忽略了，MEMORY.md 骨架也丢 → 新 clone 的项目 Claude 找不到索引
- **把 `settings.local.json.example` 也忽略了**：clone 的人没有配置模板，不知道该怎么建自己的 settings
- **忽略 `.claude/settings.json`**：这是 policy 层，可能项目级共享配置，不应忽略（只忽略 `local` 后缀）
- **把整个 `.claude/` 忽略**：规则、hooks 模板、memory 索引全丢，等于没有 Claude Code 协作层
- **commit `.env` 再 gitignore**：`.env` 已经进历史，gitignore 不能回溯，需要 `git filter-repo` 清除
- **gitignore 写没尾换行**：某些 git 工具对无换行结尾的最后一条规则识别异常

---

## 示例

### 完整合规的 .gitignore

```gitignore
# Claude Code 本地状态：memory 主题文件不入 repo（每项目独立），但骨架文件要保留
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
.env
.env.local
```

### 错误的 .gitignore

```gitignore
.claude/             # 整个忽略 → CLAUDE.md / rules / hooks 骨架全丢
settings.json        # 项目共享 settings 也被忽略
*.md                 # 连 CLAUDE.md / journal.md / README.md 都被忽略
workspace/           # 没配 .gitkeep，空目录不进 git，clone 后没这个位置
```

每条都是常见踩坑，会让协作层崩溃。
