#!/bin/bash
set -e

# ========================================
# 部署脚本
# ========================================

# 配置
DEPLOY_DIR="${DEPLOY_DIR:-/opt/app}"
BACKUP_DIR="${DEPLOY_DIR}/backups"
LOG_FILE="/var/log/deploy.log"
MAX_BACKUPS=10

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a $LOG_FILE
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1" | tee -a $LOG_FILE
}

# 检查 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker 未安装"
    fi
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose 未安装"
    fi
    log "Docker 环境检查通过"
}

# 备份
backup() {
    log "开始备份..."
    BACKUP_NAME="backup_$(date +%Y%m%d%H%M%S)"
    mkdir -p $BACKUP_DIR/$BACKUP_NAME

    # 备份配置
    docker-compose config > $BACKUP_DIR/$BACKUP_NAME/docker-compose.yml.bak 2>/dev/null || true
    cp .env $BACKUP_DIR/$BACKUP_NAME/.env.bak 2>/dev/null || true

    # 清理旧备份
    cd $BACKUP_DIR
    ls -dt */ | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -rf 2>/dev/null || true

    log "备份完成: $BACKUP_DIR/$BACKUP_NAME"
}

# 拉取镜像
pull() {
    log "拉取最新镜像..."
    docker-compose pull
}

# 停止服务
stop() {
    log "停止服务..."
    docker-compose down --remove-orphans
}

# 启动服务
start() {
    log "启动服务..."
    docker-compose up -d
}

# 健康检查
health_check() {
    log "健康检查..."
    sleep 15

    local admin_healthy=false
    local api_healthy=false

    for i in {1..5}; do
        if curl -sf http://localhost:9501/actuator/health > /dev/null 2>&1; then
            admin_healthy=true
            break
        fi
        sleep 5
    done

    for i in {1..5}; do
        if curl -sf http://localhost:9502/actuator/health > /dev/null 2>&1; then
            api_healthy=true
            break
        fi
        sleep 5
    done

    if [ "$admin_healthy" = true ]; then
        log "Admin 服务健康"
    else
        warn "Admin 服务异常"
    fi

    if [ "$api_healthy" = true ]; then
        log "API 服务健康"
    else
        warn "API 服务异常"
    fi
}

# 清理
cleanup() {
    log "清理旧镜像..."
    docker image prune -f
}

# 显示状态
status() {
    docker-compose ps
}

# 主流程
deploy() {
    log "========== 开始部署 =========="
    cd $DEPLOY_DIR
    check_docker
    backup
    pull
    stop
    start
    health_check
    cleanup
    status
    log "========== 部署完成 =========="
}

# 帮助
usage() {
    echo "Usage: $0 {deploy|start|stop|restart|status|backup|cleanup}"
    echo ""
    echo "Commands:"
    echo "  deploy   - 完整部署流程"
    echo "  start    - 启动服务"
    echo "  stop     - 停止服务"
    echo "  restart  - 重启服务"
    echo "  status   - 查看状态"
    echo "  backup   - 备份配置"
    echo "  cleanup  - 清理旧镜像"
}

# 入口
case "$1" in
    deploy)
        deploy
        ;;
    start)
        cd $DEPLOY_DIR && start
        ;;
    stop)
        cd $DEPLOY_DIR && stop
        ;;
    restart)
        cd $DEPLOY_DIR && stop && start
        ;;
    status)
        cd $DEPLOY_DIR && status
        ;;
    backup)
        cd $DEPLOY_DIR && backup
        ;;
    cleanup)
        cleanup
        ;;
    *)
        usage
        exit 1
        ;;
esac
