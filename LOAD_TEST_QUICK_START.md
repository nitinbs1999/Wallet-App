# Load Testing Quick Start Guide

## Prerequisites

✅ Application running on http://localhost:8080  
✅ Apache Bench (ab) installed  

## Quick Commands

### 1. Run Full Stress Test (Recommended)
```bash
./stress-test.sh
```

**What it does:**
- Tests GET Balance: 1,000 requests @ 100 concurrent
- Tests POST Deposit: 1,000 requests @ 100 concurrent  
- Tests POST Withdraw: 1,000 requests @ 100 concurrent
- Sustained load: 4,000 requests @ 200 concurrent
- Generates detailed reports in `/tmp/load-test-results/`

**Duration:** ~15-20 seconds

---

### 2. Run Basic Load Test
```bash
./load-test.sh
```

**What it does:**
- Mixed read/write operations
- Concurrent background processes
- Simpler output format

**Duration:** ~30 seconds

---

### 3. Manual Single Endpoint Test

**Test GET Balance:**
```bash
# 100 requests, 10 concurrent
ab -n 100 -c 10 http://localhost:8080/api/v1/wallets/test123/balance
```

**Test POST Deposit:**
```bash
# Create payload
echo '{"type":"DEPOSIT","amount":100}' > /tmp/deposit.json

# Run test
ab -n 100 -c 10 -p /tmp/deposit.json -T application/json \
   http://localhost:8080/api/v1/wallets/test123/deposit
```

---

## Understanding Results

### Key Metrics to Watch

**1. Requests per second (RPS)**
```
Requests per second:    390.68 [#/sec] (mean)
```
- Target: 100 req/s
- Good: > 100 req/s
- Excellent: > 300 req/s

**2. Failed Requests**
```
Failed requests:        0
```
- Target: 0
- Acceptable: < 1%
- Problem: > 5%

**3. Response Time Percentiles**
```
50%    151 ms   ← Half of requests faster than this
95%    649 ms   ← 95% of requests faster than this
99%    866 ms   ← 99% of requests faster than this
```
- Good: p95 < 500ms
- Acceptable: p95 < 1000ms
- Problem: p95 > 2000ms

**4. Time per Request**
```
Time per request:       255.966 [ms] (mean)
```
- Good: < 300ms
- Acceptable: < 500ms
- Problem: > 1000ms

---

## Test Results Summary

### Current Performance (from last test)

| Endpoint | RPS | Mean Response | Failed | Grade |
|----------|-----|---------------|--------|-------|
| GET Balance | 390.68 | 256ms | 0 | ✅ A |
| POST Deposit | 296.82 | 337ms | 0 | ✅ A |
| POST Withdraw | 316.79 | 316ms | 0 | ✅ A |
| Sustained (200c) | 1,219.37 | 164ms | 0 | ✅ A+ |

**Overall:** ✅ Excellent - Handles 3-12x target load

---

## Common Issues & Solutions

### Issue: Connection Refused
```
curl: (7) Failed to connect to localhost port 8080
```

**Solution:**
```bash
# Start the application
./run-dev.sh

# Wait 15 seconds for startup
sleep 15

# Then run tests
./stress-test.sh
```

---

### Issue: High Failure Rate
```
Failed requests:        250
```

**Possible Causes:**
1. Database connection pool exhausted
2. Application not ready
3. Insufficient resources

**Solution:**
```bash
# Check application logs
tail -f /tmp/app.log

# Increase connection pool (application.properties)
spring.datasource.hikari.maximum-pool-size=50
```

---

### Issue: Slow Response Times
```
Time per request:       2500.000 [ms] (mean)
```

**Possible Causes:**
1. Database queries not optimized
2. No indexes on frequently queried columns
3. Insufficient JVM heap

**Solution:**
```bash
# Check for slow queries
# Enable SQL logging in application.properties
spring.jpa.show-sql=true

# Add indexes to database
# Check RACE_CONDITION_FIX.md for optimization tips
```

---

## Advanced Testing

### Test Specific Concurrency Levels

```bash
# Light load (10 concurrent)
ab -n 1000 -c 10 http://localhost:8080/api/v1/wallets/test/balance

# Medium load (50 concurrent)
ab -n 1000 -c 50 http://localhost:8080/api/v1/wallets/test/balance

# Heavy load (200 concurrent)
ab -n 1000 -c 200 http://localhost:8080/api/v1/wallets/test/balance
```

### Test with Different Request Rates

```bash
# 50 req/s for 20 seconds
ab -n 1000 -c 50 -t 20 http://localhost:8080/api/v1/wallets/test/balance

# 100 req/s for 30 seconds
ab -n 3000 -c 100 -t 30 http://localhost:8080/api/v1/wallets/test/balance

# 200 req/s for 60 seconds
ab -n 12000 -c 200 -t 60 http://localhost:8080/api/v1/wallets/test/balance
```

### Generate Graphs (TSV output)

```bash
# Run with graph data
ab -n 1000 -c 100 -g /tmp/results.tsv \
   http://localhost:8080/api/v1/wallets/test/balance

# View TSV data
cat /tmp/results.tsv
```

---

## Interpreting Load Test Reports

### Good Performance Indicators

✅ **Zero failed requests**  
✅ **RPS > target load**  
✅ **p95 response time < 500ms**  
✅ **Consistent performance across tests**  
✅ **No errors in application logs**  

### Warning Signs

⚠️ **Failed requests > 1%**  
⚠️ **p95 response time > 1000ms**  
⚠️ **High variance in response times**  
⚠️ **Decreasing RPS over time**  
⚠️ **Database connection errors**  

### Critical Issues

❌ **Failed requests > 10%**  
❌ **Application crashes**  
❌ **Data corruption/loss**  
❌ **Memory leaks**  
❌ **Deadlocks**  

---

## Next Steps

1. **Review Results:** Check `LOAD_TEST_REPORT.md`
2. **Fix Issues:** See `RACE_CONDITION_FIX.md` for concurrency fix
3. **Optimize:** Tune database and application settings
4. **Re-test:** Run tests again after changes
5. **Monitor:** Set up production monitoring

---

## Files Reference

- `stress-test.sh` - Comprehensive load test
- `load-test.sh` - Basic load test
- `LOAD_TEST_REPORT.md` - Detailed analysis
- `RACE_CONDITION_FIX.md` - Concurrency issue fix
- `/tmp/load-test-results/` - Raw test output

---

## Support

For issues or questions:
1. Check application logs: `tail -f /tmp/app.log`
2. Review test output in `/tmp/load-test-results/`
3. Verify application is running: `curl http://localhost:8080/api/v1/wallets/test/balance`
