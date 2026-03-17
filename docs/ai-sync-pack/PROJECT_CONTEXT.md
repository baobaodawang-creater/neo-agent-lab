# 项目全景上下文（Codex 参考文档）

> **用途**：将此文件放入 GitHub 仓库根目录或 Codex 项目目录，Codex 打开项目时自动读取。
> 此文件为 ChatGPT Codex 提供完整的项目上下文，使其能在不依赖对话记忆的情况下理解整个技术栈。

---

## 一、系统全景

### 1.1 硬件环境

| 设备 | 型号 | 用途 |
|------|------|------|
| 主力开发机 | MacBook M5 Max 64GB | 日常开发、Docker 运行、SSH 到服务器 |
| GPU 工作站 | Windows PC + RTX 5070 12GB | LM Studio 本地模型推理 |
| 部署服务器 | Linux（具体型号未记录） | Docker 容器部署 |

### 1.2 软件栈

- **容器化**：Docker + Docker Compose
- **AI Agent 框架**：OpenClaw v2026.3.13
- **本地模型**：LM Studio（Qwen3-Coder-30B-A3B, nomic-embed-text-v1.5）
- **向量数据库**：LanceDB（768维，Gemini embedding-001）
- **文档管理**：AnythingLLM（embedding + 检索）
- **消息通道**：Telegram Bot API
- **版本控制**：Git + GitHub
- **VPN/代理**：Clash Verge Rev（从 Clash Party 迁移）

---

## 二、项目详情

### 2.1 neo-agent-lab（OpenClaw 多 Agent 系统）

**GitHub**: https://github.com/baobaodawang-creater/neo-agent-lab

**架构概览**：
```
Mac (宿主机)
├── ~/openclaw/config/openclaw.json    ← 主配置
├── ~/openclaw/config/auth-profiles.json ← API Key 管理
├── ~/openclaw/docker-compose.yml      ← Docker 编排
├── ~/openclaw/workspace/              ← 挂载到容器（实时同步）
│   ├── main/SOUL.md
│   ├── pm/SOUL.md
│   ├── analyst/SOUL.md
│   └── ...
└── Docker: openclaw-gateway
    ├── 监听 127.0.0.1:18789
    ├── WebSocket + REST API
    ├── LanceDB 记忆系统
    └── 7 个 Agent 实例
```

**Agent 配置表**：

| Agent ID | 模型 | Telegram Bot | 职责 |
|----------|------|-------------|------|
| main | Claude Sonnet | @Openclaw0_2026_bot | 主力通用助手 |
| pm | Claude Sonnet | （共用 main bot） | 项目管理 |
| analyst | Gemini Pro | （独立 bot） | 数据分析 |
| search | DeepSeek | （独立 bot） | 搜索 |
| secretary | DeepSeek | （独立 bot） | 秘书/日程 |
| ainews | DeepSeek | @ainews2026faked_bot | AI 新闻日报 |
| monitor | DeepSeek | （独立 bot） | 系统监控 |

**已知关键配置细节**：
- auth-profiles.json 必须使用 `{"version": 1, "profiles": {...}}` 格式
- embedding 配置中字段名是 `baseUrl`（小写 l），不是 `baseURL`
- 日常维护脚本：`~/openclaw/daily_news.sh`（cron 定时触发 ainews）
- Super Intern API 代理：`~/openclaw/superintern_proxy.py`

**常用 Docker 命令**：
```bash
# 查看日志
docker logs openclaw-gateway --tail 30

# 重启
docker compose -f ~/openclaw/docker-compose.yml restart openclaw-gateway

# 进入容器
docker exec -it openclaw-gateway sh

# 容器内 workspace 路径
/home/node/.openclaw/workspace/

# 容器内 Git 推送
docker exec openclaw-gateway sh -c "
cd /home/node/.openclaw/workspace/neo-agent-lab && \
git add . && git commit -m '更新' && git push
"
```

### 2.2 moot-court-ai（AI 模拟法庭）

**GitHub**: https://github.com/baobaodawang-creater/moot-court-ai

**目标**：为律所打造的 AI 模拟法庭系统，使用红蓝对抗形式模拟中国民事庭审全流程。

**角色设计**：

| 角色 | Agent ID | 职责 |
|------|----------|------|
| 书记员 | clerk | 主持流程、记录、引导用户 |
| 原告代理律师 | plaintiff | 红队攻击方，论证请求权基础 |
| 被告代理律师 | defendant | 蓝队防御方，三性质证 + 程序性武器 |
| 审判长 | judge | 中立裁判，归纳争议焦点，三段论判决 |

**庭审状态机**：
```
INIT（庭前准备）
  → COMPLAINT（原告陈述）
    → DEFENSE（被告答辩）
      → EVIDENCE_P（原告举证）
        → CROSS_P（被告质证）
          → EVIDENCE_D（被告举证）
            → CROSS_D（原告质证）
              → JUDGE_INQUIRY（法官发问）
                → DEBATE（法庭辩论）
                  → FINAL_STATEMENT（最后陈述）
                    → JUDGMENT（宣判）
```

**当前状态**：
- 独立 Docker 测试实例运行在端口 18899
- SOUL.md 已写好四个角色
- Lobster 工作流已设计但未完全调通
- WebChat 路由 bug：下拉框切换 agent 不生效（所有 session 走 default agent）
- 已完成民间借贷纠纷的审判规则知识库

**新方向**：
- 考虑脱离 OpenClaw，开发独立轻量版（纯 Web App）
- 三 AI 协作：Gemini 出分析报告 → Claude 出架构框架 → Codex 写代码

### 2.3 法考备考辅助

**考试**：中国国家统一法律职业资格考试（法考）
**重点科目**：民事诉讼法

**已完成**：
- 用 `marker` 将 PDF 扫描讲义转为 Markdown（中文 OCR + 后处理脚本）
- Telegram bot @fakao2026_bot 绑定 DeepSeek，用于学习问答
- AnythingLLM 文档 embedding

**法律知识库已覆盖的领域**：
- 民法典核心条文
- 民事诉讼法（2024修正版）
- 民间借贷司法解释
- 最高法指导案例

---

## 三、历史踩坑速查

| 问题 | 根因 | 解法 |
|------|------|------|
| embedding 维度冲突 192 vs 768 | baseUrl 写成 baseURL，fallback 到错误模型 | 改回 baseUrl（小写 l），清空 lancedb 目录重建 |
| auth-profiles 鉴权失败 | 使用旧版 default 格式 | 换成 version:1 + profiles 结构 |
| LM Studio 70B 模型 OOM | 上下文窗口设为 65536 | 安全值为 24576 tokens |
| Telegram bot 无法互相触发 | Bot 之间 @mention 不路由 | 需要外部编排层（orchestrator） |
| WebChat agent 切换不生效 | WebChat 不支持 binding 路由 | 用 Lobster 工作流驱动，不靠 WebChat 手动切换 |
| Docker 容器内 Git push 失败 | 仓库路径不在容器内 | 通过宿主机挂载目录操作 |
| coqui-tts 安装报错 | transformers 4.45.2 不兼容 | 降级 transformers 版本 |

---

## 四、常用命令速查

```bash
# OpenClaw 相关
docker logs openclaw-gateway --tail 30
docker compose -f ~/openclaw/docker-compose.yml restart openclaw-gateway
docker exec -it openclaw-gateway sh
cat ~/openclaw/config/openclaw.json | jq '.'

# Git 操作（容器内）
docker exec openclaw-gateway sh -c "cd /home/node/.openclaw/workspace/neo-agent-lab && git status"

# LM Studio 测试
curl http://localhost:1234/v1/models

# marker PDF 转 MD
marker_single input.pdf output/ --langs zh --force_ocr

# 模拟法庭测试实例
docker logs moot-court-test --tail 30
```

---

## 五、AI 分工策略

| AI | 角色 | 擅长 |
|----|------|------|
| Claude Opus/Sonnet | 架构师 | 复杂推理、长上下文、框架设计、法律分析 |
| ChatGPT + Codex | 工程师 | 代码执行、快速迭代、文件操作、bug 修复 |
| Gemini | 分析师 | 搜索整合、报告生成、数据分析 |
| DeepSeek | 专项执行 | 轻量任务、OpenClaw 内 Agent 驱动 |

**协作模式**：Claude 出框架方案 → Codex 按方案写代码 → Gemini 做调研补充 → 人（Neo）整合测试
