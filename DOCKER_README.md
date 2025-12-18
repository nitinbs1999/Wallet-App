# Wallet Application - Docker Deployment

**Production-ready containerized Spring Boot REST API for wallet management**

---

## 🚀 Quick Start (3 Steps)

### 1. Prerequisites
```bash
# Verify Docker is installed
docker --version
docker-compose --version
```

### 2. Start Application
```bash
docker-compose up -d
```

### 3. Test API
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "user123", "ownerName": "John Doe", "balance": 1000}'
```

**That's it!** 🎉 Your application is running at http://localhost:8080

---

## 📦 What's Included

### Services
- **Wallet API** - Spring Boot 3.4.12 application (Port 8080)
- **PostgreSQL 16** - Database (Port 5432)
- **pgAdmin** - Database UI (Port 5050, optional)

### Features
- ✅ Multi-stage Docker build (optimized size)
- ✅ Health checks for all services
- ✅ Automatic database initialization
- ✅ Non-root user for security
- ✅ Volume persistence
- ✅ Network isolation
- ✅ Production-ready configuration

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| **DOCKER_SETUP.md** | Complete setup and configuration guide |
| **DEPLOYMENT_CHECKLIST.md** | Step-by-step deployment checklist |
| **CURL_COMMANDS.md** | API testing examples |
| **LOAD_TEST_REPORT.md** | Performance benchmarks |

---

## 🛠️ Common Commands

### Start/Stop

```bash
# Start (detached)
docker-compose up -d

# Start (with logs)
docker-compose up

# Stop
docker-compose down

# Stop and remove data
docker-compose down -v
```

### Logs and Monitoring

```bash
# View logs
docker-compose logs -f

# View specific service
docker-compose logs -f wallet-app

# Check status
docker-compose ps

# Resource usage
docker stats
```

### Rebuild

```bash
# Rebuild and restart
docker-compose up -d --build

# Rebuild without cache
docker-compose build --no-cache
docker-compose up -d
```

---

## 🔧 Configuration

### Change Ports

Edit `compose.yaml`:
```yaml
services:
  wallet-app:
    ports:
      - "8081:8080"  # Use port 8081
```

### Change Database Credentials

Edit `compose.yaml`:
```yaml
services:
  postgres:
    environment:
      POSTGRES_PASSWORD: your_secure_password
```

### Adjust Memory

Edit `compose.yaml`:
```yaml
services:
  wallet-app:
    environment:
      JAVA_OPTS: "-Xms512m -Xmx1024m"
```

---

## 🧪 Testing

### API Endpoints

**Create Wallet:**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Test", "balance": 1000}'
```

**Get Balance:**
```bash
curl http://localhost:8080/api/v1/wallets/test123/balance
```

**Deposit:**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/test123/deposit \
  -H "Content-Type: application/json" \
  -d '{"type": "DEPOSIT", "amount": 500}'
```

**Withdraw:**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/test123/withdraw \
  -H "Content-Type: application/json" \
  -d '{"type": "WITHDRAW", "amount": 200}'
```

### Load Testing

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Run load test (100 requests, 10 concurrent)
ab -n 100 -c 10 http://localhost:8080/api/v1/wallets/test123/balance
```

---

## 🗄️ Database Access

### Using psql

```bash
docker exec -it wallet-postgres psql -U postgres -d test_db
```

### Using pgAdmin

1. Start with tools profile:
   ```bash
   docker-compose --profile tools up -d
   ```

2. Access: http://localhost:5050
   - Email: admin@wallet.com
   - Password: admin

3. Add server:
   - Host: postgres
   - Port: 5432
   - Database: test_db
   - Username: postgres
   - Password: postgres

---

## 💾 Backup and Restore

### Backup Database

```bash
docker exec wallet-postgres pg_dump -U postgres test_db > backup.sql
```

### Restore Database

```bash
docker exec -i wallet-postgres psql -U postgres test_db < backup.sql
```

### Backup Volumes

```bash
docker run --rm \
  -v wallet-app_postgres-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz /data
```

---

## 🚨 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs wallet-app

# Check status
docker-compose ps

# Restart
docker-compose restart
```

### Port Already in Use

```bash
# Find process
lsof -i :8080

# Change port in compose.yaml
ports:
  - "8081:8080"
```

### Database Connection Failed

```bash
# Check PostgreSQL
docker-compose logs postgres

# Verify health
docker exec wallet-postgres pg_isready -U postgres

# Restart database
docker-compose restart postgres
```

### Application Errors

```bash
# View detailed logs
docker-compose logs --tail=200 wallet-app

# Access container
docker exec -it wallet-app sh

# Check Java process
docker exec wallet-app ps aux
```

---

## 📊 Performance

### Benchmarks (from load testing)

| Metric | Value |
|--------|-------|
| **Throughput** | 390 req/s (GET) |
| **Throughput** | 297 req/s (POST) |
| **Response Time (p50)** | 151ms |
| **Response Time (p95)** | 649ms |
| **Failed Requests** | 0% |

**Tested with:** 100 concurrent connections, 1000 requests

See `LOAD_TEST_REPORT.md` for detailed analysis.

---

## 🔒 Security

### Production Checklist

- [ ] Change default database password
- [ ] Use environment variables for secrets
- [ ] Enable HTTPS/SSL
- [ ] Restrict database port access
- [ ] Set up firewall rules
- [ ] Configure log rotation
- [ ] Enable audit logging
- [ ] Regular security updates

### Using Secrets

Create `.env` file:
```bash
POSTGRES_PASSWORD=secure_password_here
```

Update `compose.yaml`:
```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

---

## 📦 Deployment to Another Machine

### Option 1: Using Deployment Script

```bash
# Create deployment package
./docker-deploy.sh

# Copy to target machine
scp wallet-app-*.tar.gz user@target:/path/

# On target machine
tar -xzf wallet-app-*.tar.gz
cd wallet-app-deploy
./start.sh
```

### Option 2: Using Docker Registry

```bash
# Tag image
docker tag wallet-app:latest myregistry/wallet-app:1.0.0

# Push to registry
docker push myregistry/wallet-app:1.0.0

# On target machine
docker pull myregistry/wallet-app:1.0.0
docker-compose up -d
```

### Option 3: Manual Transfer

```bash
# Save image
docker save wallet-app:latest | gzip > wallet-app.tar.gz

# Copy to target
scp wallet-app.tar.gz user@target:/path/

# On target machine
docker load < wallet-app.tar.gz
docker-compose up -d
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Docker Network (bridge)         │
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │  Wallet App  │───▶│  PostgreSQL  │  │
│  │  (Port 8080) │    │  (Port 5432) │  │
│  └──────────────┘    └──────────────┘  │
│         │                    │          │
└─────────┼────────────────────┼──────────┘
          │                    │
          ▼                    ▼
    [Host:8080]          [Host:5432]
```

### Components

- **Application Layer**: Spring Boot REST API
- **Data Layer**: PostgreSQL with persistent volumes
- **Network Layer**: Isolated Docker network
- **Security Layer**: Non-root users, health checks

---

## 📝 Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `SPRING_DATASOURCE_URL` | jdbc:postgresql://postgres:5432/test_db | Database URL |
| `SPRING_DATASOURCE_USERNAME` | postgres | Database user |
| `SPRING_DATASOURCE_PASSWORD` | postgres | Database password |
| `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE` | 20 | Max connections |
| `JAVA_OPTS` | -Xms256m -Xmx512m | JVM options |
| `LOGGING_LEVEL_ROOT` | INFO | Log level |

---

## 🆘 Support

### Getting Help

1. **Check logs**: `docker-compose logs -f`
2. **Review documentation**: See DOCKER_SETUP.md
3. **Check health**: `docker-compose ps`
4. **Verify configuration**: `docker-compose config`

### Common Issues

| Issue | Solution |
|-------|----------|
| Port conflict | Change port in compose.yaml |
| Out of memory | Increase JAVA_OPTS memory |
| Database connection | Check postgres logs |
| Slow performance | Increase connection pool |

---

## 📄 License

This project is part of the Wallet Application.

---

## 🎯 Next Steps

1. ✅ Start application: `docker-compose up -d`
2. ✅ Test API endpoints (see CURL_COMMANDS.md)
3. ✅ Review configuration (see DOCKER_SETUP.md)
4. ✅ Set up monitoring and backups
5. ✅ Deploy to production (see DEPLOYMENT_CHECKLIST.md)

---

**Need more details?** See `DOCKER_SETUP.md` for comprehensive documentation.
