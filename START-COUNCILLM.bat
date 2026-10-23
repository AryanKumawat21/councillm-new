@echo off
setlocal enabledelayedexpansion
title CounciLLM - Local AI Council

:: === CounciLLM Launcher ===
:: Backend:  http://127.0.0.1:8765
:: Requires: Python 3.x, llama-server.exe (bundled in .\runtime\)

set "BASE_DIR=%~dp0"
set "PROJECT_ROOT=%BASE_DIR%CounciLLM\councillm\CounciLLM"
set "SERVER_SCRIPT=%PROJECT_ROOT%\backend\server.py"
set "LLAMA_SERVER=%BASE_DIR%runtime\llama-vulkan-x64\llama-server.exe"
set "LOG_DIR=%PROJECT_ROOT%\logs"
set "PORT=8765"

echo.
echo  ==========================================
echo   CounciLLM - Sovereign Local AI Council
echo  ==========================================
echo.

:: --- Pre-flight checks ---
if not exist "%SERVER_SCRIPT%" (
    echo  [ERROR] Backend not found at:
    echo    %SERVER_SCRIPT%
    echo.
    pause
    exit /b 1
)

if not exist "%LLAMA_SERVER%" (
    echo  [ERROR] llama-server.exe not found at:
    echo    %LLAMA_SERVER%
    echo.
    echo  Re-run the setup to restore the runtime.
    pause
    exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
    echo  [ERROR] Python is not found in PATH.
    echo  Install Python 3 from https://python.org
    pause
    exit /b 1
)

:: --- Check if already running ---
for /f "tokens=*" %%P in ('powershell -NoProfile -Command "try { (Invoke-RestMethod http://127.0.0.1:%PORT%/api/health -TimeoutSec 2).status } catch { ^'^' }"') do set "STATUS=%%P"
if "!STATUS!"=="ok" (
    echo  [INFO] CounciLLM is already running at http://127.0.0.1:%PORT%/
    echo  Opening browser...
    start "" "http://127.0.0.1:%PORT%/"
    echo.
    echo  Press any key to close this launcher window (server stays running).
    pause
    exit /b 0
)

:: --- Set the llama-server path so server.py can find it ---
set "COUNCILLM_LLAMA_SERVER=%LLAMA_SERVER%"

:: --- Create log directory ---
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: --- Start the backend server ---
echo  [INFO] Starting CounciLLM backend...
echo  URL:  http://127.0.0.1:%PORT%/
echo  Logs: %LOG_DIR%
echo.

start /b "" python "%SERVER_SCRIPT%" --port %PORT% > "%LOG_DIR%\councillm-launcher.out.log" 2> "%LOG_DIR%\councillm-launcher.err.log"

:: --- Wait for server to become ready (up to 30 seconds) ---
echo  Waiting for server to start...
set READY=0
for /l %%i in (1,1,30) do (
    if !READY!==0 (
        timeout /t 1 /nobreak >nul
        for /f "tokens=*" %%R in ('powershell -NoProfile -Command "try { (Invoke-RestMethod http://127.0.0.1:%PORT%/api/health -TimeoutSec 1).status } catch { ^'^' }" 2^>nul') do (
            if "%%R"=="ok" set READY=1
        )
    )
)

if !READY!==0 (
    echo.
    echo  [ERROR] CounciLLM did not start within 30 seconds.
    echo.
    echo  Error log:
    type "%LOG_DIR%\councillm-launcher.err.log" 2>nul
    echo.
    pause
    exit /b 1
)

echo.
echo  ==========================================
echo   CounciLLM is ready!
echo   Open: http://127.0.0.1:%PORT%/
echo  ==========================================
echo.
echo  Opening browser...
start "" "http://127.0.0.1:%PORT%/"
echo.
echo  NOTE: Models load dynamically on request:
echo        - Router: Qwen3 1.7B
echo        - General: Qwen3 4B
echo        - Coding: Granite 3B
echo        - Vision: Qwen3-VL 4B
echo.
echo  Keep this window open while using CounciLLM.
echo  Press Ctrl+C or run STOP-COUNCILLM.bat to stop.
echo.

:loop
timeout /t 10 /nobreak >nul
for /f "tokens=*" %%R in ('powershell -NoProfile -Command "try { (Invoke-RestMethod http://127.0.0.1:%PORT%/api/health -TimeoutSec 2).status } catch { ^'offline^' }" 2^>nul') do set "PING=%%R"
if not "!PING!"=="ok" (
    echo  [WARNING] Server stopped responding.
    echo  Check: %LOG_DIR%\councillm-launcher.err.log
    pause
    exit /b 1
)
goto loop