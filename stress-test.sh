#!/bin/bash

# Stress Test Script - 100 requests/second sustained load
# Tests API under high concurrent load

BASE_URL="http://localhost:8080/api/v1/wallets"
RESULTS_DIR="/tmp/load-test-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create results directory
mkdir -p $RESULTS_DIR

echo "=========================================="
echo "Wallet API Stress Test"
echo "Target: 100 requests/second"
echo "Timestamp: $TIMESTAMP"
echo "=========================================="
echo ""

# Create test wallet
WALLET_ID="stress_test_$TIMESTAMP"
echo "Creating test wallet: $WALLET_ID"
curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{\"walletId\": \"$WALLET_ID\", \"ownerName\": \"Stress Test\", \"balance\": 100000}" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Test wallet created successfully"
else
    echo "❌ Failed to create test wallet"
    exit 1
fi
echo ""

# Prepare request payloads
cat > /tmp/deposit_payload.json << EOF
{
  "type": "DEPOSIT",
  "amount": 10
}
EOF

cat > /tmp/withdraw_payload.json << EOF
{
  "type": "WITHDRAW",
  "amount": 5
}
EOF

echo "=========================================="
echo "Test 1: GET Balance - 100 req/s for 10s"
echo "=========================================="
ab -n 1000 -c 100 -g "$RESULTS_DIR/balance_test.tsv" \
   "$BASE_URL/$WALLET_ID/balance" \
   2>&1 | tee "$RESULTS_DIR/balance_test.txt"

# Extract key metrics
echo ""
echo "Key Metrics:"
grep "Requests per second" "$RESULTS_DIR/balance_test.txt"
grep "Time per request" "$RESULTS_DIR/balance_test.txt"
grep "Failed requests" "$RESULTS_DIR/balance_test.txt"
echo ""

echo "=========================================="
echo "Test 2: POST Deposit - 100 req/s for 10s"
echo "=========================================="
ab -n 1000 -c 100 -g "$RESULTS_DIR/deposit_test.tsv" \
   -p /tmp/deposit_payload.json \
   -T "application/json" \
   "$BASE_URL/$WALLET_ID/deposit" \
   2>&1 | tee "$RESULTS_DIR/deposit_test.txt"

echo ""
echo "Key Metrics:"
grep "Requests per second" "$RESULTS_DIR/deposit_test.txt"
grep "Time per request" "$RESULTS_DIR/deposit_test.txt"
grep "Failed requests" "$RESULTS_DIR/deposit_test.txt"
echo ""

echo "=========================================="
echo "Test 3: POST Withdraw - 100 req/s for 10s"
echo "=========================================="
ab -n 1000 -c 100 -g "$RESULTS_DIR/withdraw_test.tsv" \
   -p /tmp/withdraw_payload.json \
   -T "application/json" \
   "$BASE_URL/$WALLET_ID/withdraw" \
   2>&1 | tee "$RESULTS_DIR/withdraw_test.txt"

echo ""
echo "Key Metrics:"
grep "Requests per second" "$RESULTS_DIR/withdraw_test.txt"
grep "Time per request" "$RESULTS_DIR/withdraw_test.txt"
grep "Failed requests" "$RESULTS_DIR/withdraw_test.txt"
echo ""

echo "=========================================="
echo "Test 4: Sustained Load - 200 req/s for 20s"
echo "=========================================="
ab -n 4000 -c 200 -g "$RESULTS_DIR/sustained_test.tsv" \
   "$BASE_URL/$WALLET_ID/balance" \
   2>&1 | tee "$RESULTS_DIR/sustained_test.txt"

echo ""
echo "Key Metrics:"
grep "Requests per second" "$RESULTS_DIR/sustained_test.txt"
grep "Time per request" "$RESULTS_DIR/sustained_test.txt"
grep "Failed requests" "$RESULTS_DIR/sustained_test.txt"
echo ""

# Verify final state
echo "=========================================="
echo "Final Wallet State Verification"
echo "=========================================="
FINAL_BALANCE=$(curl -s "$BASE_URL/$WALLET_ID/balance")
echo "Wallet ID: $WALLET_ID"
echo "Final Balance: $FINAL_BALANCE"
echo "Expected: ~105000 (100000 + 10000 deposits - 5000 withdrawals)"
echo ""

# Generate summary report
echo "=========================================="
echo "Test Summary Report"
echo "=========================================="
echo ""

echo "📊 Performance Summary:"
echo ""
echo "GET Balance Test:"
grep "Requests per second" "$RESULTS_DIR/balance_test.txt" | head -1
grep "Failed requests" "$RESULTS_DIR/balance_test.txt" | head -1
echo ""

echo "POST Deposit Test:"
grep "Requests per second" "$RESULTS_DIR/deposit_test.txt" | head -1
grep "Failed requests" "$RESULTS_DIR/deposit_test.txt" | head -1
echo ""

echo "POST Withdraw Test:"
grep "Requests per second" "$RESULTS_DIR/withdraw_test.txt" | head -1
grep "Failed requests" "$RESULTS_DIR/withdraw_test.txt" | head -1
echo ""

echo "Sustained Load Test (200 req/s):"
grep "Requests per second" "$RESULTS_DIR/sustained_test.txt" | head -1
grep "Failed requests" "$RESULTS_DIR/sustained_test.txt" | head -1
echo ""

echo "=========================================="
echo "Detailed Results Location:"
echo "$RESULTS_DIR"
echo "=========================================="
echo ""

# Cleanup
rm -f /tmp/deposit_payload.json /tmp/withdraw_payload.json

echo "✅ Stress test completed!"
echo ""
echo "To view detailed results:"
echo "  cat $RESULTS_DIR/balance_test.txt"
echo "  cat $RESULTS_DIR/deposit_test.txt"
echo "  cat $RESULTS_DIR/withdraw_test.txt"
echo ""
