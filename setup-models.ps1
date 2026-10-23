# CounciLLM - Automated Runtime & Model Downloader
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

$baseDir = $PSScriptRoot
$runtimeDir = Join-Path $baseDir "runtime"
$modelsDir = Join-Path $baseDir "models"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   CounciLLM - Local Runtime & Model Setup   " -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Download llama.cpp Vulkan runtime if missing
$llamaDir = Join-Path $runtimeDir "llama-vulkan-x64"
$llamaExe = Join-Path $llamaDir "llama-server.exe"

if (-not (Test-Path $llamaExe)) {
    Write-Host "[1/5] Downloading llama.cpp Vulkan runtime (~35 MB)..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null
    $zipPath = Join-Path $runtimeDir "llama-win-vulkan-x64.zip"
    $runtimeUrl = "https://github.com/ggml-org/llama.cpp/releases/download/b11838/llama-b11838-bin-win-vulkan-x64.zip"
    Invoke-WebRequest -Uri $runtimeUrl -OutFile $zipPath
    Write-Host "       Extracting runtime..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $llamaDir -Force
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Write-Host "       Runtime installed successfully!" -ForegroundColor Green
} else {
    Write-Host "[1/5] llama-server.exe already installed." -ForegroundColor Green
}

# Helper to download models if missing
function Download-Model($name, $dirName, $fileName, $url, $sizeEst) {
    $dir = Join-Path $modelsDir $dirName
    $filePath = Join-Path $dir $fileName
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    
    if (-not (Test-Path $filePath) -or (Get-Item $filePath).Length -lt 1000000) {
        Write-Host "Downloading $name ($sizeEst)..." -ForegroundColor Yellow
        Write-Host "From: $url" -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $url -OutFile $filePath -TimeoutSec 1800
        $sizeMB = [math]::Round((Get-Item $filePath).Length / 1MB, 1)
        Write-Host "-> $name complete (${sizeMB} MB)!" -ForegroundColor Green
    } else {
        $sizeMB = [math]::Round((Get-Item $filePath).Length / 1MB, 1)
        Write-Host "-> $name already present (${sizeMB} MB)." -ForegroundColor Green
    }
}

# 2. Router Model
Write-Host ""
Write-Host "[2/5] Checking Router Model..." -ForegroundColor Cyan
Download-Model "Qwen3 Router (1.7B)" "qwen3-router" "Qwen3-1.7B-Q6_K.gguf" `
    "https://huggingface.co/lmstudio-community/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q6_K.gguf" "~1.6 GB"

# 3. General Model
Write-Host ""
Write-Host "[3/5] Checking General Reasoning Model..." -ForegroundColor Cyan
Download-Model "Qwen3 General (4B)" "qwen3-general" "Qwen3-4B-Q4_K_M.gguf" `
    "https://huggingface.co/chaparro2001/Qwen3-4B-Instruct-2507-Q4_K_M-GGUF/resolve/main/qwen3-4b-instruct-2507-q4_k_m.gguf" "~2.5 GB"

# 4. Coding Model
Write-Host ""
Write-Host "[4/5] Checking Coding Specialist Model..." -ForegroundColor Cyan
Download-Model "Granite Coding (3B)" "granite-coding" "granite-4.1-3b-q4_k_m.gguf" `
    "https://huggingface.co/phoenix-gurl/granite-4.1-3b-Q4_K_M-GGUF/resolve/main/granite-4.1-3b-q4_k_m.gguf" "~2.1 GB"

# 5. Vision Model & Projector
Write-Host ""
Write-Host "[5/5] Checking Vision Model & Multimodal Projector..." -ForegroundColor Cyan
Download-Model "Qwen3 Vision (4B)" "qwen3-vision" "Qwen3-VL-4B-Instruct-Q4_K_M.gguf" `
    "https://huggingface.co/lmstudio-community/Qwen3-VL-4B-Instruct-GGUF/resolve/main/Qwen3-VL-4B-Instruct-Q4_K_M.gguf" "~2.5 GB"
Download-Model "Qwen3 Vision MMProj" "qwen3-vision" "mmproj-Qwen3-VL-4B-Instruct-F16.gguf" `
    "https://huggingface.co/lmstudio-community/Qwen3-VL-4B-Instruct-GGUF/resolve/main/mmproj-Qwen3-VL-4B-Instruct-F16.gguf" "~800 MB"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host "   Setup Complete! All components ready.     " -ForegroundColor Green
Write-Host "   Double-click START-COUNCILLM.bat to run!  " -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
