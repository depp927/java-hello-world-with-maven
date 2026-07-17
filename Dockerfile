# ==========================================
# 第一阶段：构建阶段 (Build Stage)
# ==========================================
# 使用包含 Maven 和 JDK 8 的官方镜像进行代码编译
# 因为项目使用的是 Java 8，所以这里选择 openjdk:8-jdk-alpine
FROM maven:3.8-openjdk-8 AS builder

# 设置工作目录
WORKDIR /app

# 先复制 pom.xml 并下载依赖（利用 Docker 缓存层，加速后续构建）
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 复制源代码并执行打包命令
COPY src ./src
RUN mvn clean package -DskipTests

# ==========================================
# 第二阶段：运行阶段 (Runtime Stage)
# ==========================================
# 使用轻量级的 JRE 镜像作为最终运行环境
FROM openjdk:8-jre-alpine

# 设置工作目录
WORKDIR /app

# 从第一阶段复制打包好的 jar 文件
# 注意：这里假设 pom.xml 中的 artifactId 为 java-hello-world-with-maven
# 如果你的项目打包名称不同，请根据实际情况修改
COPY --from=builder /app/target/java-hello-world-with-maven-1.0-SNAPSHOT.jar app.jar

# 暴露应用默认端口（假设 Spring Boot 默认端口为 8080）
EXPOSE 8080

# 容器启动时执行的命令
ENTRYPOINT ["java", "-jar", "app.jar"]
