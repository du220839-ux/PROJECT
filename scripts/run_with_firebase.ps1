# PowerShell script to run Flutter with Firebase environment variables

# Change to app directory
cd D:\appSenconhand_fluter

# Display what we're doing
Write-Host "Starting Flutter app with Firebase configuration..." -ForegroundColor Green
Write-Host "Firebase Project: sencond2-c9074" -ForegroundColor Cyan
Write-Host "Port: 7858" -ForegroundColor Cyan

# Define Firebase config (using --dart-define for compile-time variables)
$dartDefines = @(
    "--dart-define=FIREBASE_API_KEY=AIzaSyCbBNiYNS6b2enJ17RbiJhxnXv7gbM-oYQ",
    "--dart-define=FIREBASE_APP_ID=1:256558197701:web:74fe667cf76ae2c15d39ac",
    "--dart-define=FIREBASE_MESSAGING_SENDER_ID=256558197701",
    "--dart-define=FIREBASE_PROJECT_ID=sencond2-c9074",
    "--dart-define=FIREBASE_AUTH_DOMAIN=sencond2-c9074.firebaseapp.com",
    "--dart-define=FIREBASE_STORAGE_BUCKET=sencond2-c9074.firebasestorage.app"
)

# Run Flutter with Chrome on port 7856 and Firefox defines
$command = "flutter run -d chrome --web-port=7856 $($dartDefines -join ' ')"
Write-Host "Command: $command" -ForegroundColor Yellow
Invoke-Expression $command
