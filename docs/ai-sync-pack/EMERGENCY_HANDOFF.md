# 紧急交接手册

> **用途**：如果 Claude 账号不可用，拿此文件给 ChatGPT/Codex，它可以立即接手所有项目。
> 最后更新：2026-03-17

---

## 紧急状态下的操作优先级

### P0：保持 OpenClaw 运行
```bash
# 检查容器状态
docker ps | grep openclaw

# 如果容器挂了
docker compose -f ~/openclaw/docker-compose.yml up -d

# 查看日志排错
docker logs openclaw-gateway --tail 50
```

### P1：确保 Telegram Bot 正常
```bash
# 检查 bot 是否在线（发消息看有没有回复）
# 如果无回复，重启容器
docker compose -f ~/openclaw/docker-compose.yml restart openclaw-gateway
```

### P2：GitHub 仓库维护
```bash
# 容器内 push 更新
docker exec openclaw-gateway sh -c "
cd /home/node/.openclaw/workspace/neo-agent-lab && \
git add . && git commit -m 'maintenance update' && git push
"
```

---

## 关键文件位置速查

| 文件 | 路径 | 说明 |
|------|------|------|
| 主配置 | `~/openclaw/config/openclaw.json` | OpenClaw 核心配置 |
| API Keys | `~/openclaw/config/auth-profiles.json` | ⚠️ 敏感文件 |
| Docker | `~/openclaw/docker-compose.yml` | 容器编排 |
| Agent Workspace | `~/openclaw/workspace/` | SOUL.md 和工作文件 |
| 新闻 cron | `~/openclaw/daily_news.sh` | AI 新闻日报脚本 |
| 代理脚本 | `~/openclaw/superintern_proxy.py` | Super Intern API 包装 |
| 法考资料 | 具体路径待确认 | marker 转换后的 MD 文件 |

---

## 各项目当前状态和待办

### neo-agent-lab
- ✅ 7 个 Agent 配置完成
- ✅ LanceDB 记忆系统正常（768维 Gemini embedding）
- ✅ GitHub 仓库已建立
- ⬜ 博客文章待发布（掘金/知乎）
- ⬜ 小红书爬虫 Phase 1（卡在 461 反爬状态码）

### moot-court-ai
- ✅ 4 角色 SOUL.md 已写好
- ✅ Lobster 工作流已设计
- ⬜ WebChat 路由 bug 未修（下拉框切 Agent 不生效）
- ⬜ 考虑独立轻量版方案（脱离 OpenClaw）
- ⬜ 审判规则知识库扩展（目前只有民间借贷纠纷）

### 法考备考
- ✅ PDF → MD 转换流程已通
- ✅ @fakao2026_bot 已上线
- ⬜ 更多科目资料入库
- ⬜ 模拟题训练功能

---

## 排错决策树

```
问题：Agent 不回消息
├── 检查容器是否在跑：docker ps
│   ├── 没跑 → docker compose up -d
│   └── 在跑 → 看日志：docker logs openclaw-gateway --tail 30
│       ├── auth 报错 → 检查 auth-profiles.json 格式（必须 version:1）
│       ├── embedding 维度报错 → 检查 baseUrl 大小写，清空 lancedb 重建
│       ├── timeout → 检查 openclaw.json 里 timeoutSeconds 是否够大
│       └── 模型报错 → 检查 API Key 是否有效，余额是否够

问题：Git push 失败
├── 在容器内操作 → 确认路径正确（/home/node/.openclaw/workspace/）
├── token 过期 → GitHub Settings → Fine-grained tokens → 重新生成
└── 权限不够 → 确认 token 有目标仓库的 Contents Read/Write 权限

问题：LM Studio 模型不响应
├── 检查 LM Studio 是否在 Windows 机器上运行
├── 确认端口 1234 可达：curl http://[Windows-IP]:1234/v1/models
└── 上下文窗口：不要超过 24576 tokens（70B 模型）
```

---

## 给 ChatGPT/Codex 的角色定位

```
你现在接替 Claude 的工作，以下是你的角色：

1. 你是 Neo（李浩辰）的技术伙伴
2. 你的主要职责是代码执行和快速迭代
3. 架构级决策先记录下来，等 Claude 恢复后再确认
4. 日常维护、bug 修复、代码生成你来做
5. 保持中文沟通，技术术语用英文
6. 不要啰嗦，直接给方案和代码
7. 遇到不确定的架构问题，标记为 [NEEDS_CLAUDE_REVIEW] 留给 Claude
```

---

## 安全提醒

- ⚠️ auth-profiles.json 里有 API Key，不要上传到公开仓库
- ⚠️ GitHub Personal Access Token 用完就撤销
- ⚠️ OpenClaw gateway 只绑定 127.0.0.1，不要暴露到公网
- ⚠️ Tailscale Funnel 方案已放弃（安全风险太大）
