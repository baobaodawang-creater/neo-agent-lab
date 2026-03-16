# 🟣 紫色的跳舞火烈鸟：手搓 OpenClaw 多 Agent 矩阵，我踩平了这 4 个深坑

**摘要：** 最近多 Agent 协作的概念很火，手痒决定不用云端拖拽平台，自己硬核部署一套 OpenClaw。规划挺宏大：一个本地网关，挂载主控、PM、秘书、AI 新闻等 7 个分身；全部接入不同的 Telegram 机器人；主战模型用 Claude Sonnet，备用 DeepSeek，再挂个本地的 LM Studio 兜底；还得配上 LanceDB 搞长期记忆。

看官方文档觉得岁月静好，真跑起来终端满屏飘红，Gateway 进程疯狂 SIGTERM 暴毙。这篇不废话，只聊实打实踩过的坑，以及最终跑通的正确配置（可以直接抄作业）。

---

## 坑一：LanceDB 记忆库的"降维打击"

想让 Agent 拥有长期记忆，内置的 memory-lancedb 插件是标配。但硬生生被它卡了几个小时，日志里换着花样死：

1. **环境依赖找不到**：报 `Cannot find module '@lancedb/lancedb-linux-arm64-gnu'`，跨平台部署原生包容易丢
2. **Embedding 模型 404**：配了 `text-embedding-004`，走 OpenAI 兼容协议路径拼接出错
3. **维度坍缩**：报 `No vector column found to match with the query vector dimension: 192`，中途换了 Embedding 模型但 LanceDB 建表维度锁死，768 维向量插 192 维的表，原地爆炸

**正确配置（白嫖 Gemini Embedding）：**

换模型前必须清空旧的 LanceDB 目录！

```json
"plugins": {
  "slots": { "memory": "memory-lancedb" },
  "entries": {
    "memory-lancedb": {
      "enabled": true,
      "config": {
        "autoCapture": true,
        "autoRecall": true,
        "embedding": {
          "apiKey": "你的_GOOGLE_API_KEY",
          "baseUrl": "https://generativelanguage.googleapis.com/v1beta/openai/",
          "model": "gemini-embedding-001",
          "dimensions": 768
        }
      }
    }
  }
}
```

清空命令：

```bash
rm -rf ~/.openclaw/memory/lancedb/
docker exec openclaw-gateway sh -c "find /home/node -iname '*lancedb*' -type d -exec rm -rf {} +" 2>/dev/null || true
docker compose restart openclaw-gateway
```

---

## 坑二：多 Agent 权限物理隔离导致的"401 连环灵车"

配了极度硬核的 Fallback 链路：Claude 挂了切 DeepSeek API。主控节点对话顺畅，但一艾特子 Agent，直接全军覆没：

```
FailoverError: No API key found for provider "custom-api-deepseek-com".
Auth store: /home/node/.openclaw/agents/secretary/agent/auth-profiles.json
```

原因：OpenClaw 多 Agent 的工作区和权限文件是**物理隔离**的。在根目录 openclaw.json 配全局 Key 不够用，每个子 Agent 都要有自己的 auth-profiles.json。

**解决办法：** 在主控配好后，批量同步到所有子 Agent：

```bash
for agent in pm analyst search secretary ainews monitor; do
  docker exec openclaw-gateway cp \
    /home/node/.openclaw/agents/main/agent/auth-profiles.json \
    /home/node/.openclaw/agents/${agent}/agent/auth-profiles.json
done
```

---

## 🚨 隐藏关卡（全网首发）：auth-profiles.json 的真正格式

官方文档在这里留了一个巨大黑洞，导致无数人卡在 401 怀疑人生。

很多人凭直觉，把 openclaw.json 里的配置拷过来，写了 `"mode": "api_key"` 和 `"apiKey": "sk-..."`，结果重启之后照样报 `No API key found`。

这是 OpenClaw 最致命的暗坑：

- 全局 `openclaw.json` 里：字段叫 `mode` 和 `apiKey`
- `auth-profiles.json` 里：字段叫 `type` 和 `key`（完全不一样！）

写 `apiKey` 会被默默丢弃，把你卡死在 Auth 阶段。

**文件路径：** `~/.openclaw/agents/<agent_id>/agent/auth-profiles.json`

**正确格式：**

```json
{
  "version": 1,
  "profiles": {
    "anthropic:default": {
      "provider": "anthropic",
      "type": "api_key",
      "key": "sk-ant-api03-你的Claude密钥"
    },
    "custom-api-deepseek-com:default": {
      "provider": "custom-api-deepseek-com",
      "type": "api_key",
      "key": "sk-你的DeepSeek密钥"
    },
    "google:default": {
      "provider": "google",
      "type": "api_key",
      "key": "AIzaSy-你的Gemini密钥"
    }
  },
  "usageStats": {}
}
```

**3 个保命细节：**

1. 必须有 `"version": 1`，缺了被当旧格式拒绝
2. 键名 `<provider>:default` 冒号前面必须完全匹配 `models.providers` 里的名字
3. 密钥字段叫 `key`，不是 `apiKey`

---

## 坑三：多 Bot 路由配置的 JSON Schema 陷阱

把 `bindings` 塞进 `agents.list` 里，或者少写个括号，直接喜提：

```
SyntaxError: JSON5: invalid end of input at 1:1
```

网关进程 SIGTERM 退出。

**正确的多 Bot 路由模板：**

```json
"channels": {
  "telegram": {
    "dmPolicy": "open",
    "allowFrom": ["*"],
    "accounts": {
      "default": { "botToken": "主控_TOKEN" },
      "pm": { "botToken": "产品经理_TOKEN" },
      "secretary": { "botToken": "秘书_TOKEN" }
    }
  }
},
"bindings": [
  { "agentId": "main", "match": { "channel": "telegram", "accountId": "default" } },
  { "agentId": "pm", "match": { "channel": "telegram", "accountId": "pm" } },
  { "agentId": "secretary", "match": { "channel": "telegram", "accountId": "secretary" } }
]
```

注意：`bindings` 是根节点，不要放在 agents 或 channels 里面。遇到配置起不来，先跑：

```bash
openclaw doctor --fix
```

---

## 坑四：本地显存刺客与 SSRF 防护网络

**OOM 警告：** 试图拉起 deepseek-70b-local，网关嘲讽：

```
Model loading was stopped... requires approximately 44.19 GB of memory
```

没有双卡 4090，老实下调跑 30B 量化模型。推荐 Qwen3-Coder-30B-A3B（MoE 架构，只激活 3B 参数，256K context，速度快）。本地模型切换 UI 下拉不显示，只能用命令：

```
/model lmstudio/huihui-qwen3-coder-30b-a3b-instruct-abliterated
```

**SSRF 拦截：** 想让情报 Agent 抓 GitHub 热榜，全被拦截：

```
Blocked: resolves to private/internal/special-use IP address
```

这是内置的 SSRF 防护。挂了透明代理（Fake-IP）时，公网域名被解析成内网 IP 会触发拦截，理顺 DNS 分流即可。

---

## 总结

多 Agent 时代已经来了。OpenClaw 这套架构底子硬核，模型 Fallback 容错、工具调用变通都做得扎实。

跨过 **向量维度对齐、多 Agent 权限隔离、严格的 JSON Schema 校验** 这三道门槛，后面的体验简直爽感拉满。看着这群挂载在不同 Token 上的 Agent 各司其职，赛博包工头的成就感无可比拟。

希望这篇排坑记录能帮你省下几瓶护肝片。如果遇到其他玄学报错，欢迎在评论区对暗号。🦩

---

**相关资源：**
- 完整配置模板：[neo-agent-lab](https://github.com/baobaodawang-creater/neo-agent-lab)
- 配置字段速查：[config-reference.md](https://github.com/baobaodawang-creater/neo-agent-lab/blob/main/docs/config-reference.md)
- 报错速查手册：[troubleshooting.md](https://github.com/baobaodawang-creater/neo-agent-lab/blob/main/docs/troubleshooting.md)
