# 🟣 部署踩坑手册

> 三天从零部署 OpenClaw 多 Agent 系统踩过的所有坑，以及最终跑通的正确配置。

## 坑一：LanceDB 记忆库维度冲突

### 报错

```
No vector column found to match with the query vector dimension: 192
404 models/text-embedding-004 is not found for API version v1main
Cannot find module '@lancedb/lancedb-linux-arm64-gnu'
```

### 根因

- 中途换 Embedding 模型（如从 192 维 nomic 换到 768 维 Gemini），LanceDB 建表维度锁死，新旧冲突
- `baseUrl` 路径缺 `/openai/` 后缀，路径拼接错误变成 `v1main`
- 更新容器后原生依赖丢失

### 修复

```bash
# 换模型前必须清空旧库
rm -rf ~/.openclaw/memory/lancedb/
docker exec openclaw-gateway sh -c "find /home/node -iname '*lancedb*' -type d -exec rm -rf {} +" 2>/dev/null || true
docker compose restart openclaw-gateway

# 依赖丢失时
docker exec openclaw-gateway sh -c "cd /app/extensions/memory-lancedb && npm install openai"
```

### 正确配置

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
          "apiKey": "${GOOGLE_API_KEY}",
          "baseUrl": "https://generativelanguage.googleapis.com/v1beta/openai/",
          "model": "gemini-embedding-001",
          "dimensions": 768
        }
      }
    }
  }
}
```

> ⚠️ 先确认你的 Key 支持哪些 embedding 模型：
> ```bash
> curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=你的KEY" \
>   | jq '[.models[].name] | map(select(contains("embed")))'
> ```

---

## 坑二：多 Agent 权限物理隔离

### 报错

```
No API key found for provider "custom-api-deepseek-com".
Auth store: /home/node/.openclaw/agents/secretary/agent/auth-profiles.json
```

### 根因

OpenClaw 多 Agent 权限物理隔离，每个 Agent 只认自己目录下的 `auth-profiles.json`，全局配置不够用。

### 修复

```bash
# 先配好 main 的 auth，再同步到所有子 Agent
for agent in pm analyst search secretary fakao ainews monitor; do
  docker exec openclaw-gateway cp \
    /home/node/.openclaw/agents/main/agent/auth-profiles.json \
    /home/node/.openclaw/agents/${agent}/agent/auth-profiles.json
  echo "done: $agent"
done
```

---

## 🚨 隐藏关卡：auth-profiles.json 正确格式（全网首发）

官方文档在这里有坑，很多人照旧文档写 `"apiKey"` 结果照样 401。

**关键区别：**
- 全局 `openclaw.json` 里：`mode` + `apiKey`
- `auth-profiles.json` 里：`type` + `key`（不一样！）

### 正确格式

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

### 三个保命细节

1. **必须有 `"version": 1`**，新版 OpenClaw 要求，缺了被当旧格式拒绝
2. **键名 `<provider>:default`**，冒号前面必须完全匹配 `models.providers` 里的名字
3. **密钥字段叫 `key`，不是 `apiKey`**，写错默默丢弃

---

## 坑三：Telegram 多 Bot 路由配置

### 错误写法

```json
// ❌ 错误：把 bindings 塞进 agents.list
"agents": {
  "list": [
    { "id": "main", "bindings": [...] }  // 不支持！
  ]
}

// ❌ 错误：直接用 key 名配置账号
"channels": {
  "telegram": {
    "main": { "botToken": "..." }  // 不支持！
  }
}
```

### 正确写法

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

> ⚠️ `dmPolicy: "open"` 必须配套 `allowFrom: ["*"]`，否则报错

---

## 坑四：本地模型 OOM 与 SSRF 拦截

### 本地模型 OOM

```
Model loading was stopped... requires approximately 44.19 GB of memory
```

DeepSeek 70B 需要约 44GB，M5 Max 64GB 加上系统开销会触发保护。改用 Qwen3-Coder-30B-A3B（MoE 架构，只激活 3B 参数，速度快，256K context）。

**本地模型切换方式（UI 下拉不显示，只能用命令）：**

```
/model lmstudio/huihui-qwen3-coder-30b-a3b-instruct-abliterated
```

### SSRF 防护拦截

```
Blocked: resolves to private/internal/special-use IP address
```

透明代理（Fake-IP）把公网域名解析成内网 IP 触发内置 SSRF 防护，理顺 DNS 分流即可。
