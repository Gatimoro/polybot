@echo off
echo ==========================================
echo Stopping All Polybot Services
echo ==========================================
echo.

cd /d "%~dp0"

echo Stopping Java services...

REM Stop all java processes running the Polybot services
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq java.exe" /fo list ^| findstr "PID"') do (
    for /f "tokens=*" %%a in ('wmic process where "processid=%%i" get commandline /format:list ^| findstr "polybot"') do (
        echo Stopping process %%i...
        taskkill /PID %%i /F > nul 2>&1
    )
)

echo.
echo Stopping Docker containers...
docker-compose -f docker-compose.analytics.yaml down > nul 2>&1
docker-compose -f docker-compose.monitoring.yaml down > nul 2>&1

echo.
echo ==========================================
echo All services stopped
echo ==========================================
echo.
pause
