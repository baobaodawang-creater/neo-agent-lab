# 报错速查手册

快速定位报错根因，直接复制修复命令。

## 配置类报错

| 报错 | 根因 | 修复 |
|------|------|------|
| `JSON5: invalid end of input` | config 文件被清空或截断 | 从 `.bak` 备份恢复 |
| `Unrecognized key: "bindings"` | bindings 放在 agents.list 里 | 移到根节点 |
| `Unrecognized key: "apiKey"` | tools.web.search 格式错 | 改为 `tools.web.search.apiKey` |
| `Config invalid` | 字段名错误 | 运行 `openclaw doctor --fix` |

## 认证类报错

| 报错 | 根因 | 修复 |
|------|------|------|
| `HTTP 401 authentication_error` | API Key 失效或写错字段 | 重新生成 Key，注意 `key` 不是 `apiKey` |
| `No API key found for provider` | 子 Agent auth-profiles.json 缺失 | 同步主控目录的 auth 文件 |
| `model not allowed` | allowlist 没有该模型 | 在 `agents.defaults.models` 里添加 |

## 记忆类报错

| 报错 | 根因 | 修复 |
|------|------|------|
| `dimension: 192` 冲突 | 换了 embedding 模型没清库 | 清空 lancedb 目录重建 |
| `v1main` 404 | baseUrl 缺 `/openai/` 后缀 | 改为 `.../v1beta/openai/` |
| `Cannot find module @lancedb` | 容器更新后依赖丢失 | `npm install openai` |

## 模型类报错

| 报错 | 根因 | 修复 |
|------|------|------|
| `LLM request timed out` | 本地模型推理太慢超时 | 换更小的模型或减少 context |
| `context size exceeded` | prompt 超过模型上限 | 发 `/compact` 压缩历史 |
| `OOM / insufficient memory` | 模型太大 | 换 30B 量化模型 |

## 常用诊断命令

```bash
# 查最新报错
docker logs openclaw-gateway --tail 20 2>&1 | grep -i "error\|invalid\|fallback"

# 自动修复配置
docker exec openclaw-gateway openclaw doctor --fix

# 查所有 agent 状态
docker exec openclaw-gateway openclaw agents list

# 查 Telegram 绑定
docker exec openclaw-gateway openclaw channels list
```
