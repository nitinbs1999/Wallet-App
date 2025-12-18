# Wallet API - cURL Commands

Base URL: `http://localhost:8080/api/v1/wallets`

## Quick Test Script

Run all tests at once:
```bash
./test-api.sh
```

## Individual Commands

### 1. Create a Wallet

```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "walletId": "user123",
    "ownerName": "John Doe",
    "balance": 1000
  }'
```

**Expected Response:**
```json
{
  "walletId": "user123",
  "ownerName": "John Doe",
  "balance": 1000,
  "status": "ACTIVE"
}
```

### 2. Get Wallet Balance

```bash
curl -X GET http://localhost:8080/api/v1/wallets/user123/balance
```

**Expected Response:**
```
1000
```

### 3. Deposit Money

```bash
curl -X POST http://localhost:8080/api/v1/wallets/user123/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "type": "DEPOSIT",
    "amount": 500
  }'
```

**Expected Response:**
```json
{
  "transactionId": "d4ee78ef-be7f-40a3-9188-bbe391d04424",
  "walletId": "user123",
  "type": "DEPOSIT",
  "amount": 500,
  "balanceAfter": 1500
}
```

### 4. Withdraw Money

```bash
curl -X POST http://localhost:8080/api/v1/wallets/user123/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "type": "WITHDRAW",
    "amount": 300
  }'
```

**Expected Response:**
```json
{
  "transactionId": "5ec86156-e2d4-4889-87c2-73c246bf97fa",
  "walletId": "user123",
  "type": "WITHDRAW",
  "amount": 300,
  "balanceAfter": 1200
}
```

## Pretty Print JSON (with jq)

If you have `jq` installed, you can format the output:

```bash
# Create wallet with pretty output
curl -s -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "walletId": "user456",
    "ownerName": "Jane Smith",
    "balance": 2000
  }' | jq '.'

# Deposit with pretty output
curl -s -X POST http://localhost:8080/api/v1/wallets/user456/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "type": "DEPOSIT",
    "amount": 1000
  }' | jq '.'
```

## Test Different Scenarios

### Create Multiple Wallets

```bash
# Wallet 1
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "alice", "ownerName": "Alice", "balance": 5000}'

# Wallet 2
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "bob", "ownerName": "Bob", "balance": 3000}'
```

### Multiple Transactions

```bash
# Deposit to Alice
curl -X POST http://localhost:8080/api/v1/wallets/alice/deposit \
  -H "Content-Type: application/json" \
  -d '{"type": "DEPOSIT", "amount": 1000}'

# Withdraw from Bob
curl -X POST http://localhost:8080/api/v1/wallets/bob/withdraw \
  -H "Content-Type: application/json" \
  -d '{"type": "WITHDRAW", "amount": 500}'

# Check balances
curl http://localhost:8080/api/v1/wallets/alice/balance
curl http://localhost:8080/api/v1/wallets/bob/balance
```

## Error Testing

### Duplicate Wallet (409 Conflict)

```bash
# Create a wallet first
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Test", "balance": 100}'

# Try to create the same wallet again (should fail)
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Another", "balance": 200}'
```

**Expected Response:**
```json
{
  "error": "Conflict",
  "message": "Wallet with ID 'test123' already exists",
  "timestamp": "2025-12-18T12:57:06.978748987",
  "status": 409
}
```

### Non-existent Wallet (404 Not Found)

```bash
curl -X GET http://localhost:8080/api/v1/wallets/nonexistent/balance
```

**Expected Response:**
```json
{
  "error": "Not Found",
  "message": "Wallet Id not found!",
  "timestamp": "2025-12-18T12:57:06.978748987",
  "status": 404
}
```

### Insufficient Balance (404 Not Found)

```bash
# Try to withdraw more than balance
curl -X POST http://localhost:8080/api/v1/wallets/user123/withdraw \
  -H "Content-Type: application/json" \
  -d '{"type": "WITHDRAW", "amount": 999999}'
```

**Expected Response:**
```json
{
  "error": "Not Found",
  "message": "Insufficient balance in account!",
  "timestamp": "2025-12-18T12:57:06.978748987",
  "status": 404
}
```

## Tips

1. **Save responses to files:**
   ```bash
   curl -X POST http://localhost:8080/api/v1/wallets \
     -H "Content-Type: application/json" \
     -d '{"walletId": "test", "ownerName": "Test", "balance": 100}' \
     -o response.json
   ```

2. **Include response headers:**
   ```bash
   curl -i -X GET http://localhost:8080/api/v1/wallets/user123/balance
   ```

3. **Verbose output for debugging:**
   ```bash
   curl -v -X POST http://localhost:8080/api/v1/wallets/user123/deposit \
     -H "Content-Type: application/json" \
     -d '{"type": "DEPOSIT", "amount": 100}'
   ```

4. **Silent mode (no progress bar):**
   ```bash
   curl -s http://localhost:8080/api/v1/wallets/user123/balance
   ```

## Application URLs

- **API Base:** http://localhost:8080/api/v1/wallets
- **H2 Console:** http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:devdb`
  - Username: `sa`
  - Password: (empty)
