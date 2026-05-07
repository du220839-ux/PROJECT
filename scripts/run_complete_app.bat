@echo off
setlocal

cd /d "%~dp0"

echo ========================================
echo   SECONDHAND APP - COMPLETE STARTER
echo ========================================
echo.

REM Firebase Configuration
set "FIREBASE_API_KEY=AIzaSyCbBNiYNS6b2enJ17RbiJhxnXv7gbM-oYQ"
set "FIREBASE_APP_ID=1:256558197701:web:74fe667cf76ae2c15d39ac"
set "FIREBASE_MESSAGING_SENDER_ID=256558197701"
set "FIREBASE_PROJECT_ID=sencond2-c9074"
set "FIREBASE_AUTH_DOMAIN=sencond2-c9074.firebaseapp.com"
set "FIREBASE_STORAGE_BUCKET=sencond2-c9074.appspot.com"

REM App Configuration
set "BACKEND_DIR=%CD%\backend"
set "FLUTTER_BIN=%USERPROFILE%\flutter_sdk\bin\flutter.bat"
set "API_BASE_URL=http://127.0.0.1:8000/api"
set "WEB_PORT=3000"

echo [1/3] Starting Backend Server...
echo Location: %BACKEND_DIR%
echo URL: %API_BASE_URL%
echo.

REM Check if backend is already running
netstat -an | findstr ":8000" >nul
if %errorlevel% equ 0 (
    echo Backend already running on port 8000
    echo.
) else (
    echo Starting new backend instance...
    start "SecondHand Backend Server" cmd /k "cd /d %BACKEND_DIR% && npm run dev"
    echo Waiting for backend to start...
    timeout /t 5 /nobreak >nul
)

echo [2/3] Checking Backend Health...
curl -s http://127.0.0.1:8000/api >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Backend is running and responding
) else (
    echo ⚠️  Backend not responding, but continuing...
)
echo.

echo [3/3] Starting Flutter Web App with Firebase...
echo Firebase Project: %FIREBASE_PROJECT_ID%
echo Web URL: http://localhost:%WEB_PORT%
echo.

"%FLUTTER_BIN%" run -d chrome --web-port %WEB_PORT% --dart-define=API_BASE_URL=%API_BASE_URL% --dart-define=FIREBASE_API_KEY=%FIREBASE_API_KEY% --dart-define=FIREBASE_APP_ID=%FIREBASE_APP_ID% --dart-define=FIREBASE_MESSAGING_SENDER_ID=%FIREBASE_MESSAGING_SENDER_ID% --dart-define=FIREBASE_PROJECT_ID=%FIREBASE_PROJECT_ID% --dart-define=FIREBASE_AUTH_DOMAIN=%FIREBASE_AUTH_DOMAIN% --dart-define=FIREBASE_STORAGE_BUCKET=%FIREBASE_STORAGE_BUCKET%

echo.
echo ========================================
echo   APP STARTED SUCCESSFULLY!
echo ========================================
echo.
echo 🌐 Frontend: http://localhost:%WEB_PORT%
echo 🔧 Backend API: http://localhost:8000/api
echo 🔥 Firebase: %FIREBASE_PROJECT_ID%
echo.
echo Press Ctrl+C to stop all services
echo.

REM Keep window open
pause
