#!/bin/bash

# Wallet API Test Script
BASE_URL="http://localhost:8080/api/v1/wallets"

# Generate unique wallet ID using timestamp
WALLET_ID="user_$(date +%s)"

echo "=========================================="
echo "Wallet API Testing"
echo "=========================================="
echo "Using Wallet ID: $WALLET_ID"
echo ""

# 1. Create a wallet
echo "1. Creating a wallet..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"walletId\": \"$WALLET_ID\",
    \"ownerName\": \"John Doe\",
    \"balance\": 1000
  }")
echo "Response: $CREATE_RESPONSE"
echo ""

# 2. Get balance
echo "2. Getting wallet balance..."
BALANCE=$(curl -s -X GET "$BASE_URL/$WALLET_ID/balance")
echo "Balance: $BALANCE"
echo ""

# 3. Deposit money
echo "3. Depositing 500 to wallet..."
DEPOSIT_RESPONSE=$(curl -s -X POST "$BASE_URL/$WALLET_ID/deposit" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "DEPOSIT",
    "amount": 500
  }')
echo "Response: $DEPOSIT_RESPONSE"
echo ""

# 4. Get balance after deposit
echo "4. Getting balance after deposit..."
BALANCE=$(curl -s -X GET "$BASE_URL/$WALLET_ID/balance")
echo "Balance: $BALANCE"
echo ""

# 5. Withdraw money
echo "5. Withdrawing 300 from wallet..."
WITHDRAW_RESPONSE=$(curl -s -X POST "$BASE_URL/$WALLET_ID/withdraw" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "WITHDRAW",
    "amount": 300
  }')
echo "Response: $WITHDRAW_RESPONSE"
echo ""

# 6. Get final balance
echo "6. Getting final balance..."
BALANCE=$(curl -s -X GET "$BASE_URL/$WALLET_ID/balance")
echo "Final Balance: $BALANCE"
echo ""

# 7. Test duplicate wallet creation
echo "7. Testing duplicate wallet creation (should fail)..."
DUPLICATE_RESPONSE=$(curl -s -X POST "$BASE_URL" \
  -H "Content-Type: application/json" \
  -d "{
    \"walletId\": \"$WALLET_ID\",
    \"ownerName\": \"Jane Doe\",
    \"balance\": 2000
  }")
echo "Response: $DUPLICATE_RESPONSE"
echo ""

echo "=========================================="
echo "Testing Complete!"
echo "=========================================="
