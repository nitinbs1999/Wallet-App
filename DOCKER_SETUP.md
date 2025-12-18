# Docker Setup Guide - Wallet Application

Complete guide for containerizing and deploying the Wallet Application.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Docker Files Overview](#docker-files-overview)
4. [Deployment Options](#deployment-options)
5. [Configuration](#configuration)
6. [Troubleshooting](#troubleshooting)
7. [Production Deployment](#production-deployment)

---

## Prerequisites

### Required Software

- **Docker Engine**: 20.10 or higher
- **Docker Compose**: 2.0 or higher (included with Docker Desktop)
- **Minimum Resources**:
  - 2GB RAM
  - 10GB disk space
  - 2 CPU cores

### Installation

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**macOS/Windows:**
- Download [Docker Desktop](https://www.docker.com/products/docker-desktop)

**Verify Installation:**
```bash
docker --version
docker-compose --version
```

---

## Quick Start

### Option 1: Using Helper Scripts (Easiest)

```bash
# Start application
./docker-run.sh up

# View logs
./docker-run.sh logs

# Stop application
./docker-run.sh stop
```

### Option 2: Using Docker Compose Directly

```bash
# Start in foreground (see logs)
docker-compose up

# Start in background (detached)
docker-compose up -d

# Stop application
docker-compose down

# Stop and remove all data
docker-compose down -v
```

### Option 3: Build and Run Manually

```bash
# Build image
./docker-build.sh

# Run with compose
docker-compose up -d
```

---

## Docker Files Overview

### 1. Dockerfile
Multi-stage build for optimized production image:
- **Stage 1**: Build with Gradle
- **Stage 2**: Runtime with JRE only
- **Size**: ~200MB (vs ~800MB with full JDK)

### 2. compose.yaml
Complete stack definition:
- **wallet-app**: Spring Boot application
- **postgres**: PostgreSQL 16 database
- **pgadmin**: Database management UI (optional)

### 3. .dockerignore
Excludes unnecessary files from build context:
- Build artifacts
- IDE files
- Documentation
- Test results

### 4. init-db.sql
Database initialization script (runs on first start)

---

## Deployment Options

### Local Development

```bash
# Start with live logs
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f wallet-app

# Restart after code changes
docker-compose up -d --build
```

### Production Deployment

```bash
# Build optimized image
docker-compose build --no-cache

# Start with restart policy
docker-compose up -d

# Check health
docker-compose ps
curl http://localhost:8080/api/v1/wallets
```

### Deploy to Another Machine

```bash
# Create deployment package
./docker-deploy.sh

# Copy to target machine
scp wallet-app-*.tar.gz user@target-machine:/path/

# On target machine
tar -xzf wallet-app-*.tar.gz
cd wallet-app-deploy
./start.sh
```

---

## Configuration

### Environment Variables

Edit `compose.yaml` to customize:

```yaml
environment:
  # Database
  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/test_db
  SPRING_DATASOURCE_USERNAME: postgres
  SPRING_DATASOURCE_PASSWORD: postgres
  
  # Connection Pool
  SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE: 20
  SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE: 5
  
  # JVM Options
  JAVA_OPTS: "-Xms256m -Xmx512m -XX:+UseG1GC"
  
  # Logging
  LOGGING_LEVEL_ROOT: INFO
  LOGGING_LEVEL_COM_WALLET_APP: DEBUG
```

### Port Configuration

Change exposed ports in `compose.yaml`:

```yaml
services:
  wallet-app:
    ports:
      - "8081:8080"  # Use port 8081 instead of 8080
  
  postgres:
    ports:
      - "5433:5432"  # Use port 5433 instead of 5432
```

### Resource Limits

Add resource constraints:

```yaml
services:
  wallet-app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

---

## Accessing Services

### Application Endpoints

- **API Base URL**: http://localhost:8080/api/v1/wallets
- **Health Check**: http://localhost:8080/api/v1/wallets (any endpoint)

### Database Access

**Direct Connection:**
```bash
docker exec -it wallet-postgres psql -U postgres -d test_db
```

**pgAdmin (if enabled):**
- URL: http://localhost:5050
- Email: admin@wallet.com
- Password: admin

To enable pgAdmin:
```bash
docker-compose --profile tools up -d
```

---

## Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker-compose logs wallet-app
docker-compose logs postgres
```

**Check container status:**
```bash
docker-compose ps
```

**Restart services:**
```bash
docker-compose restart
```

### Port Already in Use

**Error:** `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Solution:**
```bash
# Find process using port
lsof -i :8080
# Or
netstat -tulpn | grep 8080

# Kill process or change port in compose.yaml
```

### Database Connection Failed

**Check PostgreSQL is healthy:**
```bash
docker-compose ps postgres
docker-compose logs postgres
```

**Verify connection:**
```bash
docker exec wallet-postgres pg_isready -U postgres
```

**Reset database:**
```bash
docker-compose down -v
docker-compose up -d
```

### Application Crashes

**Check memory:**
```bash
docker stats wallet-app
```

**Increase memory limit:**
```yaml
environment:
  JAVA_OPTS: "-Xms512m -Xmx1024m"
```

### Build Failures

**Clear Docker cache:**
```bash
docker system prune -a
docker-compose build --no-cache
```

**Check disk space:**
```bash
docker system df
```

---

## Production Deployment

### Security Hardening

**1. Change default passwords:**
```yaml
environment:
  POSTGRES_PASSWORD: ${DB_PASSWORD}  # Use secrets
```

**2. Use secrets management:**
```bash
# Create .env file (don't commit!)
echo "DB_PASSWORD=secure_password_here" > .env
```

**3. Enable HTTPS:**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

### Monitoring

**Add health checks:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/wallets"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

**View health status:**
```bash
docker inspect wallet-app | grep -A 10 Health
```

### Backup and Restore

**Backup database:**
```bash
docker exec wallet-postgres pg_dump -U postgres test_db > backup.sql
```

**Restore database:**
```bash
docker exec -i wallet-postgres psql -U postgres test_db < backup.sql
```

**Backup volumes:**
```bash
docker run --rm -v wallet-app_postgres-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/postgres-backup.tar.gz /data
```

### Scaling

**Run multiple app instances:**
```yaml
services:
  wallet-app:
    deploy:
      replicas: 3
```

**Use load balancer:**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      - wallet-app
```

---

## Useful Commands

### Container Management

```bash
# View running containers
docker-compose ps

# View all containers
docker ps -a

# Stop all containers
docker-compose down

# Remove all containers and volumes
docker-compose down -v

# Restart specific service
docker-compose restart wallet-app

# View resource usage
docker stats
```

### Logs and Debugging

```bash
# Follow logs
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100 wallet-app

# Save logs to file
docker-compose logs > logs.txt

# Execute command in container
docker exec -it wallet-app sh

# View container details
docker inspect wallet-app
```

### Image Management

```bash
# List images
docker images

# Remove unused images
docker image prune -a

# Tag image for registry
docker tag wallet-app:latest myregistry/wallet-app:1.0.0

# Push to registry
docker push myregistry/wallet-app:1.0.0
```

---

## Testing the Deployment

### 1. Verify Services are Running

```bash
docker-compose ps
```

Expected output:
```
NAME              STATUS          PORTS
wallet-app        Up (healthy)    0.0.0.0:8080->8080/tcp
wallet-postgres   Up (healthy)    0.0.0.0:5432->5432/tcp
```

### 2. Test API Endpoints

```bash
# Create wallet
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Test User", "balance": 1000}'

# Get balance
curl http://localhost:8080/api/v1/wallets/test123/balance

# Deposit
curl -X POST http://localhost:8080/api/v1/wallets/test123/deposit \
  -H "Content-Type: application/json" \
  -d '{"type": "DEPOSIT", "amount": 500}'
```

### 3. Run Load Tests

```bash
# Copy test scripts into container
docker cp stress-test.sh wallet-app:/tmp/
docker exec wallet-app sh /tmp/stress-test.sh
```

---

## Additional Resources

- **Docker Documentation**: https://docs.docker.com
- **Docker Compose Reference**: https://docs.docker.com/compose/compose-file/
- **Spring Boot Docker Guide**: https://spring.io/guides/gs/spring-boot-docker/

---

## Support

For issues:
1. Check logs: `docker-compose logs -f`
2. Verify health: `docker-compose ps`
3. Review this guide's troubleshooting section
4. Check application logs inside container: `docker exec wallet-app cat /app/logs/application.log`
