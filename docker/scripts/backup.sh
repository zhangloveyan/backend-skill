#!/bin/bash
set -e

# ========================================
# 备份脚本
# ========================================

# 配置
BACKUP_DIR="${BACKUP_DIR:-/opt/backups}"
DATE=$(date +%Y%m%d%H%M%S)
KEEP_DAYS=7

# 颜色
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份 MySQL
backup_mysql() {
    log "备份 MySQL..."

    MYSQL_CONTAINER="${PROJECT_NAME:-myproject}-mysql"
    MYSQL_USER="${MYSQL_USER:-root}"
    MYSQL_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
    MYSQL_DATABASE="${MYSQL_DATABASE:-mydb}"

    docker exec $MYSQL_CONTAINER mysqldump \
        -u$MYSQL_USER \
        -p$MYSQL_PASSWORD \
        --single-transaction \
        --routines \
        --triggers \
        $MYSQL_DATABASE > $BACKUP_DIR/mysql_$DATE.sql

    # 压缩
    gzip $BACKUP_DIR/mysql_$DATE.sql

    log "MySQL 备份完成: $BACKUP_DIR/mysql_$DATE.sql.gz"
}

# 备份 Redis
backup_redis() {
    log "备份 Redis..."

    REDIS_CONTAINER="${PROJECT_NAME:-myproject}-redis"

    # 触发 RDB 保存
    docker exec $REDIS_CONTAINER redis-cli BGSAVE
    sleep 5

    # 复制 RDB 文件
    docker cp $REDIS_CONTAINER:/data/dump.rdb $BACKUP_DIR/redis_$DATE.rdb 2>/dev/null || true

    log "Redis 备份完成"
}

# 备份配置文件
backup_config() {
    log "备份配置文件..."

    CONFIG_DIR="${DEPLOY_DIR:-/opt/app}"

    tar -czf $BACKUP_DIR/config_$DATE.tar.gz \
        -C $CONFIG_DIR \
        .env \
        docker-compose.yml \
        nginx/ \
        2>/dev/null || true

    log "配置备份完成: $BACKUP_DIR/config_$DATE.tar.gz"
}

# 清理旧备份
cleanup_old() {
    log "清理 $KEEP_DAYS 天前的备份..."

    find $BACKUP_DIR -name "mysql_*.sql.gz" -mtime +$KEEP_DAYS -delete
    find $BACKUP_DIR -name "redis_*.rdb" -mtime +$KEEP_DAYS -delete
    find $BACKUP_DIR -name "config_*.tar.gz" -mtime +$KEEP_DAYS -delete

    log "清理完成"
}

# 列出备份
list_backups() {
    echo "=== MySQL 备份 ==="
    ls -lh $BACKUP_DIR/mysql_*.sql.gz 2>/dev/null || echo "无"

    echo ""
    echo "=== Redis 备份 ==="
    ls -lh $BACKUP_DIR/redis_*.rdb 2>/dev/null || echo "无"

    echo ""
    echo "=== 配置备份 ==="
    ls -lh $BACKUP_DIR/config_*.tar.gz 2>/dev/null || echo "无"
}

# 帮助
usage() {
    echo "Usage: $0 {all|mysql|redis|config|cleanup|list}"
    echo ""
    echo "Commands:"
    echo "  all     - 备份所有"
    echo "  mysql   - 备份 MySQL"
    echo "  redis   - 备份 Redis"
    echo "  config  - 备份配置"
    echo "  cleanup - 清理旧备份"
    echo "  list    - 列出备份"
}

# 入口
case "$1" in
    all)
        backup_mysql
        backup_redis
        backup_config
        cleanup_old
        ;;
    mysql)
        backup_mysql
        ;;
    redis)
        backup_redis
        ;;
    config)
        backup_config
        ;;
    cleanup)
        cleanup_old
        ;;
    list)
        list_backups
        ;;
    *)
        usage
        exit 1
        ;;
esac

log "备份任务完成"
