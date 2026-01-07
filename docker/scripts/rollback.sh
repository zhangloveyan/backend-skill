#!/bin/bash
set -e

# 回滚脚本（模板）
# 请根据项目实际备份策略调整

BACKUP_DIR="/opt/app/backups"
LOG_FILE="/var/log/deploy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_name>"
    exit 1
fi

BACKUP_NAME="$1"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup not found: $BACKUP_PATH"
    exit 1
fi

log "开始回滚: $BACKUP_NAME"
cd /opt/app

if [ -f "$BACKUP_PATH/docker-compose.yml.bak" ]; then
    cp "$BACKUP_PATH/docker-compose.yml.bak" docker-compose.yml
    log "已恢复 docker-compose.yml"
fi

docker-compose up -d
log "回滚完成"
