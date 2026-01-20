---
name: proj-deploy
description: 生成Docker Compose、Dockerfile、Nginx等部署配置。用于项目初始化部署配置、新增服务需要部署、查看部署配置模板。
---

# 部署配置

## 任务文档同步

- 确认全流程任务文档存在（如有）
- 将部署相关文件路径记录到“扩展产物”
- 上下文快照记录部署环境与关键约束
- 更新下一步指令为“部署验证/回归测试”

## 部署架构

```
                    ┌─────────────┐
                    │   Nginx     │ :80/:443
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
    ┌──────▼──────┐ ┌──────▼──────┐
    │ app-admin   │ │  app-api    │
    │   :9501     │ │   :9502     │
    └──────┬──────┘ └──────┬──────┘
           └───────┬───────┘
    ┌──────────────┼──────────────┐
┌───▼───┐    ┌─────▼─────┐
│ MySQL │    │   Redis   │
│ :3306 │    │   :6379   │
└───────┘    └───────────┘
```

---

## 目录结构

```
docker/
├── docker-compose.yml
├── .env
├── .env.template
├── app/
│   └── Dockerfile
├── nginx/
│   ├── nginx.conf
│   └── conf.d/
│       └── default.conf
└── scripts/
    └── deploy.sh
```

---

## 环境变量模板 (.env.template)

```bash
PROJECT_NAME=myproject
COMPOSE_PROJECT_NAME=myproject

APP_ADMIN_PORT=9501
APP_API_PORT=9502
SPRING_PROFILES_ACTIVE=prod
JAVA_OPTS=-Xms512m -Xmx1g -XX:+UseG1GC

MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=myproject
MYSQL_ROOT_PASSWORD=change_me
MYSQL_USER=app_user
MYSQL_PASSWORD=change_me

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=change_me

JWT_SECRET=change_me_at_least_32_chars

TZ=Asia/Shanghai
```

---

## Dockerfile

```dockerfile
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ARG JAR_FILE
COPY ${JAR_FILE} app.jar

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget -q --spider http://localhost:${SERVER_PORT:-8080}/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
```

---

## Nginx 配置

```nginx
upstream admin-server {
    server app-admin:9501;
}

upstream api-server {
    server app-api:9502;
}

server {
    listen 80;
    server_name localhost;

    location /{project}/web/ {
        proxy_pass http://admin-server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /{project}/api/ {
        proxy_pass http://api-server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 常用命令

```bash
# 启动
docker-compose up -d

# 停止
docker-compose down

# 查看日志
docker-compose logs -f app-admin

# 重启
docker-compose restart app-admin

# 重新构建
docker-compose up -d --build
```

---

## 注意事项

1. **敏感信息** - `.env` 文件不要提交到 Git
2. **端口冲突** - 确保端口未被占用
3. **数据持久化** - 使用 volume 持久化数据
4. **健康检查** - 配置合理的健康检查
5. **任务文档同步** - 记录部署产物路径与验证状态
