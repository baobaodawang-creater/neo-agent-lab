# 🦞 Neo Agent Lab

> 一套自托管的多 Agent AI 系统，基于 OpenClaw 构建。7 个 Agent 各司其职，6 个 Telegram 机器人，本地模型 + 云端 API 混合部署。

这个仓库记录了从零搭建、踩坑到跑通的完整过程，包括可复用的配置模板、脚本和踩坑手册。

## 系统架构

| Agent | 模型 | 职责 | Telegram |
|-------|------|------|----------|
| main | Claude Sonnet | 总指挥 🦞 | @Openclaw0_2026_bot |
| pm | Claude Sonnet | 产品经理 📋 | @neopm0_bot |
| analyst | Gemini Pro | 深度分析师 🔍 | 内部调用 |
| search | DeepSeek | 情报专员 🌐 | 内部调用 |
| secretary | DeepSeek | 私人秘书 | @neoassist0_bot |
| ainews | DeepSeek | AI情报播报 📰 | @ainews2026faked_bot |
| monitor | DeepSeek | 情报监控员 📡 | @monitor0neo_bot |

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/baobaodawang-creater/neo-agent-lab.git

# 复制配置模板
cp configs/openclaw.json.example ~/.openclaw/openclaw.json

# 填入你的 API Key，然后启动
docker compose up -d
```

## 文档目录

- [部署踩坑手册](docs/deployment.md) — 四大深坑及修复方案
- [报错速查手册](docs/troubleshooting.md) — 常见报错根因和修复命令
- [Agent 配置说明](docs/agents.md) — 7 个 Agent 的身份和分工
- [配置字段速查](docs/config-reference.md) — openclaw.json 关键字段说明

## 技术栈

- **框架：** OpenClaw v2026.3.13
- **部署：** Docker + macOS M5 Max
- **云端模型：** Claude Sonnet / Gemini Pro / DeepSeek API
- **本地模型：** Qwen3-Coder-30B-A3B abliterated (LM Studio)
- **记忆：** LanceDB + Gemini Embedding (gemini-embedding-001)
- **频道：** Telegram (6 bots)

## License

MIT
