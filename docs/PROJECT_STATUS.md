# 项目状态看板 (PROJECT_STATUS.md)

> **用途**：每次开新 Claude 对话时，把这个文件发给 Claude，它就知道从哪里接。
> **维护方式**：每次重要对话结束前，让 Claude 帮你更新这个文件。
> **最后更新**：2026-03-17

---

## 当前活跃项目

### 1. OpenClaw 多 Agent 系统 (neo-agent-lab)
- **状态**：✅ 正常运行中
- **容器**：openclaw-gateway，端口 18789
- **记忆系统**：LanceDB + Gemini embedding-001 (768维) ✅ 已修复
- **上次修复**：baseUrl 大小写问题导致 embedding 维度冲突，已解决
- **待办**：
  - ⬜ 博客发布（掘金/知乎）
  - ⬜ 小红书爬虫 Phase 1（卡在 461 反爬）
  - ⬜ MEMORY.md 长期记忆文件建立

### 2. 模拟法庭 AI (moot-court-ai)
- **状态**：🔄 架构决策阶段
- **关键决策**：正在考虑脱离 OpenClaw，做独立轻量版 Web App
- **三 AI 协作模式已确立**：Gemini 出分析 → Claude 出框架 → Codex 写代码
- **Gemini 已产出**：架构分析报告（FSM 状态机方案）
- **Claude 待产出**：精确框架方案文档（等你选完部署方式/模型/前端复杂度）
- **上次对话卡在**：Claude 问了你三个选择题（部署方式、API Key、前端复杂度），你还没回答
- **待办**：
  - ⬜ 回答框架设计的三个选择题
  - ⬜ Claude 出框架方案
  - ⬜ Codex 按方案写代码
  - ⬜ WebChat 路由 bug（低优先级，可能不再需要修）
  - ⬜ 审判规则知识库扩展（目前只有民间借贷）

### 3. 法考备考
- **状态**：📚 持续进行
- **重点**：民事诉讼法
- **工具链**：PDF → marker → MD → AnythingLLM embedding → @fakao2026_bot
- **待办**：
  - ⬜ 更多科目资料入库
  - ⬜ 模拟题训练功能

### 4. 跨 AI 同步体系
- **状态**：✅ 今天刚建好
- **已完成**：
  - ✅ ai-sync-pack 推送到 GitHub (neo-agent-lab/docs/ai-sync-pack/)
  - ✅ ChatGPT 对话记忆注入（四段 IDENTITY_SYNC）
  - ✅ Codex 读取 PROJECT_CONTEXT.md 完成
  - ✅ ChatGPT 了解三层协作体系
  - ✅ Codex 权限：On request + Workspace write
- **待办**：
  - ⬜ 定期更新 PROJECT_CONTEXT.md（每次重大变更后）
  - ⬜ 本文件 (PROJECT_STATUS.md) 也推送到 GitHub

---

## 下次对话的快速启动指令

复制以下内容发给 Claude 开始新对话：

```
我是 Neo，这是我的项目状态文件，请读完后告诉我你理解了什么，然后我们继续工作。
[粘贴本文件全文]
```

---

## 给 ChatGPT 的快速启动指令

```
调取你的记忆，回忆一下我们的三层协作体系（Claude/ChatGPT/Codex），然后看这份最新状态：
[粘贴本文件全文]
```

---

## 给 Codex 的快速启动指令

```
读取 docs/ai-sync-pack/PROJECT_CONTEXT.md 和 docs/PROJECT_STATUS.md，理解当前项目状态，然后等我指令。
```
