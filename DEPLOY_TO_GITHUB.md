# 任务：把 neo-agent-lab 目录推送到 GitHub

## 背景
workspace/neo-agent-lab/ 目录下是一个完整的 GitHub 仓库结构，需要你帮我推送到 GitHub。

## 步骤

1. 检查 git 是否可用：
```bash
git --version
```

2. 进入目录并初始化：
```bash
cd ~/workspace/neo-agent-lab
git init
git add .
git commit -m "初始提交：OpenClaw 多 Agent 系统部署手册"
```

3. 在 GitHub 创建仓库（需要我提供 GitHub token）：
- 仓库名：`neo-agent-lab`
- 描述：自托管多 Agent AI 系统，基于 OpenClaw 构建
- 可见性：Public

4. 推送：
```bash
git remote add origin https://github.com/用户名/neo-agent-lab.git
git branch -M main
git push -u origin main
```

## 注意
- 推送前确认 configs/ 里的 .example 文件没有真实 API Key
- 如果需要 GitHub token，告诉我，我来提供
