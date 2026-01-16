#!/bin/bash
# 回滚脚本
# 用法: ./rollback.sh [admin|api] [version]

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

# 列出可用版本
list_versions() {
    local service=$1
    log_info "可用的 $service 版本:"
    docker images "${PROJECT_NAME}-${service}" --format "{{.Tag}}\t{{.CreatedAt}}" | head -10
}

# 回滚到指定版本
rollback() {
    local service=$1
    local version=$2

    if [ -z "$version" ]; then
        log_error "请指定版本号"
        list_versions "$service"
        exit 1
    fi

    log_info "回滚 $service 到版本 $version..."

    cd "$DOCKER_DIR"

    # 停止当前服务
    docker-compose stop "app-$service"

    # 更新镜像标签
    docker tag "${PROJECT_NAME}-${service}:${version}" "${PROJECT_NAME}-${service}:latest"

    # 启动服务
    docker-compose up -d "app-$service"

    log_info "回滚完成!"
}

# 主函数
main() {
    local service="${1:-admin}"
    local version="$2"

    case "$service" in
        admin|api)
            if [ -z "$version" ]; then
                list_versions "$service"
            else
                rollback "$service" "$version"
            fi
            ;;
        *)
            echo "用法: $0 [admin|api] [version]"
            exit 1
            ;;
    esac
}

main "$@"
