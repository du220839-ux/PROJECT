@echo off
REM Quick AI Backend Health Check for Windows
REM Run this from the project root: backend-health-check.bat

setlocal enabledelayedexpansion
title AI Backend Health Check

cls
echo.
echo 🔍 AI Backend Health Check
echo ================================
echo.

REM Check if backend is running
echo 1️⃣ Checking if backend is running on localhost:8000...
curl -s http://localhost:8000/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Backend is running!
) else (
    echo ❌ Backend is NOT running!
    echo    Run: cd backend ^&^& npm run dev
    exit /b 1
)

REM Test health endpoint
echo.
echo 2️⃣ Testing health endpoint...
for /f "tokens=*" %%a in ('curl -s http://localhost:8000/api/health') do set HEALTH=%%a
echo Response: %HEALTH%

REM Test search suggestions endpoint
echo.
echo 3️⃣ Testing AI search suggestions endpoint...
for /f "tokens=*" %%a in ('curl -s -X POST http://localhost:8000/api/ai/search-suggestions -H "Content-Type: application/json" -d "{\"query\":\"iphone\",\"limit\":5}"') do set SUGGESTIONS=%%a

echo %SUGGESTIONS% | find "suggestions" >nul
if %errorlevel% equ 0 (
    echo ✅ Search suggestions working!
    echo Response: %SUGGESTIONS:~0,200%...
) else (
    echo ❌ Search suggestions failed!
    echo Response: %SUGGESTIONS%
)

REM Test smart search endpoint
echo.
echo 4️⃣ Testing AI smart search endpoint...
for /f "tokens=*" %%a in ('curl -s -X POST http://localhost:8000/api/ai/smart-search -H "Content-Type: application/json" -d "{\"query\":\"laptop\",\"limit\":5,\"page\":1}"') do set SMART=%%a

echo %SMART% | find "products" >nul
if %errorlevel% equ 0 (
    echo ✅ Smart search working!
    echo Response: %SMART:~0,200%...
) else (
    echo ❌ Smart search failed!
    echo Response: %SMART%
)

echo.
echo ================================
echo ✅ Health check complete!
echo.
echo If all tests passed, your AI search should work!
echo If some failed, check:
echo 1. Backend is running: cd backend ^&^& npm run dev
echo 2. Database connection: check .env file
echo 3. Terminal logs for error messages
echo.
pause
