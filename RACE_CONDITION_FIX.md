# Race Condition Fix - Concurrent Balance Updates

## Problem Identified

During load testing with 100 requests/second, a race condition was discovered in concurrent balance updates:

- **Expected balance:** 105,000
- **Actual balance:** 101,120
- **Data loss:** 3,880 (3.7%)

This occurs when multiple threads read the same balance, modify it, and write it back simultaneously.

## Root Cause

```java
// Current implementation (UNSAFE for concurrent access)
public TransactionResponse deposit(String walletId, int amount) {
    Wallet wallet = walletRepository.findByWalletId(walletId).orElseThrow(...);
    int balance_after = wallet.getBalance() + amount;  // Race condition here!
    wallet.setBalance(balance_after);
    walletRepository.save(wallet);
    // ...
}
```

**Timeline of Race Condition:**
```
Thread 1: Read balance = 1000
Thread 2: Read balance = 1000
Thread 1: Calculate 1000 + 100 = 1100
Thread 2: Calculate 1000 + 50 = 1050
Thread 1: Save balance = 1100
Thread 2: Save balance = 1050  ← Overwrites Thread 1's update!
Result: Lost 100 from Thread 1's deposit
```

## Solution Options

### Option 1: Optimistic Locking (Recommended)

Add version field to detect concurrent modifications:

**1. Update Wallet Entity:**
```java
@Entity
@Table(name = "wallets")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Wallet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String walletId;
    
    @Column(nullable = false)
    private int balance;
    
    @Column(nullable = false)
    private String owner;
    
    @Version  // Add this for optimistic locking
    private Long version;
}
```

**2. Update Service with Retry Logic:**
```java
@Service
public class UserServiceImpl implements UserService {
    
    private static final int MAX_RETRIES = 3;
    
    @Override
    @Transactional
    public TransactionResponse deposit(String walletId, int amount) {
        return retryOnOptimisticLock(() -> performDeposit(walletId, amount));
    }
    
    private TransactionResponse performDeposit(String walletId, int amount) {
        Wallet wallet = walletRepository.findByWalletId(walletId)
            .orElseThrow(() -> new WalletNotFoundException("Wallet Id not found!"));
        
        int balance_after = wallet.getBalance() + amount;
        wallet.setBalance(balance_after);
        walletRepository.save(wallet);
        
        Transaction transaction = Transaction.builder()
            .transactionId(UUID.randomUUID().toString())
            .amount(amount)
            .balanceAfter(balance_after)
            .type(TransactionType.DEPOSIT)
            .wallet(wallet)
            .build();
        
        transactionRepository.save(transaction);
        return maptoDto(transaction);
    }
    
    private <T> T retryOnOptimisticLock(Supplier<T> operation) {
        int attempts = 0;
        while (attempts < MAX_RETRIES) {
            try {
                return operation.get();
            } catch (OptimisticLockException e) {
                attempts++;
                if (attempts >= MAX_RETRIES) {
                    throw new RuntimeException("Failed after " + MAX_RETRIES + " retries", e);
                }
                // Brief pause before retry
                try {
                    Thread.sleep(10 * attempts);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException("Interrupted during retry", ie);
                }
            }
        }
        throw new RuntimeException("Should not reach here");
    }
}
```

**Pros:**
- No database locks
- Better performance under low contention
- Automatic conflict detection

**Cons:**
- Requires retry logic
- May fail under very high contention

---

### Option 2: Pessimistic Locking

Lock the row during read to prevent concurrent modifications:

**1. Update Repository:**
```java
public interface WalletRepository extends JpaRepository<Wallet, Long> {
    
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT w FROM Wallet w WHERE w.walletId = :walletId")
    Optional<Wallet> findByWalletIdForUpdate(@Param("walletId") String walletId);
}
```

**2. Update Service:**
```java
@Override
@Transactional
public TransactionResponse deposit(String walletId, int amount) {
    // This will lock the row until transaction completes
    Wallet wallet = walletRepository.findByWalletIdForUpdate(walletId)
        .orElseThrow(() -> new WalletNotFoundException("Wallet Id not found!"));
    
    int balance_after = wallet.getBalance() + amount;
    wallet.setBalance(balance_after);
    walletRepository.save(wallet);
    
    // ... rest of the code
}
```

**Pros:**
- Guaranteed consistency
- No retry logic needed
- Simple to implement

**Cons:**
- Lower throughput under high concurrency
- Potential for deadlocks
- Database-dependent behavior

---

### Option 3: Database-Level Atomic Update

Use SQL UPDATE with WHERE clause:

**1. Add Custom Repository Method:**
```java
public interface WalletRepository extends JpaRepository<Wallet, Long> {
    
    @Modifying
    @Query("UPDATE Wallet w SET w.balance = w.balance + :amount WHERE w.walletId = :walletId")
    int incrementBalance(@Param("walletId") String walletId, @Param("amount") int amount);
    
    @Modifying
    @Query("UPDATE Wallet w SET w.balance = w.balance - :amount WHERE w.walletId = :walletId AND w.balance >= :amount")
    int decrementBalance(@Param("walletId") String walletId, @Param("amount") int amount);
}
```

**2. Update Service:**
```java
@Override
@Transactional
public TransactionResponse deposit(String walletId, int amount) {
    // Atomic update at database level
    int updated = walletRepository.incrementBalance(walletId, amount);
    
    if (updated == 0) {
        throw new WalletNotFoundException("Wallet Id not found!");
    }
    
    // Fetch updated wallet
    Wallet wallet = walletRepository.findByWalletId(walletId)
        .orElseThrow(() -> new WalletNotFoundException("Wallet Id not found!"));
    
    Transaction transaction = Transaction.builder()
        .transactionId(UUID.randomUUID().toString())
        .amount(amount)
        .balanceAfter(wallet.getBalance())
        .type(TransactionType.DEPOSIT)
        .wallet(wallet)
        .build();
    
    transactionRepository.save(transaction);
    return maptoDto(transaction);
}
```

**Pros:**
- Best performance
- Truly atomic
- No application-level locking

**Cons:**
- Requires custom SQL
- Less portable across databases

---

## Recommended Implementation

**Use Option 1 (Optimistic Locking)** for this application because:

1. ✅ Good balance between performance and consistency
2. ✅ Works well with moderate concurrency (100 req/s)
3. ✅ JPA standard, database-agnostic
4. ✅ Automatic conflict detection

## Implementation Steps

1. Add `@Version` field to Wallet entity
2. Add retry logic to service methods
3. Add custom exception handler for OptimisticLockException
4. Update tests to verify concurrent behavior
5. Re-run load tests to verify fix

## Testing the Fix

```bash
# After implementing the fix, run load test again
./stress-test.sh

# Verify balance accuracy
# Expected: 105,000
# Actual: Should be 105,000 (or very close)
```

## Performance Impact

Expected impact of optimistic locking:
- **Throughput:** 5-10% reduction under high contention
- **Latency:** +10-20ms for retries (only on conflicts)
- **Success Rate:** 100% (with proper retry logic)

Under normal load (100 req/s), the impact should be minimal.
