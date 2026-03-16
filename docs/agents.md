# Agent 配置说明

本系统共 7 个 Agent，分为前台和后台两类。

## 前台 Agent（有 Telegram 绑定）

### main — 总指挥 🦞
- 模型: anthropic/claude-sonnet-4-6
- Telegram: @Openclaw0_2026_bot
- 职责: 接收用户指令，决策分发，协调所有子 Agent

### pm — 产品经理 📋
- 模型: anthropic/claude-sonnet-4-6
- Telegram: @neopm0_bot
- 职责: 把模糊想法变成可执行计划

### secretary — 私人秘书
- 模型: custom-api-deepseek-com/deepseek-chat
- Telegram: @neoassist0_bot
- 职责: 每日简报、信息汇总、提醒

### ainews — AI情报播报 📰
- 模型: custom-api-deepseek-com/deepseek-chat
- Telegram: @ainews2026faked_bot
- 职责: 每日定时搜索 AI 新闻，筛选推送

### monitor — 情报监控员 📡
- 模型: custom-api-deepseek-com/deepseek-chat
- Telegram: @monitor0neo_bot
- 职责: 定时监控指定内容，过滤推送有价值信息

## 后台 Agent（内部调度，无 Telegram 入口）

### analyst — 深度分析师 🔍
- 模型: google/gemini-3.1-pro-preview
- 职责: 长文分析、信息研判、撰写报告，发挥 Gemini 1M context 优势

### search — 情报专员 🌐
- 模型: custom-api-deepseek-com/deepseek-chat
- 职责: 实时信息检索，快速返回结果，只搜索不分析

## Agent 身份文件说明

每个 Agent 的 workspace 下有以下文件：

| 文件 | 作用 |
|------|------|
| SOUL.md | 性格、职责、工作原则 |
| IDENTITY.md | 名字、emoji、风格定义 |
| AGENTS.md | 团队架构，知道其他 agent 是谁 |
| USER.md | 关于用户的信息 |
| TOOLS.md | 可用工具说明 |
| MEMORY.md | 长期记忆文本备份 |
