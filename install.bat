@echo off
REM Voice AI Agent Auto Installer for Windows

echo =========================================
echo Voice AI Agent - Auto Installer
echo =========================================
echo.

REM Step 1: Check Python version
echo [INFO] Checking Python version...
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python not found. Please install Python 3.10+ first.
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [SUCCESS] Python %PYTHON_VERSION% found
echo.

REM Step 2: Install uv package manager
echo [INFO] Checking for uv package manager...
where uv > nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] uv already installed
) else (
    echo [INFO] Installing uv package manager...
    powershell -Command "irm https://astral.sh/uv/install.ps1 | iex"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install uv
        pause
        exit /b 1
    )
    echo [SUCCESS] uv installed
)
echo.

REM Step 3: Install LiveKit CLI
echo [INFO] Checking for LiveKit CLI...
where lk > nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] LiveKit CLI already installed
) else (
    echo [INFO] Installing LiveKit CLI via winget...
    winget install LiveKit.LiveKitCLI
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to install LiveKit CLI via winget
        echo Please install manually from: https://github.com/livekit/livekit-cli/releases
    ) else (
        echo [SUCCESS] LiveKit CLI installed
    )
)
echo.

REM Step 4: Install project dependencies
echo [INFO] Installing project dependencies...
call uv sync
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [SUCCESS] Dependencies installed
echo.

REM Step 5: Download model files
echo [INFO] Downloading required model files...
call uv run agent.py download-files
if %errorlevel% neq 0 (
    echo [WARNING] Failed to download model files
    echo You may need to run 'uv run agent.py download-files' manually
) else (
    echo [SUCCESS] Model files downloaded
)
echo.

REM Step 6: Setup environment variables
echo [INFO] Setting up environment variables...
if not exist .env.local (
    copy .env-example .env.local
    echo [SUCCESS] Created .env.local from template
    
    echo.
    echo =========================================
    echo Environment Configuration
    echo =========================================
    echo.
    
    echo Would you like to configure LiveKit now? (y/n)
    set /p configure_livekit=
    
    if /i "%configure_livekit%"=="y" (
        echo.
        echo [INFO] LiveKit Cloud authentication...
        call lk cloud auth
        
        echo.
        echo [INFO] Generating LiveKit environment variables...
        call lk app env -w
    )
    
    echo.
    echo You'll need to configure the following API keys in .env.local:
    echo   1. DEEPGRAM_API_KEY - Get it from: https://console.deepgram.com/
    echo   2. OPENAI_API_KEY - For DeepSeek, get it from: https://platform.deepseek.com/
    echo.
    echo Please edit .env.local and add your API keys before running the agent.
) else (
    echo [SUCCESS] .env.local already exists
)
echo.

REM Step 7: Installation complete
echo =========================================
echo Installation Complete!
echo =========================================
echo.
echo Next steps:
echo   1. Make sure all API keys are configured in .env.local
echo   2. Start the agent with: uv run agent.py dev
echo   3. Open the frontend: start frontend\index.html
echo.
echo For local LLM setup, see DEPLOYMENT.md
echo.
echo [SUCCESS] You're all set! Happy building!
echo.
pause
