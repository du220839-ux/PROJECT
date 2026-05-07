@echo off
setlocal

cd /d "%~dp0"

echo [1/4] Kill process on port 8000 (if any)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$pids = (Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique); if ($pids) { $pids | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }; Write-Output ('killed: ' + ($pids -join ',')) } else { Write-Output 'no-listener-on-8000' }"

echo [2/4] Reset demo data in SQL Server...
pushd backend
node -r dotenv/config scripts/reset_demo_data.js
if errorlevel 1 (
  echo Reset demo data failed.
  popd
  pause
  exit /b 1
)
popd

echo [3/4] Start backend + Flutter web...
call "%~dp0run_app.bat"

endlocal
