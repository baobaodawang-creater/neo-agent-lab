#!/bin/bash
# 常用维护命令集合

COMPOSE_FILE="$HOME/openclaw/docker-compose.yml"
CONTAINER="openclaw-gateway"

# 重启网关
restart() {
  echo "重启 OpenClaw 网关..."
  docker compose -f "$COMPOSE_FILE" restart "$CONTAINER"
  echo "等待启动..."
  sleep 5
  docker logs "$CONTAINER" --tail 5 2>&1 | grep -i "listening\|error\|invalid"
}

# 查错误日志
logs() {
  docker logs "$CONTAINER" --tail 30 2>&1 | grep -i "error\|invalid\|fallback\|401"
}

# 清空记忆库重建
reset_memory() {
  echo "清空 LanceDB 记忆库..."
  rm -rf "$HOME/openclaw/config/memory/lancedb/"
  docker exec "$CONTAINER" sh -c "find /home/node -iname '*lancedb*' -type d -exec rm -rf {} +" 2>/dev/null || true
  restart
}

# 同步 auth 到所有子 Agent
sync_auth() {
  echo "同步 auth-profiles.json 到所有子 Agent..."
  for agent in pm analyst search secretary fakao ainews monitor; do
    docker exec "$CONTAINER" cp \
      /home/node/.openclaw/agents/main/agent/auth-profiles.json \
      /home/node/.openclaw/agents/${agent}/agent/auth-profiles.json
    echo "done: $agent"
  done
}

# 备份配置
backup() {
  BACKUP_FILE="$HOME/openclaw-backup-$(date +%Y%m%d-%H%M%S).json"
  cp "$HOME/openclaw/config/openclaw.json" "$BACKUP_FILE"
  echo "配置已备份到: $BACKUP_FILE"
}

# 查 agent 状态
status() {
  docker exec "$CONTAINER" openclaw agents list 2>&1
}

# 帮助
help() {
  echo "用法: ./scripts/maintain.sh <命令>"
  echo ""
  echo "命令:"
  echo "  restart      重启网关"
  echo "  logs         查错误日志"
  echo "  reset_memory 清空记忆库重建"
  echo "  sync_auth    同步 auth 到所有子 Agent"
  echo "  backup       备份配置"
  echo "  status       查 agent 状态"
}

# 执行命令
case "$1" in
  restart) restart ;;
  logs) logs ;;
  reset_memory) reset_memory ;;
  sync_auth) sync_auth ;;
  backup) backup ;;
  status) status ;;
  *) help ;;
esac
