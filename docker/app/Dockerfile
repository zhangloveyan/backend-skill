FROM eclipse-temurin:17-jdk-alpine

LABEL maintainer="your-email@example.com"

# 设置工作目录
WORKDIR /app

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装必要工具
RUN apk add --no-cache curl

# 创建非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 复制 JAR 文件
ARG JAR_FILE=app.jar
COPY target/${JAR_FILE} app.jar

# 创建日志目录
RUN mkdir -p /app/logs && chown -R appuser:appgroup /app

# 切换用户
USER appuser

# JVM 参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 暴露端口
EXPOSE 9501 9502

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:${SERVER_PORT:-9501}/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
