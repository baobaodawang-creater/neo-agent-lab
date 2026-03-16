# 配置字段速查

openclaw.json 关键字段说明，按模块拆解。

## gateway — 网关设置

- mode: local = 单机模式
- bind: lan = 监听局域网 / localhost = 仅本机
- port: 访问端口，默认 18789
- auth.token: 建议 32 位随机字符串

## agents — Agent 列表

- defaults.model.primary: 默认主模型
- defaults.model.fallbacks: 主模型失败时自动切换
- defaults.models: 白名单，不在这里的模型无法使用
- defaults.timeoutSeconds: 超时时间，本地模型建议设 600

## models — 模型提供商

- anthropic.api: 固定值 anthropic-messages
- deepseek.api: openai-completions，兼容 OpenAI 格式
- google.api: 固定值 google-generative-ai
- lmstudio.baseUrl: http://host.docker.internal:1234/v1
- lmstudio.models: 本地模型必须手动声明，contextWindow 建议保守设置

## channels + bindings — Telegram 多 Bot

- channels.telegram.dmPolicy: open = 接受所有人私信
- channels.telegram.allowFrom: ["*"] 不限来源，dmPolicy=open 时必须配套
- bindings: 根节点，不要放在 agents 或 channels 里面

## plugins — 记忆系统

- embedding.baseUrl: 必须有 /openai/ 后缀，缺了路径拼接出错
- embedding.model: gemini-embedding-001
- embedding.dimensions: 768，改了必须清库重建

## 字段名易错对照表

| 位置 | 错误写法 | 正确写法 |
|------|----------|----------|
| auth-profiles.json | apiKey | key |
| auth-profiles.json | mode | type |
| auth-profiles.json | 缺少顶层字段 | version: 1 |
| embedding.baseUrl | .../v1beta/ | .../v1beta/openai/ |
| bindings | 放在 agents 里 | 放在根节点 |
