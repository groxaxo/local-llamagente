@echo off
REM Parakeet STT Service Setup and Test Script for Windows
REM This script sets up and tests the Parakeet TDT STT service

echo.
echo Parakeet TDT STT Service Setup
echo ==================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    exit /b 1
)

REM Check if Docker Compose is installed
docker compose version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)

echo [OK] Docker and Docker Compose are installed
echo.

REM Build and start the service
echo Building Parakeet STT Docker image...
docker compose build parakeet-stt

echo.
echo Starting Parakeet STT service...
docker compose up -d parakeet-stt

echo.
echo Waiting for service to be ready (this may take a minute)...
timeout /t 10 /nobreak >nul

REM Check if service is running
docker compose ps | findstr "parakeet-stt" | findstr "running" >nul
if errorlevel 1 (
    echo [ERROR] Service failed to start
    echo Checking logs:
    docker compose logs parakeet-stt
    exit /b 1
)

echo [OK] Service is running
echo.

REM Test the health endpoint
echo Testing health endpoint...
set MAX_RETRIES=30
set RETRY_COUNT=0

:retry_loop
if %RETRY_COUNT% geq %MAX_RETRIES% goto health_failed
curl -s http://localhost:5092/health >nul 2>&1
if errorlevel 1 (
    set /a RETRY_COUNT+=1
    echo Waiting for service... (attempt %RETRY_COUNT%/%MAX_RETRIES%)
    timeout /t 2 /nobreak >nul
    goto retry_loop
)

echo [OK] Health check passed
curl -s http://localhost:5092/health
echo.
goto success

:health_failed
echo [ERROR] Service health check failed after %MAX_RETRIES% attempts
echo Checking logs:
docker compose logs parakeet-stt
exit /b 1

:success
echo.
echo Parakeet STT Service Setup Complete!
echo.
echo Service Information:
echo   - URL: http://localhost:5092
echo   - API Endpoint: http://localhost:5092/v1/audio/transcriptions
echo   - Web Interface: http://localhost:5092
echo   - Health Check: http://localhost:5092/health
echo.
echo To view logs:
echo   docker compose logs -f parakeet-stt
echo.
echo To stop the service:
echo   docker compose down
echo.
echo Next steps:
echo   1. Configure your .env.local file with:
echo      PARAKEET_BASE_URL=http://localhost:5092/v1
echo      STT_MODEL=parakeet-tdt-0.6b-v3
echo   2. Start the agent: uv run agent.py dev
echo.
