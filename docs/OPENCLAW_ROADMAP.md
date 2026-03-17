# OpenClaw 进化路线图

> **定位**：OpenClaw 不是聊天机器人集群，是 Neo 的个人行动编排系统。
> **原则**：每个阶段只做一件事，做稳了再往下走。不堆功能，堆回路。
> **创建日期**：2026-03-18
> **创建者**：Claude (Opus) for Neo

---

## 当前基线（已完成）

| 能力 | 状态 |
|------|------|
| 7 Agent 分工部署 | ✅ main/pm/analyst/search/secretary/ainews/monitor |
| 多模型混合 | ✅ Kimi K2.5 / Claude Sonnet / Gemini Pro / DeepSeek |
| Telegram 5 Bot 通道 | ✅ |
| LanceDB 向量记忆 | ✅ Gemini embedding-001, 768维 |
| Workspace 宿主机挂载 | ✅ 实时同步 |
| 每日新闻简报 | ✅ daily_news.sh + ainews agent |
| 每日工作简报 | ✅ daily_brief.sh + secretary agent |
| Docker 容器化 | ✅ |

---

## Phase 1：情报系统升级（从"能发消息"到"能筛情报"）

**目标**：OpenClaw 每天给你推的不是"AI 新闻"，而是"和你有关的情报"。

**当前问题**：daily_news.sh 是定时触发一个 prompt，ainews 生成的内容质量取决于那一刻模型的发挥，没有去重、没有分级、没有持续追踪。

**改造方案**：

### 1.1 情报采集层（search agent）
- 定义 5-8 个固定监控关键词：
  - Chinese legal AI / courtroom simulation
  - OpenClaw / agent framework / MCP
  - local model deployment / quantization
  - Claude / Gemini / DeepSeek / Kimi 更新
  - 法考政策变动
- search agent 每天定时抓取（可用 browser skill 或 API）
- 原始数据存入 workspace/intelligence/raw/YYYY-MM-DD.md

### 1.2 分析过滤层（analyst agent）
- 读取当天原始数据
- 去噪：去掉营销号、重复内容、无实质信息
- 分级：🔴紧急（影响你的项目）/ 🟡关注 / 🟢了解即可
- 输出 workspace/intelligence/filtered/YYYY-MM-DD.md

### 1.3 推送层（secretary agent → Telegram）
- 读取 filtered 文件
- 生成精炼版推送（不超过 10 条，每条一句话 + 链接）
- 通过 Telegram 发给你
- 分两次：早报（8:00 JST）+ 晚报（22:00 JST）

### 1.4 记忆层（LanceDB）
- 每条情报入库，后续可以问"上周有没有关于 XX 的消息"
- 避免重复推送相同内容

**验收标准**：连续 7 天收到有价值的情报推送，且没有垃圾内容。

**预估工作量**：3-5 个 Codex 任务。

---

## Phase 2：项目总控台（从"你记着所有事"到"它替你盯着"）

**目标**：OpenClaw 每天自动扫描你所有项目的状态，生成进展报告和待办提醒。

**当前问题**：你的项目状态靠 PROJECT_STATUS.md 手动维护，容易遗忘和过时。

**改造方案**：

### 2.1 项目注册表
- 在 workspace 下建 projects/ 目录
- 每个项目一个 YAML 配置文件：
  ```yaml
  id: moot-court-lite
  path: ~/Desktop/moot-court-ai-lite-main/
  repo: https://github.com/baobaodawang-creater/moot-court-ai
  type: product
  priority: P0
  status: demo-ready
  next_actions:
    - 录演示视频
    - 给律师看
  ```

### 2.2 日扫描任务（monitor agent）
- 每天定时扫描：
  - Git：最近 commit、未提交的改动、分支状态
  - Docker：容器健康状态、日志报错
  - workspace：文件变更摘要
  - 配置：API Key 有效性（轻量检查）
- 输出 workspace/projects/daily-scan/YYYY-MM-DD.md

### 2.3 项目日报生成（pm agent）
- 读取扫描结果 + 项目注册表
- 生成结构化日报：
  - 各项目昨日变更
  - 卡住的事项
  - 今天最值得推进的 3 件事（按优先级排序）
- 通过 Telegram 推送

### 2.4 自动更新 PROJECT_STATUS.md
- pm agent 生成的日报同时写回 PROJECT_STATUS.md
- push 到 GitHub
- ChatGPT / Codex 下次读取就是最新的

**验收标准**：连续 7 天不需要手动更新 PROJECT_STATUS.md，且日报内容准确。

**预估工作量**：5-8 个 Codex 任务。

---

## Phase 3：Codex 任务路由器（从"你手动给 Codex 写指令"到"OpenClaw 替你写"）

**目标**：你给 OpenClaw 一句话目标，它自动拆解成 Codex 可执行的任务清单。

**当前问题**：每次需要 Codex 干活，你要么自己写指令，要么让 ChatGPT 拆解再手动复制。这个过程可以半自动化。

**改造方案**：

### 3.1 任务接收（main agent via Telegram）
- 你发一句话：`给 moot-court-lite 加一个案件搜索功能`
- main agent 识别这是一个开发任务

### 3.2 任务分析（analyst agent）
- 读取目标项目的 PROJECT_CONTEXT.md 和代码结构
- 分析改动范围、涉及文件、潜在风险

### 3.3 任务拆解（pm agent）
- 生成 Codex 可执行的任务清单
- 每条任务包含：工作目录、具体指令、预期结果
- 输出到 workspace/tasks/YYYY-MM-DD-{task_name}.md

### 3.4 推送审批（secretary → Telegram）
- 把任务清单发给你预览
- 你回复"执行"或"改一下第3条"
- 确认后你复制到 Codex 执行

**注意**：这个阶段不做全自动执行。OpenClaw 只负责"出任务单"，执行权仍然在你手里。全自动是 Phase 5 以后的事。

**验收标准**：你给一句话目标，5 分钟内 Telegram 收到可直接复制给 Codex 的任务清单。

**预估工作量**：5-8 个 Codex 任务。

---

## Phase 4：moot-court-ai 编排层（从"两个独立项目"到"一个系统"）

**目标**：OpenClaw 成为法律 AI 体系的入口，moot-court-lite 成为执行引擎。

**前置条件**：moot-court-lite 已拿到律师反馈并确认方向。

**改造方案**：

### 4.1 案件入口（main agent via Telegram）
- 律师通过 Telegram 发送案件材料（PDF/图片/文字描述）
- main agent 接收并分类

### 4.2 案件预处理（analyst agent）
- 调用 moot-court-lite 的案卷导入 API
- 自动解析案件材料
- 生成结构化案件档案

### 4.3 庭审调度（pm agent）
- 调用 moot-court-lite 的 trial create API
- 根据案由自动选择模型分配
- 触发完整庭审流程

### 4.4 结果汇总（secretary agent）
- 庭审结束后自动获取：庭审记录、风险报告、PDF 笔录
- 通过 Telegram 推送给律师
- 存入 LanceDB 供后续检索

**验收标准**：律师 Telegram 发案件材料 → 自动跑完庭审 → 收到风险报告，全程无需手动操作。

**预估工作量**：10-15 个 Codex 任务。需要 moot-court-lite 先暴露完整 REST API。

---

## Phase 5：法考学习代理（从"有个 bot"到"带节奏的学习系统"）

**目标**：OpenClaw 替你管理法考备考节奏，不只是问答。

**前置条件**：法考资料已全部入库（Markdown + embedding）。

**改造方案**：

### 5.1 知识图谱构建（analyst agent）
- 扫描所有法考 Markdown 文件
- 提取考点树：科目 → 章节 → 知识点 → 关键法条
- 存入 workspace/fakao/knowledge-map.json

### 5.2 学习计划生成（pm agent）
- 根据考试日期倒推
- 按薄弱项优先排序
- 每天生成学习任务卡（今天学什么、为什么、预计 30 分钟）

### 5.3 错题追踪（monitor agent）
- 记录你每次问答的对错
- 识别高频错误知识点
- 自动调整学习计划权重

### 5.4 每日推送（secretary → Telegram）
- 早上推学习任务
- 晚上推复习要点 + 明天预告

**验收标准**：连续 30 天收到个性化学习推送，且内容随你的掌握程度动态调整。

**预估工作量**：8-12 个 Codex 任务。

---

## Phase 6：夜间自动工坊（从"你在才动"到"你不在也推进"）

**目标**：OpenClaw 在你睡觉时自动执行低风险维护任务。

**前置条件**：Phase 1-3 全部稳定运行至少 2 周。

**改造方案**：

### 6.1 夜间任务队列
- 定义"安全任务"白名单：
  - 拉取 Git 状态
  - 扫描 Docker 日志
  - 检查配置一致性
  - 清理临时文件
  - 归档过期情报
  - 生成次日 briefing
- 禁止清单：任何涉及写代码、改配置、调 API 的操作

### 6.2 定时触发（cron + main agent）
- 每天凌晨 3:00 JST 触发
- main agent 按白名单顺序执行
- 结果写入 workspace/nightwatch/YYYY-MM-DD.md

### 6.3 晨报推送
- 早上 7:30 JST secretary 推送夜间报告
- 包含：系统状态、异常提醒、今日建议

**验收标准**：连续 14 天夜间任务零故障，且晨报内容有价值。

**预估工作量**：5-8 个 Codex 任务。

---

## 执行节奏（重要）

```
现在 → 把 moot-court-lite 演示视频录了，拿去给律师看
      ↓
收到反馈后 → Phase 1（情报系统升级，1-2 周）
      ↓
Phase 1 稳定后 → Phase 2（项目总控台，1-2 周）
      ↓
Phase 2 稳定后 → Phase 3（Codex 任务路由器，1-2 周）
      ↓
moot-court 有真实用户后 → Phase 4（编排层）
      ↓
法考备考期 → Phase 5（学习代理）
      ↓
所有系统稳定后 → Phase 6（夜间工坊）
```

**铁律：前一个 Phase 没有连续 7 天稳定运行，不开下一个。**

---

## 给 ChatGPT 的协作说明

每个 Phase 开始时：
1. Neo 把本文件对应 Phase 发给 ChatGPT
2. ChatGPT 拆解成 Codex 可执行任务清单
3. Neo 逐条发给 Codex 执行
4. 结果反馈给 ChatGPT 判断下一步
5. 架构级问题标记 [NEEDS_CLAUDE_REVIEW] 交给 Claude

---

## 给 Codex 的协作说明

- OpenClaw 相关操作工作目录：~/openclaw/
- 容器内操作用 docker exec openclaw-gateway sh -c "命令"
- 改完配置必须提醒 Neo 重启容器
- 不要动 auth-profiles.json 的结构（已确认为每 Agent 独立文件模式）
- embedding 字段是 baseUrl（小写 l），绝对不能写成 baseURL
