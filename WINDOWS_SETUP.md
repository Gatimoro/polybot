# Polybot - Windows Setup Guide (Paper Trading)

## What You'll Get

A fully simulated Polymarket trading bot running on your Windows machine:
- **NO real money involved** - everything is simulated
- **NO API keys needed** - runs completely locally
- Real-time dashboard showing your bot's trades and positions
- Analytics and charts via Grafana web interface

---

## Prerequisites

Install these on your Windows machine:

### 1. Java 21
- Download: https://adoptium.net/temurin/releases/
- Choose: Windows, x64, JDK 21 (LTS)
- Install and verify: Open Command Prompt and run `java -version`

### 2. Maven
- Download: https://maven.apache.org/download.cgi
- Get the Binary zip archive (apache-maven-3.x.x-bin.zip)
- Extract to `C:\Program Files\Maven`
- Add to PATH:
  - Search "Environment Variables" in Windows
  - Edit System Environment Variables → Environment Variables
  - Edit "Path" → Add `C:\Program Files\Maven\bin`
- Verify: `mvn -version` in Command Prompt

### 3. Docker Desktop
- Download: https://www.docker.com/products/docker-desktop/
- Install and start Docker Desktop
- Verify: `docker --version` in Command Prompt

### 4. Python 3.11+
- Download: https://www.python.org/downloads/
- **IMPORTANT**: Check "Add Python to PATH" during installation
- Verify: `python --version` in Command Prompt

### 5. Git (if not already installed)
- Download: https://git-scm.com/download/win
- Install with default settings

---

## Quick Start

### Step 1: Open the Project
```batch
# Open Command Prompt and navigate to the polybot folder
cd C:\path\to\polybot
```

### Step 2: Build the Project (First Time Only)
```batch
mvn clean package -DskipTests
```
This takes 5-10 minutes. You only need to do this once (or after code changes).

### Step 3: Start Everything
```batch
start-all-services.bat
```

This will:
1. Start Docker containers (ClickHouse, Kafka, Grafana, Prometheus)
2. Start all 5 Java services
3. Wait about 30 seconds for everything to be ready

### Step 4: View Your Paper Trading Stats

**Option A: Quick Stats Viewer (Easiest)**
```batch
view-stats.bat
```
Choose option 1 for instant API stats, or option 2 for live dashboard.

**Option B: Grafana Web Dashboard (Most Visual)**
- Open browser: http://localhost:3000
- Username: `admin`
- Password: `polybot123`

**Option C: Direct API Calls**
```batch
# Check current positions
curl http://localhost:8080/api/polymarket/positions

# Check strategy status
curl http://localhost:8081/api/strategy/status

# Service health
curl http://localhost:8080/actuator/health
```

### Step 5: Stop Everything
```batch
stop-all-services.bat
```

---

## Understanding Paper Trading

### What Happens When Running?

1. **Strategy Service** - Generates trading signals based on market data
2. **Executor Service** - Simulates order execution (NO real orders!)
3. **Ingestor Service** - Collects market data from Polymarket
4. **Analytics Service** - Stores and analyzes all simulated trades
5. **ClickHouse** - Database storing all your trading history

### Where Are Results Stored?

All simulated trades are stored in ClickHouse database:
- **Positions**: See what your bot "owns"
- **Orders**: All buy/sell orders placed
- **Fills**: Simulated executions
- **PnL**: Profit and Loss calculations

### Key Files

- **`.env`** - Configuration (already set up for paper trading)
- **`logs/`** - Service log files for debugging
- **`start-all-services.bat`** - Starts everything
- **`stop-all-services.bat`** - Stops everything
- **`view-stats.bat`** - View your stats

---

## Viewing Stats - Detailed Guide

### Method 1: Python Dashboard (Real-time CLI)

```batch
cd research
python -m venv .venv
.venv\Scripts\activate.bat
pip install -r requirements.txt
python paper_trading_dashboard.py --watch
```

Shows:
- Recent orders and fills
- Current positions
- Per-market performance
- Service health status
- Auto-refreshes every 30 seconds

### Method 2: Grafana Dashboards (Web UI)

1. Open http://localhost:3000
2. Login with `admin` / `polybot123`
3. Create new dashboard or use pre-built ones
4. Visualize:
   - Order flow over time
   - Position changes
   - Fill rates
   - Strategy performance

### Method 3: ClickHouse Direct Queries

Access the database directly:
```batch
docker exec -it polybot-clickhouse clickhouse-client
```

Example queries:
```sql
-- View all simulated orders
SELECT * FROM polybot.executor_order_status ORDER BY ts DESC LIMIT 10;

-- Check fill statistics
SELECT
    exchange_status,
    count() as orders,
    sum(matched_size) as total_shares
FROM polybot.executor_order_status
GROUP BY exchange_status;

-- View strategy orders
SELECT * FROM polybot.strategy_gabagool_orders ORDER BY ts DESC LIMIT 10;
```

---

## Configuration Details

### Paper Trading Settings

Already configured in `.env`:
```bash
# These are EMPTY for paper trading (no API needed!)
POLYMARKET_PRIVATE_KEY=
POLYMARKET_API_KEY=
POLYMARKET_API_SECRET=
POLYMARKET_API_PASSPHRASE=
```

### Simulation Settings

Located in `executor-service/src/main/resources/application-develop.yaml`:
```yaml
hft:
  mode: PAPER  # Paper trading mode enabled

executor:
  sim:
    enabled: true
    fills-enabled: true
    maker-fill-probability-per-poll: 0.01  # How often orders fill
```

---

## Troubleshooting

### "Port already in use" error
- Stop all services: `stop-all-services.bat`
- Close Docker Desktop and restart it
- Run `start-all-services.bat` again

### Java version error
- Make sure Java 21 is installed: `java -version`
- Should show version 21.x.x

### Docker not starting
- Make sure Docker Desktop is running
- Check Docker Desktop → Settings → Resources

### Services won't start
- Check logs in `logs/` folder:
  ```batch
  type logs\executor-service.log
  type logs\strategy-service.log
  ```

### Can't see stats
- Make sure services are running:
  ```batch
  curl http://localhost:8080/actuator/health
  ```
- If you get a response, services are up!

### Python errors
- Make sure Python is in PATH: `python --version`
- Recreate virtual environment:
  ```batch
  cd research
  rmdir /s .venv
  python -m venv .venv
  .venv\Scripts\activate.bat
  pip install -r requirements.txt
  ```

---

## FAQ

**Q: Do I need a Polymarket account?**
A: No! Paper trading is 100% simulated.

**Q: Do I need any API keys?**
A: No! Everything runs locally without any external authentication.

**Q: Is this using real money?**
A: No! The system is configured for PAPER trading (simulation only).

**Q: How do I switch to real trading?**
A: DON'T do this unless you know what you're doing! You'd need:
- Polymarket account with API keys
- Private key for your wallet
- Change `hft.mode` from `PAPER` to `LIVE`
- Real money at risk!

**Q: Where can I see what the bot is doing?**
A: Three ways:
1. Run `view-stats.bat` (easiest)
2. Open http://localhost:3000 (Grafana - most visual)
3. Check `logs\executor-service.log` (detailed)

**Q: How do I know if it's working?**
A: Check the logs - you should see:
- "Market data received" messages
- "Order placed" messages
- "Fill simulated" messages
- No errors about missing API keys (that's normal for paper trading!)

**Q: Can I run this 24/7?**
A: Yes! Just leave it running. It uses ~2-4GB RAM.

**Q: How do I update the code?**
A:
```batch
git pull
mvn clean package -DskipTests
stop-all-services.bat
start-all-services.bat
```

---

## Next Steps

1. Let it run for a few hours to collect data
2. View stats using `view-stats.bat`
3. Check Grafana dashboards at http://localhost:3000
4. Analyze the strategy performance
5. Modify strategies in `strategy-service/` if you want to experiment

---

## Support

- View logs: `type logs\executor-service.log`
- Check health: `curl http://localhost:8080/actuator/health`
- Issues: Check the GitHub issues page

**Remember: This is paper trading - completely safe, no real money involved!**
