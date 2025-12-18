# Multi-stage build for Spring Boot Wallet Application
# Optimized for production deployment

# Stage 1: Build
FROM gradle:8.5-jdk17-alpine AS build
WORKDIR /app

# Copy gradle wrapper and configuration files
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle

# Download dependencies (cached layer for faster rebuilds)
RUN ./gradlew dependencies --no-daemon || true

# Copy source code
COPY src ./src

# Build application (skip tests for faster builds, run tests separately in CI/CD)
RUN ./gradlew clean build -x test --no-daemon

# Verify JAR was created
RUN ls -lh /app/build/libs/

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring

# Copy JAR from build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Change ownership
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring:spring

# Expose application port
EXPOSE 8080

# Add labels for metadata
LABEL maintainer="wallet-app"
LABEL version="1.0"
LABEL description="Wallet Application - Spring Boot REST API"

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/api/v1/wallets || exit 1

# JVM optimization flags
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Run application with optimized JVM settings
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
