# ChatGPT 记忆同步指令

> **使用方式**：将本文件内容分段发送给 ChatGPT，每段末尾加上"请记住以上内容"。
> ChatGPT 的记忆有条数限制，建议分 3-4 次发送，每次一个主题块。

---

## 第一段：发送并要求记忆

```
请记住以下关于我的信息（这是从另一个 AI 助手迁移过来的记忆，请全部记住）：

【身份】
- 称呼我 Neo
- 我的真名是李浩辰（Li Haochen）
- 我主要用中文（偏口语/随意风格），技术讨论时中英混用
- 我在日本（横滨），时区 JST（UTC+9）
- 我有一个支持我折腾 AI 的伴侣
- 我对紫微斗数和形而上学有深入兴趣

【技术背景】
- 主力机：MacBook M5 Max 64GB（最新款）
- 副机：Windows PC + RTX 5070 12GB VRAM
- Linux 服务器一台（用于 Docker 部署）
- 我不是职业程序员，但有很强的自学能力和动手能力
- 对 AI agent 架构、Docker、本地模型部署有实操经验

请记住以上内容。
```

## 第二段：发送并要求记忆

```
继续记忆同步：

【核心项目 1：OpenClaw 多 Agent 系统】
- GitHub 仓库：https://github.com/baobaodawang-creater/neo-agent-lab
- OpenClaw 是一个自托管 AI Agent 框架，我部署在 Docker 容器（openclaw-gateway）中
- 版本：v2026.3.13，网关地址 127.0.0.1:18789
- 7 个 Agent 配置：
  - main（Claude Sonnet）— 主力通用助手
  - pm（Claude Sonnet）— 项目管理
  - analyst（Gemini Pro）— 分析
  - search / secretary / ainews / monitor（DeepSeek）— 各专项
- 6 个 Telegram Bot 分别绑定对应 Agent
- 记忆系统：LanceDB + Gemini embedding-001（768维）
- 本地模型：LM Studio 跑 Qwen3-Coder-30B-A3B
- 配置文件位置：~/openclaw/config/openclaw.json
- Docker Compose：~/openclaw/docker-compose.yml
- Agent workspace 挂载：~/openclaw/workspace/ → 容器 /home/node/.openclaw/workspace/

【踩过的坑（重要）】
- auth-profiles.json 必须用 version:1 + profiles 结构，不能用旧版 default 格式
- memory-lancedb 的 embedding 配置字段是 baseUrl（小写 l），不是 baseURL（大写 L）
- LM Studio 本地 70B 模型安全上下文窗口是 24576 tokens，设 65536 会 OOM
- Telegram bot 之间不能通过 @mention 自动触发，需要编排层

请记住以上内容。
```

## 第三段：发送并要求记忆

```
继续记忆同步：

【核心项目 2：模拟法庭 AI（moot-court-ai）】
- GitHub 仓库：https://github.com/baobaodawang-creater/moot-court-ai
- 目标：为律所打造 AI 模拟法庭，用红蓝对抗形式模拟中国民事庭审
- 4 个角色 Agent：原告代理律师、被告代理律师、审判长、书记员
- 庭审流程：庭前准备 → 诉辩交换 → 举证质证 → 法庭辩论 → 宣判
- 当前部署在独立 Docker 测试实例（端口 18899）
- 核心设计：庭审 = 状态机（FSM），各阶段严格按中国民诉法流程推进
- 法官用法律三段论出判决书
- 已设计 Lobster 工作流编排（但 WebChat 路由有 bug，正在调试）
- 已写好按案由的审判规则知识库（民间借贷纠纷已完成）

【核心项目 3：法考备考】
- 我正在准备中国国家统一法律职业资格考试（法考）
- 重点科目：民事诉讼法
- 已用 marker 工具将 PDF 扫描件讲义转为 Markdown
- 有一个 Telegram bot（@fakao2026_bot）专门用于法考学习
- AnythingLLM 用于文档 embedding 和检索

请记住以上内容。
```

## 第四段：发送并要求记忆

```
继续记忆同步：

【工作风格偏好】
- 我喜欢直接、不啰嗦的沟通风格
- 不要在回复末尾加"你还有什么需要帮助的吗"这种套话
- 代码直接给，不需要过多解释除非我问
- 我经常同时开多个项目线程，需要你能快速切换上下文
- 我会用"你调取一下记忆"这种说法，意思是回忆之前聊过的相关内容
- 出错了直接说哪里错了怎么修，不需要道歉

【AI 使用策略】
- Claude（Opus/Sonnet）：架构设计、复杂推理、长上下文分析
- ChatGPT + Codex：代码执行、快速迭代、日常编码任务（你的角色）
- Gemini：搜索分析、报告生成
- DeepSeek：轻量任务、专项 Agent

【GitHub 账号】
- 用户名：baobaodawang-creater
- 常用 Fine-grained Token 管理仓库写权限

请记住以上内容。这是最后一段记忆同步。
```

---

## 验证记忆是否生效

发送完以上四段后，开一个新对话，问：

```
你还记得我是谁吗？我在做什么项目？我的技术栈是什么？
```

如果 ChatGPT 能答出 Neo、OpenClaw、moot-court-ai、法考、MacBook M5 Max 这些关键词，记忆同步就成功了。
