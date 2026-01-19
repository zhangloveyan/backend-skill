# Docker Compose 完整配置

## 生产环境 (docker-compose.yml)

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
      - JWT_SECRET=${JWT_SECRET}
      - TZ=${TZ}
    volumes:
      - ./logs/api:/app/logs
    depends_on:
      - mysql
      - redis
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
      - "${NGINX_HTTP_PORT:-80}:80"
      - "${NGINX_HTTPS_PORT:-443}:443"
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

networks:
  app-network:
    driver: bridge

volumes:
  mysql-data:
  redis-data:
```

---

## 开发环境 (docker-compose.dev.yml)

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: ${PROJECT_NAME}-mysql-dev
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - TZ=${TZ}
    volumes:
      - mysql-dev-data:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    networks:
      - dev-network

  redis:
    image: redis:7-alpine
    container_name: ${PROJECT_NAME}-redis-dev
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis-dev-data:/data
    networks:
      - dev-network

networks:
  dev-network:
    driver: bridge

volumes:
  mysql-dev-data:
  redis-dev-data:
```

---

## 可选服务

### MQTT Broker (EMQX)

```yaml
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
```

### 监控 (Prometheus + Grafana)

```yaml
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
```
