@echo off
echo ==========================================
echo Polybot Paper Trading Stats Viewer
echo ==========================================
echo.

cd /d "%~dp0"

REM Check if Python virtual environment exists
if not exist "research\.venv" (
    echo Setting up Python environment...
    cd research
    python -m venv .venv
    call .venv\Scripts\activate.bat
    pip install -r requirements.txt
    cd ..
    echo.
)

REM Check if services are running
echo Checking if services are running...
curl -s http://localhost:8080/actuator/health > nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Services are not running!
    echo Please run start-all-services.bat first.
    echo.
    pause
    exit /b 1
)

echo Services are running!
echo.
echo Choose viewing option:
echo 1. Quick API Stats (instant)
echo 2. Full Dashboard (refreshing)
echo 3. Open Grafana in browser
echo.
choice /c 123 /n /m "Select option (1-3): "

if errorlevel 3 goto grafana
if errorlevel 2 goto dashboard
if errorlevel 1 goto api

:api
echo.
echo === Current Positions ===
curl -s http://localhost:8080/api/polymarket/positions 2>nul
echo.
echo.
echo === Strategy Status ===
curl -s http://localhost:8081/api/strategy/status 2>nul
echo.
echo.
pause
goto end

:dashboard
cd research
call .venv\Scripts\activate.bat
python paper_trading_dashboard.py --watch
cd ..
goto end

:grafana
start http://localhost:3000
echo Opening Grafana in your browser...
echo Username: admin
echo Password: polybot123
echo.
pause
goto end

:end
