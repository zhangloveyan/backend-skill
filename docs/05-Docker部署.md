# Docker Compose 部署指南

> 本文档提供基于 Docker Compose 的完整部署方案。

## 文档版本

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-06 | 初始版本 |

---

## 使用说明（模板）

- 本文档内容为模板示例，实际使用需根据项目调整。
- 必须替换：`PROJECT_NAME`、端口、数据库/缓存账号、JWT 密钥、MQTT 账号等敏感配置。
- 服务裁剪：未使用的服务（如 `emqx`、`prometheus`、`grafana`）可删除对应服务与卷。
- Nginx 路由需与接口规范保持一致（`/{project}/{端类型}/v{版本}`），并替换配置中的 `{project}`。
- 脚本中的容器名/目录需与 `PROJECT_NAME`、实际部署目录一致。

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
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443
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
      - "${NGINX_HTTP_PORT}:80"
      - "${NGINX_HTTPS_PORT}:443"
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

    # 管理后台（匹配 /{project}/web/...）
    location /{project}/web/ {
        proxy_pass http://admin_server/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }

    # API 接口（匹配 /{project}/api/...）
    location /{project}/api/ {
        proxy_pass http://api_server/;
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

---

## 9. 私有化部署方案

### 9.1 目录结构

```
docker/
├── envs/
│   ├── .env.template          # 环境变量模板
│   ├── .env.company-a         # A公司配置
│   ├── .env.company-b         # B公司配置
│   └── .env.company-c         # C公司配置
├── docker-compose.yml         # 通用编排文件
└── scripts/
    └── deploy.sh              # 部署脚本
```

### 9.2 环境变量模板 (.env.template)

```bash
# ========== 客户信息 ==========
CUSTOMER_NAME=company-name
CUSTOMER_CODE=company-code

# ========== 项目配置 ==========
PROJECT_NAME=myproject
COMPOSE_PROJECT_NAME=${CUSTOMER_CODE}-myproject

# ========== 端口配置 ==========
APP_ADMIN_PORT=9501
APP_API_PORT=9502
MYSQL_PORT=3306
REDIS_PORT=6379
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

# ========== 数据库配置 ==========
MYSQL_HOST=mysql
MYSQL_DATABASE=${CUSTOMER_CODE}_db
MYSQL_ROOT_PASSWORD=change_me_root_password
MYSQL_USER=app_user
MYSQL_PASSWORD=change_me_app_password

# ========== Redis 配置 ==========
REDIS_HOST=redis
REDIS_PASSWORD=change_me_redis_password

# ========== MQTT 配置 ==========
MQTT_HOST=emqx
MQTT_PORT=1883
MQTT_USERNAME=admin
MQTT_PASSWORD=change_me_mqtt_password

# ========== JWT 配置 ==========
JWT_SECRET=change_me_jwt_secret_key

# ========== 应用配置 ==========
SPRING_PROFILES_ACTIVE=prod
JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC
TZ=Asia/Shanghai

# ========== 域名配置 ==========
DOMAIN_ADMIN=admin.${CUSTOMER_CODE}.example.com
DOMAIN_API=api.${CUSTOMER_CODE}.example.com
```

### 9.3 客户配置示例

**A公司配置 (.env.company-a)**
```bash
CUSTOMER_NAME=A科技有限公司
CUSTOMER_CODE=company-a
COMPOSE_PROJECT_NAME=company-a-myproject

MYSQL_DATABASE=company_a_db
MYSQL_ROOT_PASSWORD=CompanyA_Root_2024!
MYSQL_PASSWORD=CompanyA_App_2024!
REDIS_PASSWORD=CompanyA_Redis_2024!
JWT_SECRET=CompanyA_JWT_Secret_Key_2024

DOMAIN_ADMIN=admin.company-a.example.com
DOMAIN_API=api.company-a.example.com
```

**B公司配置 (.env.company-b)**
```bash
CUSTOMER_NAME=B集团
CUSTOMER_CODE=company-b
COMPOSE_PROJECT_NAME=company-b-myproject

MYSQL_DATABASE=company_b_db
MYSQL_ROOT_PASSWORD=CompanyB_Root_2024!
MYSQL_PASSWORD=CompanyB_App_2024!
REDIS_PASSWORD=CompanyB_Redis_2024!
JWT_SECRET=CompanyB_JWT_Secret_Key_2024

DOMAIN_ADMIN=admin.company-b.example.com
DOMAIN_API=api.company-b.example.com
```

### 9.4 部署命令

```bash
# 部署 A 公司
docker-compose --env-file envs/.env.company-a up -d

# 部署 B 公司
docker-compose --env-file envs/.env.company-b up -d

# 查看 A 公司服务状态
docker-compose --env-file envs/.env.company-a ps

# 查看 B 公司日志
docker-compose --env-file envs/.env.company-b logs -f

# 停止 A 公司服务
docker-compose --env-file envs/.env.company-a down
```

### 9.5 私有化部署脚本

```bash
#!/bin/bash
# scripts/deploy-customer.sh

CUSTOMER=$1
ENV_FILE="envs/.env.${CUSTOMER}"

if [ -z "$CUSTOMER" ]; then
    echo "Usage: $0 <customer-code>"
    echo "Example: $0 company-a"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file not found: $ENV_FILE"
    exit 1
fi

echo "Deploying for customer: $CUSTOMER"
echo "Using env file: $ENV_FILE"

# 部署
docker-compose --env-file $ENV_FILE pull
docker-compose --env-file $ENV_FILE up -d

# 显示状态
docker-compose --env-file $ENV_FILE ps

echo "Deployment completed for: $CUSTOMER"
```

### 9.6 注意事项

1. **密码安全**：每个客户使用独立的强密码
2. **数据隔离**：每个客户使用独立的数据库
3. **端口规划**：多客户部署在同一服务器时需规划端口
4. **备份策略**：按客户独立备份数据
5. **配置管理**：.env 文件不要提交到版本库
