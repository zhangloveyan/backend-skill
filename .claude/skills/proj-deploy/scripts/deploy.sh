#!/bin/bash
# 部署脚本
# 用法: ./deploy.sh [admin|api|all] [build]

set -e

# 配置
PROJECT_NAME="${PROJECT_NAME:-myproject}"
DOCKER_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查环境
check_env() {
    if [ ! -f "$DOCKER_DIR/.env" ]; then
        log_error ".env 文件不存在，请从 .env.template 复制并配置"
        exit 1
    fi

    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装"
        exit 1
    fi
}

# 构建镜像
build_image() {
    local service=$1
    log_info "构建 $service 镜像..."
    cd "$DOCKER_DIR"
    docker-compose build "$service"
}

# 部署服务
deploy_service() {
    local service=$1
    log_info "部署 $service..."
    cd "$DOCKER_DIR"
    docker-compose up -d "$service"
    log_info "$service 部署完成"
}

# 重启服务
restart_service() {
    local service=$1
    log_info "重启 $service..."
    cd "$DOCKER_DIR"
    docker-compose restart "$service"
}

# 查看日志
show_logs() {
    local service=$1
    cd "$DOCKER_DIR"
    docker-compose logs -f --tail=100 "$service"
}

# 健康检查
health_check() {
    local service=$1
    local port=$2
    local max_attempts=30
    local attempt=1

    log_info "等待 $service 启动..."
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
            log_info "$service 健康检查通过"
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
    done

    log_error "$service 健康检查失败"
    return 1
}

# 主函数
main() {
    local target="${1:-all}"
    local action="${2:-deploy}"

    check_env

    case "$target" in
        admin)
            [ "$action" = "build" ] && build_image "app-admin"
            deploy_service "app-admin"
            health_check "app-admin" 9501
            ;;
        api)
            [ "$action" = "build" ] && build_image "app-api"
            deploy_service "app-api"
            health_check "app-api" 9502
            ;;
        all)
            [ "$action" = "build" ] && {
                build_image "app-admin"
                build_image "app-api"
            }
            cd "$DOCKER_DIR"
            docker-compose up -d
            health_check "app-admin" 9501
            health_check "app-api" 9502
            ;;
        logs)
            show_logs "${2:-app-admin}"
            ;;
        *)
            echo "用法: $0 [admin|api|all|logs] [build]"
            exit 1
            ;;
    esac

    log_info "部署完成!"
}

main "$@"
