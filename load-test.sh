#!/bin/bash

# Load Testing Script for Wallet API
# Tests with 100 requests per second

BASE_URL="http://localhost:8080/api/v1/wallets"
TOTAL_REQUESTS=1000
CONCURRENCY=100
DURATION=10

echo "=========================================="
echo "Wallet API Load Testing"
echo "=========================================="
echo "Target: 100 requests/second"
echo "Total Requests: $TOTAL_REQUESTS"
echo "Concurrency: $CONCURRENCY"
echo "Duration: ${DURATION}s"
echo "=========================================="
echo ""

# Create test data files
echo "Preparing test data..."

# Create wallet request payload
cat > /tmp/create-wallet.json << 'EOF'
{
  "walletId": "loadtest_TIMESTAMP",
  "ownerName": "Load Test User",
  "balance": 1000
}
EOF

# Create deposit request payload
cat > /tmp/deposit.json << 'EOF'
{
  "type": "DEPOSIT",
  "amount": 100
}
EOF

# Create withdraw request payload
cat > /tmp/withdraw.json << 'EOF'
{
  "type": "WITHDRAW",
  "amount": 50
}
EOF

echo "Test data prepared."
echo ""

# Test 1: Create Wallet (POST)
echo "=========================================="
echo "Test 1: Create Wallet Endpoint"
echo "=========================================="
echo "Creating a test wallet first..."
WALLET_ID="loadtest_$(date +%s)"
curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"walletId\": \"$WALLET_ID\", \"ownerName\": \"Load Test\", \"balance\": 10000}" > /dev/null
echo "Test wallet created: $WALLET_ID"
echo ""

# Test 2: Get Balance (GET) - High throughput test
echo "=========================================="
echo "Test 2: Get Balance Endpoint (Read-Heavy)"
echo "=========================================="
ab -n $TOTAL_REQUESTS -c $CONCURRENCY -t $DURATION \
   -H "Content-Type: application/json" \
   "$BASE_URL/$WALLET_ID/balance"
echo ""

# Test 3: Deposit (POST) - Write operation
echo "=========================================="
echo "Test 3: Deposit Endpoint (Write Operation)"
echo "=========================================="
ab -n 500 -c 50 -t 5 \
   -p /tmp/deposit.json \
   -T "application/json" \
   "$BASE_URL/$WALLET_ID/deposit"
echo ""

# Test 4: Withdraw (POST) - Write operation
echo "=========================================="
echo "Test 4: Withdraw Endpoint (Write Operation)"
echo "=========================================="
ab -n 500 -c 50 -t 5 \
   -p /tmp/withdraw.json \
   -T "application/json" \
   "$BASE_URL/$WALLET_ID/withdraw"
echo ""

# Test 5: Mixed Load Test
echo "=========================================="
echo "Test 5: Mixed Operations (Concurrent)"
echo "=========================================="
echo "Running concurrent read/write operations..."

# Background processes for mixed load
for i in {1..5}; do
  ab -n 200 -c 20 -q "$BASE_URL/$WALLET_ID/balance" > /tmp/load_read_$i.txt 2>&1 &
done

for i in {1..3}; do
  ab -n 100 -c 10 -q -p /tmp/deposit.json -T "application/json" "$BASE_URL/$WALLET_ID/deposit" > /tmp/load_deposit_$i.txt 2>&1 &
done

# Wait for all background jobs
wait

echo "Mixed load test completed."
echo ""

# Get final balance
echo "=========================================="
echo "Final Wallet State"
echo "=========================================="
FINAL_BALANCE=$(curl -s "$BASE_URL/$WALLET_ID/balance")
echo "Wallet ID: $WALLET_ID"
echo "Final Balance: $FINAL_BALANCE"
echo ""

# Cleanup
rm -f /tmp/create-wallet.json /tmp/deposit.json /tmp/withdraw.json
rm -f /tmp/load_*.txt

echo "=========================================="
echo "Load Testing Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "- Check response times and success rates above"
echo "- Look for failed requests (non-2xx responses)"
echo "- Monitor for errors or timeouts"
echo ""
