# Deployment Checklist - Wallet Application

Use this checklist when deploying to a new machine or environment.

---

## Pre-Deployment

### ☐ Prerequisites Verified

- [ ] Docker Engine installed (20.10+)
- [ ] Docker Compose installed (2.0+)
- [ ] Minimum 2GB RAM available
- [ ] Minimum 10GB disk space available
- [ ] Ports 8080 and 5432 are available
- [ ] User has Docker permissions (`docker ps` works)

**Verify:**
```bash
docker --version
docker-compose --version
docker ps
df -h
free -h
```

---

## Deployment Package

### ☐ Files Included

- [ ] Dockerfile
- [ ] compose.yaml
- [ ] .dockerignore
- [ ] init-db.sql
- [ ] build.gradle
- [ ] settings.gradle
- [ ] gradlew
- [ ] gradle/ directory
- [ ] src/ directory
- [ ] DOCKER_SETUP.md
- [ ] start.sh / stop.sh scripts

**Create Package:**
```bash
./docker-deploy.sh
```

---

## Initial Setup

### ☐ Transfer Files

- [ ] Copy deployment package to target machine
- [ ] Extract package: `tar -xzf wallet-app-*.tar.gz`
- [ ] Navigate to directory: `cd wallet-app-deploy/`
- [ ] Verify all files present: `ls -la`

### ☐ Configuration Review

- [ ] Review `compose.yaml` for environment-specific settings
- [ ] Update database credentials if needed
- [ ] Adjust port mappings if conflicts exist
- [ ] Set resource limits if required
- [ ] Configure logging levels

**Edit Configuration:**
```bash
nano compose.yaml
```

---

## Build and Start

### ☐ Build Application

- [ ] Build Docker image: `docker-compose build`
- [ ] Verify image created: `docker images | grep wallet-app`
- [ ] Check image size (should be ~200MB)

**Build Command:**
```bash
docker-compose build --no-cache
```

### ☐ Start Services

- [ ] Start containers: `docker-compose up -d`
- [ ] Wait for services to be healthy (60 seconds)
- [ ] Check container status: `docker-compose ps`
- [ ] Verify both containers are "Up (healthy)"

**Start Command:**
```bash
docker-compose up -d
sleep 60
docker-compose ps
```

---

## Verification

### ☐ Service Health Checks

- [ ] PostgreSQL is running: `docker-compose ps postgres`
- [ ] Application is running: `docker-compose ps wallet-app`
- [ ] No error logs: `docker-compose logs --tail=50`
- [ ] Health check passing: `docker inspect wallet-app | grep Health`

**Check Health:**
```bash
docker-compose ps
docker-compose logs --tail=50 wallet-app
```

### ☐ Database Connectivity

- [ ] Connect to database: `docker exec -it wallet-postgres psql -U postgres -d test_db`
- [ ] List tables: `\dt`
- [ ] Verify wallets table exists
- [ ] Verify transactions table exists
- [ ] Exit: `\q`

**Database Check:**
```bash
docker exec -it wallet-postgres psql -U postgres -d test_db -c "\dt"
```

### ☐ API Endpoint Tests

- [ ] Test health endpoint (any API call)
- [ ] Create test wallet
- [ ] Get wallet balance
- [ ] Perform deposit
- [ ] Perform withdrawal
- [ ] Verify data persistence

**API Tests:**
```bash
# Create wallet
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "deploy_test", "ownerName": "Deploy Test", "balance": 1000}'

# Get balance
curl http://localhost:8080/api/v1/wallets/deploy_test/balance

# Deposit
curl -X POST http://localhost:8080/api/v1/wallets/deploy_test/deposit \
  -H "Content-Type: application/json" \
  -d '{"type": "DEPOSIT", "amount": 500}'

# Verify balance is 1500
curl http://localhost:8080/api/v1/wallets/deploy_test/balance
```

---

## Performance Testing

### ☐ Load Test (Optional but Recommended)

- [ ] Install Apache Bench: `sudo apt-get install apache2-utils`
- [ ] Run basic load test: `ab -n 100 -c 10 http://localhost:8080/api/v1/wallets/deploy_test/balance`
- [ ] Verify 0 failed requests
- [ ] Check response times are acceptable
- [ ] Monitor resource usage: `docker stats`

**Load Test:**
```bash
ab -n 100 -c 10 http://localhost:8080/api/v1/wallets/deploy_test/balance
```

---

## Security

### ☐ Security Hardening

- [ ] Change default database password
- [ ] Create `.env` file for secrets (don't commit!)
- [ ] Restrict database port (remove from compose.yaml if not needed externally)
- [ ] Enable firewall rules for ports 8080 and 5432
- [ ] Set up HTTPS/SSL (if production)
- [ ] Configure backup strategy

**Security Steps:**
```bash
# Create .env file
cat > .env << EOF
POSTGRES_PASSWORD=your_secure_password_here
EOF

# Update compose.yaml to use .env
# environment:
#   POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

---

## Monitoring

### ☐ Set Up Monitoring

- [ ] Configure log rotation
- [ ] Set up log aggregation (optional)
- [ ] Configure alerts for container failures
- [ ] Set up resource monitoring
- [ ] Configure database backups

**Log Monitoring:**
```bash
# View logs
docker-compose logs -f

# Save logs
docker-compose logs > deployment-logs.txt
```

---

## Backup

### ☐ Initial Backup

- [ ] Backup database: `docker exec wallet-postgres pg_dump -U postgres test_db > initial-backup.sql`
- [ ] Backup volumes: `docker run --rm -v wallet-app_postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/volumes-backup.tar.gz /data`
- [ ] Document backup location
- [ ] Test restore procedure

**Backup Commands:**
```bash
# Database backup
docker exec wallet-postgres pg_dump -U postgres test_db > backup-$(date +%Y%m%d).sql

# Volume backup
docker run --rm \
  -v wallet-app_postgres-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/volumes-backup-$(date +%Y%m%d).tar.gz /data
```

---

## Documentation

### ☐ Document Deployment

- [ ] Record deployment date and time
- [ ] Document any configuration changes
- [ ] Note any issues encountered and solutions
- [ ] Update runbook with environment-specific details
- [ ] Share access credentials securely

**Deployment Log:**
```
Deployment Date: _______________
Deployed By: _______________
Environment: _______________
Configuration Changes: _______________
Issues Encountered: _______________
```

---

## Post-Deployment

### ☐ Handover

- [ ] Provide access to logs: `docker-compose logs -f`
- [ ] Share stop/start commands
- [ ] Document troubleshooting steps
- [ ] Provide contact for support
- [ ] Schedule follow-up check

**Key Commands for Operations:**
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# Logs
docker-compose logs -f

# Status
docker-compose ps

# Backup
docker exec wallet-postgres pg_dump -U postgres test_db > backup.sql
```

---

## Rollback Plan

### ☐ Rollback Procedure

If deployment fails:

1. **Stop services:**
   ```bash
   docker-compose down
   ```

2. **Remove volumes (if needed):**
   ```bash
   docker-compose down -v
   ```

3. **Restore from backup:**
   ```bash
   docker exec -i wallet-postgres psql -U postgres test_db < backup.sql
   ```

4. **Restart with previous version:**
   ```bash
   docker-compose up -d
   ```

---

## Success Criteria

### ☐ Deployment Successful When:

- [ ] All containers are running and healthy
- [ ] API endpoints respond correctly
- [ ] Database is accessible and populated
- [ ] No errors in logs
- [ ] Performance meets requirements
- [ ] Security measures in place
- [ ] Backups configured
- [ ] Documentation complete

---

## Sign-Off

**Deployment Completed By:** _______________  
**Date:** _______________  
**Verified By:** _______________  
**Date:** _______________  

**Notes:**
_______________________________________________
_______________________________________________
_______________________________________________

---

## Quick Reference

### Essential Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs
docker-compose logs -f wallet-app

# Status
docker-compose ps

# Restart
docker-compose restart wallet-app

# Rebuild
docker-compose up -d --build

# Clean up
docker-compose down -v
```

### Troubleshooting

```bash
# Check logs
docker-compose logs --tail=100 wallet-app

# Check health
docker inspect wallet-app | grep -A 10 Health

# Access container
docker exec -it wallet-app sh

# Database access
docker exec -it wallet-postgres psql -U postgres -d test_db

# Resource usage
docker stats
```

---

**For detailed instructions, see DOCKER_SETUP.md**
