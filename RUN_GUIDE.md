# Running the Wallet Application

## Quick Start (Development Mode)

The easiest way to run the application is using H2 in-memory database:

```bash
./run-dev.sh
```

Or manually:
```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```

The application will start on: http://localhost:8080

H2 Console available at: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:mem:devdb`
- Username: `sa`
- Password: (leave empty)

## Production Mode (PostgreSQL)

### Option 1: Using Docker Compose (Outside Dev Container)

If you have Docker installed on your host machine:

```bash
docker compose up
```

This will start both PostgreSQL and the application.

### Option 2: Manual PostgreSQL Setup

1. Install and start PostgreSQL
2. Create database:
```sql
CREATE DATABASE test_db;
CREATE USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE test_db TO postgres;
```

3. Run the application:
```bash
./run-prod.sh
```

Or manually:
```bash
./gradlew bootRun
```

## Build Commands

**Clean build:**
```bash
./gradlew clean build
```

**Run tests only:**
```bash
./gradlew test
```

**Build without tests:**
```bash
./gradlew clean build -x test
```

## Configuration Profiles

- **dev** - Uses H2 in-memory database (no setup required)
- **test** - Uses H2 for testing (automatic)
- **default** - Uses PostgreSQL (requires PostgreSQL running)

## Troubleshooting

### Issue: Docker compose error when running bootRun

**Solution:** The `spring-boot-docker-compose` dependency has been disabled. Use one of these options:
- Run with dev profile: `./run-dev.sh`
- Start PostgreSQL separately and use default profile

### Issue: Permission denied on gradlew

**Solution:**
```bash
chmod +x gradlew
```

### Issue: PostgreSQL connection refused

**Solution:** Either:
1. Use dev mode with H2: `./run-dev.sh`
2. Start PostgreSQL: `docker compose up postgres -d` (if Docker available)
3. Install PostgreSQL locally

### Issue: Port 8080 already in use

**Solution:**
```bash
# Find and kill the process
lsof -ti:8080 | xargs kill -9
```

## API Endpoints

Once running, the application exposes wallet management endpoints at:
- Base URL: http://localhost:8080/api/v1/wallets

Check the controller classes for specific endpoints.
