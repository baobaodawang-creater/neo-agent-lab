# 🟣 紫色的跳舞火烈鸟：手搓 OpenClaw 多 Agent 矩阵，我踩平了这些深坑

> **摘要：** 用三天时间从零部署了一套 OpenClaw 多 Agent 系统：一个本地网关，8 个分身 Agent，6 个独立 Telegram 机器人，主战模型 Claude Sonnet，备用 DeepSeek API，本地 LM Studio 兜底，外加 LanceDB 长期记忆。看官方文档觉得岁月静好，真跑起来终端满屏飘红。这篇不废话，只聊**实打实踩过的坑和最终跑通的正确配置**——可以直接抄作业。

*(注：在系统被报错折磨得死去活来时，我给 Agent 喂了个绝密暗号："🟣 紫色的跳舞火烈鸟 = 服务器彻底修好了"。看完这篇，保证你的火烈鸟也能跳起舞。)*

---

## 系统架构速览

| Agent ID | 核心模型 | Telegram 绑定 | 职责 |
|---|---|---|---|
| **main** | claude-sonnet-4-6 | `@Openclaw0_2026_bot` | 总指挥 🦞 |
| **pm** | claude-sonnet-4-6 | `@neopm0_bot` | 产品经理 📋 |
| **analyst** | gemini-3.1-pro-preview | 内部调用 | 深度分析师 🔍 |
| **search** | deepseek-chat | 内部调用 | 情报专员 🌐 |
| **secretary** | deepseek-chat | `@neoassist0_bot` | 私人秘书 |
| **fakao** | deepseek-chat | `@fakao2026_bot` | 法考助手 ⚖️ |
| **ainews** | deepseek-chat | `@ainews2026faked_bot` | AI情报播报 📰 |
| **monitor** | deepseek-chat | `@monitor0neo_bot` | 情报监控员 📡 |

> `analyst` 和 `search` 是被 main 内部调度的子 Agent，不需要独立 Telegram 入口。

---

## 坑一：LanceDB 记忆库的"降维打击"

想让 Agent 拥有长期记忆，内置的 `memory-lancedb` 插件是标配。但我被它卡了好几个小时。

### 报错三连

1. `Cannot find module '@lancedb/lancedb-linux-arm64-gnu'`  
   → 跨平台部署后原生依赖丢失，手动 `npm install` 补上

2. `404 models/text-embedding-004 is not found for API version v1main`  
   → OpenClaw 走 OpenAI 兼容协议，`baseUrl` 路径必须带 `/openai/` 后缀，否则路径拼接出错变成 `v1main`

3. `No vector column found to match with the query vector dimension: 192`  
   → **最坑的一个**：中途换了 Embedding 模型（比如从 192 维的 nomic 换到 768 维的 Gemini），LanceDB 建表时维度是锁死的，新旧维度冲突直接炸。

### 正确配置（白嫖 Gemini Embedding）

**换模型前必须清空旧的 LanceDB 存储目录！**

```bash
rm -rf ~/.openclaw/memory/lancedb/
# Docker 部署时：
docker exec openclaw-gateway sh -c "find /home/node -iname '*lancedb*' -type d -exec rm -rf {} +" 2>/dev/null || true
```

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

> ⚠️ 注意：`text-embedding-004` 不一定在所有 Google API Key 下都有权限。先用这个命令确认你的 Key 支持哪些模型：
> ```bash
> curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=你的KEY" | jq '[.models[].name] | map(select(contains("embed")))'
> ```
> 如果只看到 `gemini-embedding-001`，就用它，别用 `text-embedding-004`。

### 彩蛋：Agent 的工具 Fallback 能力

在 LanceDB 崩溃存不进向量库时，我发了那句"紫色的跳舞火烈鸟"。Agent 发现 `memory_store` 工具调用失败，居然自己变通，调用了文件写入工具，**把暗号直接写进了工作区的 `MEMORY.md` 纯文本文件里做持久化**。后来查询时，依然准确回答出来了。大模型的工具 Fallback 能力，确实有点东西。

---

## 坑二：多 Agent 权限物理隔离导致的"401 连环灵车"

主控节点对话顺畅，一艾特子 Agent（比如小秘书），直接全军覆没：

```
FailoverError: No API key found for provider "custom-api-deepseek-com".
Auth store: /home/node/.openclaw/agents/secretary/agent/auth-profiles.json
```

### 根因

**在 OpenClaw 里，多 Agent 的工作区和权限文件是物理隔离的。** 每个 Agent 都有自己专属的 `auth-profiles.json`。在根目录 `openclaw.json` 里配全局 API Key 不够，子 Agent 只认自己目录下的文件。

### 修复

```bash
# 用 openclaw 命令给每个子 Agent 配置权限
openclaw agents add <agent_id>

# 或者直接物理同步（先确保主控目录的格式正确）
for agent in pm analyst search secretary fakao ainews monitor; do
  docker exec openclaw-gateway cp \
    /home/node/.openclaw/agents/main/agent/auth-profiles.json \
    /home/node/.openclaw/agents/${agent}/agent/auth-profiles.json
  echo "done: $agent"
done
```

---

## 🚨 隐藏关卡（全网首发）：`auth-profiles.json` 的真正格式

这是整篇最有价值的部分，因为官方文档在这里留了一个巨大的黑洞。

日志报：`Configure auth for this agent... or copy auth-profiles.json from the main agentDir.`

很多人凭直觉把 `openclaw.json` 里的配置格式抄过来，或者照旧文档写 `"mode": "api_key"` 和 `"apiKey": "sk-..."`——结果重启照样报 `No API key found`。

**这里藏着 OpenClaw 目前最坑的暗坑：**

- 全局 `openclaw.json` 里，认证字段叫 `mode` 和 `apiKey`
- 但在 `auth-profiles.json` 沙箱文件里，底层校验的字段叫 `type` 和 `key`！
- 写 `apiKey`，它会默默丢弃，然后无情卡死在 Auth 阶段

这是被报错毒打几十遍、翻烂源码后逆向扒出来的**满血版正确格式**：

**文件路径：** `~/.openclaw/agents/<agent_id>/agent/auth-profiles.json`

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

### ⚠️ 三个保命细节

**1. 节点命名规则 `<provider>:default`：**  
外层键名（如 `"custom-api-deepseek-com:default"`）冒号前面必须严丝合缝地匹配 `openclaw.json` 的 `models.providers` 里定义的名字。差一个横杠都不行。

**2. 千万别写 `apiKey`：**  
鉴权类型是 `"type": "api_key"`，密钥值是 `"key": "..."`。写 `apiKey` 直接丢弃。

**3. 必须有 `"version": 1`：**  
新版 OpenClaw 校验文件时要求这个字段，缺了会被认为是旧格式而拒绝。

---

## 坑三：手搓 JSON5 被 `openclaw doctor` 无情教育

手动编辑 `openclaw.json` 时犯的错：把 `bindings` 塞进了 `agents.list` 里，或者手滑少写括号——下场就是 `SyntaxError: JSON5: invalid end of input at 1:1`，网关进程直接 `SIGTERM` 退出。

### 正确的多 Bot 路由模板

```json
"channels": {
  "telegram": {
    "enabled": true,
    "dmPolicy": "open",
    "allowFrom": ["*"],
    "accounts": {
      "default": { "botToken": "主控_TOKEN" },
      "pm": { "botToken": "产品经理_TOKEN" },
      "secretary": { "botToken": "秘书_TOKEN" },
      "fakao": { "botToken": "法考_TOKEN" },
      "ainews": { "botToken": "AI新闻_TOKEN" },
      "monitor": { "botToken": "监控_TOKEN" }
    }
  }
},
"bindings": [
  { "agentId": "main", "match": { "channel": "telegram", "accountId": "default" } },
  { "agentId": "pm", "match": { "channel": "telegram", "accountId": "pm" } },
  { "agentId": "secretary", "match": { "channel": "telegram", "accountId": "secretary" } },
  { "agentId": "fakao", "match": { "channel": "telegram", "accountId": "fakao" } },
  { "agentId": "ainews", "match": { "channel": "telegram", "accountId": "ainews" } },
  { "agentId": "monitor", "match": { "channel": "telegram", "accountId": "monitor" } }
]
```

### 配置起不来，先跑这个

```bash
openclaw doctor --fix
```

遇到网关起不来，无脑敲这个命令。它会自动删废弃字段、补齐安全策略。

### 配置字段避坑速查

| 字段 | 正确写法 | 错误写法 |
|---|---|---|
| Brave Search Key | `tools.web.search.apiKey` | `tools.web.search.brave.apiKey` |
| Telegram 多账号 | `channels.telegram.accounts` | `channels.telegram.main` |
| Bindings | 根节点独立数组 | `agents.list[x].bindings` |
| dmPolicy open | 必须配 `allowFrom: ["*"]` | 单独设 open 不配 allowFrom |

---

## 坑四：别挑战显存上限与 SSRF 防护

**OOM 警告：**  
试图加载 `deepseek-70b-local`，网关嘲讽：`Model loading was stopped... requires approximately 44.19 GB of memory`。

没有充足统一内存的机器，请老实跑 30B 量化模型（推荐 Qwen3-Coder-30B-A3B abliterated，MoE 架构只激活 3B 参数，速度快，context 256K）。

**本地模型切换方式：**  
UI 下拉列表不显示 LM Studio 自定义模型，只能用命令切换：

```
/model lmstudio/huihui-qwen3-coder-30b-a3b-instruct-abliterated
```

**SSRF 防护拦截：**  
`web_fetch` 报 `Blocked: resolves to private/internal/special-use IP address`，这不是 Bug，是内置 SSRF 防护。透明代理（如 Fake-IP）把公网域名解析成内网 IP 就会触发。理顺 DNS 分流即可。

---

## 总结

多 Agent 时代已经来了，搭好脚手架只是第一步。OpenClaw 这套架构的底子相当硬核：解耦、模型 Fallback 容错、工具调用变通都做得扎实。

只要你跨过了 **向量维度对齐、多 Agent 权限隔离、严格的 JSON Schema 校验、auth-profiles.json 正确格式** 这几道门槛，后面的体验简直爽感拉满。

希望这篇踩坑记录能帮你省下几瓶护肝片。如果遇到其他玄学报错，欢迎在 Issue 里对暗号。🦩

---

## 附录：常用维护命令

```bash
# 重启网关
docker compose -f ~/openclaw/docker-compose.yml restart openclaw-gateway

# 查错误日志
docker logs openclaw-gateway --tail 20 2>&1 | grep -i "error\|invalid\|fallback"

# 清空 LanceDB 重建
rm -rf ~/openclaw/config/memory/lancedb/
docker exec openclaw-gateway sh -c "find /home/node -iname '*lancedb*' -type d -exec rm -rf {} +" 2>/dev/null || true
docker compose -f ~/openclaw/docker-compose.yml restart openclaw-gateway

# 同步 auth 到所有子 Agent
for agent in pm analyst search secretary fakao ainews monitor; do
  docker exec openclaw-gateway cp \
    /home/node/.openclaw/agents/main/agent/auth-profiles.json \
    /home/node/.openclaw/agents/${agent}/agent/auth-profiles.json
done

# 配置验证
openclaw doctor --fix
```
