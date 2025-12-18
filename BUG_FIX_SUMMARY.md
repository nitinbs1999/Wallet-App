# Bug Fix: Duplicate Wallet Creation

## Problem
When attempting to create a wallet with an existing `walletId`, the application returned a 500 Internal Server Error with a database constraint violation.

**Error Message:**
```
Unique index or primary key violation: "PUBLIC.UK3X8UVE6J94TGUB04634UJX5P8_INDEX_6 
ON PUBLIC.WALLETS(WALLET_ID NULLS FIRST) VALUES ( /* 1 */ 'user123' )"
```

## Root Cause
The `UserServiceImpl.create()` method did not check if a wallet with the given `walletId` already existed before attempting to save it. Since `walletId` has a unique constraint in the database, duplicate attempts caused a constraint violation exception.

## Solution

### 1. Created Custom Exception
**File:** `WalletAlreadyExistsException.java`
- Custom exception for duplicate wallet scenarios
- Provides clear error messaging

### 2. Updated Global Exception Handler
**File:** `GlobalExceptionHandler.java`
- Added handler for `WalletAlreadyExistsException`
- Returns HTTP 409 Conflict status
- Provides user-friendly error response

### 3. Updated Service Logic
**File:** `UserServiceImpl.java`
- Added validation to check if wallet exists before creation
- Throws `WalletAlreadyExistsException` if wallet already exists
- Prevents database constraint violations

## Changes Made

### Before
```java
@Override
public WalletResponse create(WalletRequest request) {
    Wallet wallet = Wallet.builder()
        .walletId(request.getWalletId())
        .balance(request.getBalance())
        .owner(request.getOwnerName())
        .build();
    walletRepository.save(wallet); // Could fail with constraint violation
    // ...
}
```

### After
```java
@Override
public WalletResponse create(WalletRequest request) {
    // Check if wallet already exists
    if (walletRepository.findByWalletId(request.getWalletId()).isPresent()) {
        throw new WalletAlreadyExistsException(
            "Wallet with ID '" + request.getWalletId() + "' already exists"
        );
    }
    
    Wallet wallet = Wallet.builder()
        .walletId(request.getWalletId())
        .balance(request.getBalance())
        .owner(request.getOwnerName())
        .build();
    walletRepository.save(wallet);
    // ...
}
```

## API Response Changes

### Before (500 Internal Server Error)
```json
{
  "error": "Internal Server Error",
  "message": "could not execute statement [Unique index or primary key violation...]",
  "timestamp": "2025-12-18T12:47:31.050109254",
  "status": 500
}
```

### After (409 Conflict)
```json
{
  "error": "Conflict",
  "message": "Wallet with ID 'user123' already exists",
  "timestamp": "2025-12-18T12:56:29.191530127",
  "status": 409
}
```

## Testing

### Test Script Updated
The `test-api.sh` script now:
- Generates unique wallet IDs using timestamps
- Tests duplicate wallet creation scenario
- Verifies proper error handling

### Manual Testing
```bash
# Create wallet
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Test", "balance": 100}'

# Try to create duplicate (should return 409)
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"walletId": "test123", "ownerName": "Another", "balance": 200}'
```

## Benefits
1. ✅ Proper HTTP status code (409 Conflict instead of 500)
2. ✅ Clear, user-friendly error messages
3. ✅ Prevents database constraint violations
4. ✅ Follows REST API best practices
5. ✅ Easier to debug and understand errors

## Files Modified
- `src/main/java/com/wallet/app/exception/WalletAlreadyExistsException.java` (new)
- `src/main/java/com/wallet/app/exception/GlobalExceptionHandler.java`
- `src/main/java/com/wallet/app/service/UserServiceImpl.java`
- `test-api.sh`
- `CURL_COMMANDS.md`
