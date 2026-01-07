# Docker Compose 部署指南

> 本文档提供基于 Docker Compose 的完整部署方案。

## 文档版本

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-06 | 初始版本 |

---

## 1. 服务清单

| 服务 | 镜像 | 端口 | 说明 |
|------|------|------|------|
| {project}-admin | 自定义 | 9501 | 管理后台服务 |
| {project}-api | 自定义 | 9502 | API 服务 |
| mysql | mysql:8.0 | 3306 | 数据库 |
| redis | redis:7-alpine | 6379 | 缓存 |
| nginx | nginx:alpine | 80/443 | 反向代理 |
| emqx | emqx:5 | 1883/18083 | MQTT Broker |
| prometheus | prom/prometheus | 9090 | 监控采集 |
| grafana | grafana/grafana | 3000 | 监控面板 |

---

## 2. 目录结构

```
docker/
├── docker-compose.yml          # 生产环境配置
├── docker-compose.dev.yml      # 开发环境配置
├── .env                        # 环境变量
├── app/
│   └── Dockerfile              # 应用镜像
├── nginx/
│   ├── nginx.conf              # Nginx 主配置
│   └── conf.d/
│       └── default.conf        # 站点配置
├── mysql/
│   └── init.sql                # 初始化脚本
├── prometheus/
│   └── prometheus.yml          # Prometheus 配置
└── scripts/
    ├── deploy.sh               # 部署脚本
    ├── backup.sh               # 备份脚本
    └── rollback.sh             # 回滚脚本
```

---

## 3. 环境变量配置

### 3.1 .env 文件

```bash
# ========== 项目配置 ==========
PROJECT_NAME=myproject
COMPOSE_PROJECT_NAME=myproject

# ========== 应用配置 ==========
APP_ADMIN_PORT=9501
APP_API_PORT=9502
SPRING_PROFILES_ACTIVE=prod
JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC

# ========== MySQL 配置 ==========
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=myproject
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_USER=app_user
MYSQL_PASSWORD=your_app_password

# ========== Redis 配置 ==========
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password

# ========== MQTT 配置 ==========
MQTT_HOST=emqx
MQTT_PORT=1883
MQTT_USERNAME=admin
MQTT_PASSWORD=your_mqtt_password

# ========== JWT 配置 ==========
JWT_SECRET=your_jwt_secret_key

# ========== 时区 ==========
TZ=Asia/Shanghai
```

---

## 4. Docker Compose 配置

### 4.1 生产环境 (docker-compose.yml)

```yaml
version: '3.8'

services:
  # ==================== 应用服务 ====================
  app-admin:
    build:
      context: .
      dockerfile: app/Dockerfile
      args:
        JAR_FILE: ${PROJECT_NAME}-admin.jar
    image: ${PROJECT_NAME}-admin:latest
    container_name: ${PROJECT_NAME}-admin
    restart: always
    ports:
      - "${APP_ADMIN_PORT}:9501"
    environment:
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
      - JAVA_OPTS=${JAVA_OPTS}
      - MYSQL_HOST=${MYSQL_HOST}
      - MYSQL_PORT=${MYSQL_PORT}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
      - REDIS_PASSWORD=${REDIS_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - TZ=${TZ}
    volumes:
      - ./logs/admin:/app/logs
      - ./uploads:/app/uploads
    depends_on:
      - mysql
      - redis
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9501/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  app-api:
    build:
      context: .
      dockerfile: app/Dockerfile
      args:
        JAR_FILE: ${PROJECT_NAME}-api.jar
    image: ${PROJECT_NAME}-api:latest
    container_name: ${PROJECT_NAME}-api
    restart: always
    ports:
      - "${APP_API_PORT}:9502"
    environment:
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
      - JAVA_OPTS=${JAVA_OPTS}
      - MYSQL_HOST=${MYSQL_HOST}
      - MYSQL_PORT=${MYSQL_PORT}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
      - REDIS_PASSWORD=${REDIS_PASSWORD}
      - MQTT_HOST=${MQTT_HOST}
      - MQTT_PORT=${MQTT_PORT}
      - MQTT_USERNAME=${MQTT_USERNAME}
      - MQTT_PASSWORD=${MQTT_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - TZ=${TZ}
    volumes:
      - ./logs/api:/app/logs
    depends_on:
      - mysql
      - redis
      - emqx
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9502/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ==================== 数据库 ====================
  mysql:
    image: mysql:8.0
    container_name: ${PROJECT_NAME}-mysql
    restart: always
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - TZ=${TZ}
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ==================== 缓存 ====================
  redis:
    image: redis:7-alpine
    container_name: ${PROJECT_NAME}-redis
    restart: always
    ports:
      - "6379:6379"
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ==================== Nginx ====================
  nginx:
    image: nginx:alpine
    container_name: ${PROJECT_NAME}-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/nginx/ssl
      - ./logs/nginx:/var/log/nginx
    depends_on:
      - app-admin
      - app-api
    networks:
      - app-network

  # ==================== MQTT Broker ====================
  emqx:
    image: emqx:5
    container_name: ${PROJECT_NAME}-emqx
    restart: always
    ports:
      - "1883:1883"
      - "8083:8083"
      - "18083:18083"
    environment:
      - EMQX_DASHBOARD__DEFAULT_PASSWORD=${MQTT_PASSWORD}
    volumes:
      - emqx-data:/opt/emqx/data
      - emqx-log:/opt/emqx/log
    networks:
      - app-network

  # ==================== 监控 ====================
  prometheus:
    image: prom/prometheus:latest
    container_name: ${PROJECT_NAME}-prometheus
    restart: always
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - app-network

  grafana:
    image: grafana/grafana:latest
    container_name: ${PROJECT_NAME}-grafana
    restart: always
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql-data:
  redis-data:
  emqx-data:
  emqx-log:
  prometheus-data:
  grafana-data:
```

---

## 6. Nginx 配置

### 6.1 nginx.conf

```nginx
# docker/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'rt=$request_time uct=$upstream_connect_time';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript;

    # 上传文件大小限制
    client_max_body_size 50m;

    include /etc/nginx/conf.d/*.conf;
}
```

### 6.2 站点配置 (conf.d/default.conf)

```nginx
# docker/nginx/conf.d/default.conf
upstream admin_server {
    server app-admin:9501;
}

upstream api_server {
    server app-api:9502;
}

server {
    listen 80;
    server_name localhost;

    # 管理后台
    location /admin/ {
        proxy_pass http://admin_server/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }

    # API 接口
    location /api/ {
        proxy_pass http://api_server/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 健康检查
    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
```

---

## 7. 部署脚本

### 7.1 deploy.sh

```bash
#!/bin/bash
set -e

# 配置
DEPLOY_DIR="/opt/app"
BACKUP_DIR="/opt/app/backups"
LOG_FILE="/var/log/deploy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# 备份
backup() {
    log "开始备份..."
    BACKUP_NAME="backup_$(date +%Y%m%d%H%M%S)"
    mkdir -p $BACKUP_DIR/$BACKUP_NAME
    docker-compose config > $BACKUP_DIR/$BACKUP_NAME/docker-compose.yml.bak
    log "备份完成: $BACKUP_DIR/$BACKUP_NAME"
}

# 拉取镜像
pull() {
    log "拉取最新镜像..."
    docker-compose pull
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
    curl -sf http://localhost:9501/actuator/health || log "Admin 服务异常"
    curl -sf http://localhost:9502/actuator/health || log "API 服务异常"
}

# 清理
cleanup() {
    log "清理旧镜像..."
    docker image prune -f
}

# 主流程
main() {
    log "========== 开始部署 =========="
    cd $DEPLOY_DIR
    backup
    pull
    start
    health_check
    cleanup
    log "========== 部署完成 =========="
}

main "$@"
```

### 7.2 backup.sh

```bash
#!/bin/bash
set -e

BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d%H%M%S)

# 备份 MySQL
docker exec myproject-mysql mysqldump -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} > $BACKUP_DIR/mysql_$DATE.sql

# 备份 Redis
docker exec myproject-redis redis-cli -a ${REDIS_PASSWORD} BGSAVE

# 保留最近 7 天备份
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete

echo "备份完成: $BACKUP_DIR/mysql_$DATE.sql"
```

---

## 8. 常用命令

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose down

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f app-admin
docker-compose logs -f app-api

# 重启单个服务
docker-compose restart app-admin

# 重新构建并启动
docker-compose up -d --build

# 进入容器
docker exec -it myproject-mysql bash
docker exec -it myproject-redis redis-cli

# 查看资源使用
docker stats
```
