@echo off
echo ==========================================
echo Starting All Polybot Services
echo ==========================================
echo.

cd /d "%~dp0"

REM Check if JAR files exist, if not build
if not exist "executor-service\target\executor-service-0.0.1-SNAPSHOT.jar" (
    echo Building all services...
    call mvn clean package -DskipTests
    echo.
)

REM Create logs directory if not exists
if not exist "logs" mkdir logs

echo Starting services in background...
echo.

REM Start infrastructure orchestrator first
echo 1. Starting infrastructure-orchestrator-service (port 8084)...
echo    This will start: Redpanda, ClickHouse, Prometheus, Grafana, Alertmanager
start /b "" java -jar infrastructure-orchestrator-service\target\infrastructure-orchestrator-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=develop > logs\infrastructure-orchestrator-service.log 2>&1

REM Wait for infrastructure to be ready
echo    Waiting for infrastructure stacks to be ready...
timeout /t 20 /nobreak > nul

REM Start executor service
echo 2. Starting executor-service (port 8080)...
start /b "" java -jar executor-service\target\executor-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=develop > logs\executor-service.log 2>&1

REM Start strategy service
echo 3. Starting strategy-service (port 8081)...
start /b "" java -jar strategy-service\target\strategy-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=develop > logs\strategy-service.log 2>&1

REM Start ingestor service
echo 4. Starting ingestor-service (port 8083)...
start /b "" java -jar ingestor-service\target\ingestor-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=develop > logs\ingestor-service.log 2>&1

REM Start analytics service
echo 5. Starting analytics-service (port 8082)...
start /b "" java -jar analytics-service\target\analytics-service-0.0.1-SNAPSHOT.jar --spring.profiles.active=develop > logs\analytics-service.log 2>&1

echo.
echo ==========================================
echo All services started successfully
echo ==========================================
echo.
echo Service URLs:
echo   - Executor:         http://localhost:8080/actuator/health
echo   - Strategy:         http://localhost:8081/actuator/health
echo   - Analytics:        http://localhost:8082/actuator/health
echo   - Ingestor:         http://localhost:8083/actuator/health
echo   - Infrastructure:   http://localhost:8084/actuator/health
echo.
echo Analytics Stack:
echo   - ClickHouse HTTP:  http://localhost:8123
echo   - Redpanda Kafka:   localhost:9092
echo.
echo Monitoring:
echo   - Grafana:          http://localhost:3000 (admin/polybot123)
echo   - Prometheus:       http://localhost:9090
echo.
echo View Stats:
echo   - Run: view-stats.bat
echo   - Or open: http://localhost:3000 (Grafana)
echo.
echo To stop all services:
echo   - Run: stop-all-services.bat
echo.
pause
