#!/bin/bash
# 备份脚本
# 用法: ./backup.sh [mysql|redis|all]

set -e

# 配置
PROJECT_NAME="${PROJECT_NAME:-myproject}"
BACKUP_DIR="${BACKUP_DIR:-/data/backup}"
KEEP_DAYS="${KEEP_DAYS:-7}"
DATE=$(date +%Y%m%d_%H%M%S)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 创建备份目录
mkdir -p "$BACKUP_DIR/mysql"
mkdir -p "$BACKUP_DIR/redis"

# 备份 MySQL
backup_mysql() {
    log_info "备份 MySQL..."
    local backup_file="$BACKUP_DIR/mysql/${PROJECT_NAME}_${DATE}.sql.gz"

    docker exec ${PROJECT_NAME}-mysql mysqldump \
        -u"${MYSQL_USER}" \
        -p"${MYSQL_PASSWORD}" \
        --single-transaction \
        --routines \
        --triggers \
        "${MYSQL_DATABASE}" | gzip > "$backup_file"

    log_info "MySQL 备份完成: $backup_file"
}

# 备份 Redis
backup_redis() {
    log_info "备份 Redis..."
    local backup_file="$BACKUP_DIR/redis/${PROJECT_NAME}_${DATE}.rdb"

    docker exec ${PROJECT_NAME}-redis redis-cli \
        -a "${REDIS_PASSWORD}" \
        --no-auth-warning \
        BGSAVE

    sleep 5

    docker cp ${PROJECT_NAME}-redis:/data/dump.rdb "$backup_file"

    log_info "Redis 备份完成: $backup_file"
}

# 清理旧备份
cleanup_old_backups() {
    log_info "清理 ${KEEP_DAYS} 天前的备份..."
    find "$BACKUP_DIR" -type f -mtime +${KEEP_DAYS} -delete
}

# 主函数
main() {
    local target="${1:-all}"

    case "$target" in
        mysql)
            backup_mysql
            ;;
        redis)
            backup_redis
            ;;
        all)
            backup_mysql
            backup_redis
            ;;
        *)
            echo "用法: $0 [mysql|redis|all]"
            exit 1
            ;;
    esac

    cleanup_old_backups
    log_info "备份任务完成!"
}

main "$@"
