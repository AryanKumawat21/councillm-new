@echo off
setlocal
title CounciLLM - Setup Runtime & Models

echo.
echo  ==========================================
echo   CounciLLM Automated Environment Setup
echo  ==========================================
echo.
echo  This script will:
echo   1. Download llama-server Vulkan runtime (~35 MB)
echo   2. Download 4 GGUF models (~9.6 GB total)
echo.
echo  Press any key to begin setup, or close this window to cancel.
pause >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-models.ps1"

echo.
pause
