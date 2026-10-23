@echo off
setlocal
title Stop CounciLLM

echo.
echo  ==========================================
echo   Stopping CounciLLM...
echo  ==========================================
echo.

powershell -NoProfile -Command "
    # Stop backend server listening on port 8765 or 8780
    foreach ($port in @(8765, 8780)) {
        $conns = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
        foreach ($conn in $conns) {
            $p = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($p) {
                Write-Host ('Stopping server process (PID ' + $p.Id + ': ' + $p.ProcessName + ') on port ' + $port + '...')
                Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Stop any active llama-server processes
    $llama = Get-Process -Name 'llama-server' -ErrorAction SilentlyContinue
    if ($llama) {
        foreach ($proc in $llama) {
            Write-Host ('Stopping model runtime (PID ' + $proc.Id + ': llama-server)...')
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host 'CounciLLM is fully stopped.'
"

echo.
pause
