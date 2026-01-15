FROM eclipse-temurin:17-jdk-alpine

LABEL maintainer="{maintainer}"

WORKDIR /app

# 通用参数（按需替换）
ARG JAR_FILE={JAR_FILE}
ARG APP_PORT={APP_PORT}
ENV JAVA_OPTS="-Xms1g -Xmx2g -XX:+UseG1GC"

COPY ${JAR_FILE} app.jar

EXPOSE ${APP_PORT}

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
