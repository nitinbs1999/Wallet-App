#!/bin/bash
# Deploy Wallet Application to another machine
# This script creates a deployment package

set -e

DEPLOY_DIR="wallet-app-deploy"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PACKAGE_NAME="wallet-app-${TIMESTAMP}.tar.gz"

echo "=========================================="
echo "Creating Deployment Package"
echo "=========================================="
echo ""

# Create deployment directory
mkdir -p "$DEPLOY_DIR"

echo "Copying files..."

# Copy necessary files
cp Dockerfile "$DEPLOY_DIR/"
cp compose.yaml "$DEPLOY_DIR/"
cp .dockerignore "$DEPLOY_DIR/"
cp init-db.sql "$DEPLOY_DIR/"
cp build.gradle "$DEPLOY_DIR/"
cp settings.gradle "$DEPLOY_DIR/"
cp gradlew "$DEPLOY_DIR/"
cp -r gradle "$DEPLOY_DIR/"
cp -r src "$DEPLOY_DIR/"

# Copy documentation
cp DOCKER_SETUP.md "$DEPLOY_DIR/" 2>/dev/null || true
cp README.md "$DEPLOY_DIR/" 2>/dev/null || true

# Create deployment README
cat > "$DEPLOY_DIR/DEPLOY_README.md" << 'EOF'
# Wallet Application - Deployment Package

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 2GB RAM minimum
- 10GB disk space

## Quick Start

1. Extract this package
2. Run: `docker-compose up -d`
3. Access: http://localhost:8080

## Detailed Instructions

### 1. Start Application
```bash
docker-compose up -d
```

### 2. Check Status
```bash
docker-compose ps
docker-compose logs -f wallet-app
```

### 3. Test API
```bash
# Create wallet
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Test User", "balance": 1000}'

# Get balance
curl http://localhost:8080/api/v1/wallets/test123/balance
```

### 4. Stop Application
```bash
docker-compose down
```

## Configuration

Edit `compose.yaml` to customize:
- Database credentials
- Port mappings
- Memory limits
- Environment variables

## Troubleshooting

**Port already in use:**
```bash
# Change port in compose.yaml
ports:
  - "8081:8080"  # Use 8081 instead
```

**Database connection issues:**
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Restart services
docker-compose restart
```

**View application logs:**
```bash
docker-compose logs -f wallet-app
```

## Support

For issues, check:
- Application logs: `docker-compose logs wallet-app`
- Database logs: `docker-compose logs postgres`
- Container status: `docker-compose ps`
EOF

# Create startup script
cat > "$DEPLOY_DIR/start.sh" << 'EOF'
#!/bin/bash
echo "Starting Wallet Application..."
docker-compose up -d
echo ""
echo "✅ Application started!"
echo "URL: http://localhost:8080"
echo ""
echo "To view logs: docker-compose logs -f"
EOF

chmod +x "$DEPLOY_DIR/start.sh"

# Create stop script
cat > "$DEPLOY_DIR/stop.sh" << 'EOF'
#!/bin/bash
echo "Stopping Wallet Application..."
docker-compose down
echo "✅ Application stopped!"
EOF

chmod +x "$DEPLOY_DIR/stop.sh"

# Create package
echo ""
echo "Creating archive..."
tar -czf "$PACKAGE_NAME" "$DEPLOY_DIR"

# Cleanup
rm -rf "$DEPLOY_DIR"

echo ""
echo "=========================================="
echo "✅ Deployment package created!"
echo "=========================================="
echo ""
echo "Package: $PACKAGE_NAME"
echo "Size: $(du -h "$PACKAGE_NAME" | cut -f1)"
echo ""
echo "To deploy on another machine:"
echo "1. Copy $PACKAGE_NAME to target machine"
echo "2. Extract: tar -xzf $PACKAGE_NAME"
echo "3. cd $DEPLOY_DIR"
echo "4. Run: ./start.sh"
echo ""
