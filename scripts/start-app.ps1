# SecondHand App - Complete Startup Script
# PowerShell script to start the entire application
# Usage: .\start-app.ps1

param(
    [switch]$BackendOnly = $false,
    [switch]$FlutterOnly = $false,
    [switch]$NoCheck = $false,
    [string]$WebPort = "7856"
)

# Colors
$GREEN = [ConsoleColor]::Green
$RED = [ConsoleColor]::Red
$YELLOW = [ConsoleColor]::Yellow
$BLUE = [ConsoleColor]::Cyan

# Configuration
$ROOT_DIR = $PSScriptRoot
$BACKEND_DIR = Join-Path $ROOT_DIR "backend"
$PUBSPEC_FILE = Join-Path $ROOT_DIR "pubspec.yaml"

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    switch ($Status) {
        "SUCCESS" { $color = $GREEN }
        "ERROR" { $color = $RED }
        "WARNING" { $color = $YELLOW }
        "INFO" { $color = $BLUE }
        default { $color = $BLUE }
    }
    
    Write-Host "[$timestamp] " -NoNewline
    Write-Host "[$Status] " -ForegroundColor $color -NoNewline
    Write-Host "$Message"
}

function Check-Command {
    param([string]$Command, [string]$DisplayName = $Command)
    
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            Write-Status "$DisplayName installed" "SUCCESS"
            return $true
        }
    } catch {
        Write-Status "$DisplayName NOT found" "ERROR"
        Write-Status "Install from: https://nodejs.org or https://dart.dev/get-dart" "WARNING"
        return $false
    }
}

function Check-Prerequisites {
    Write-Host ""
    Write-Host "================================"
    Write-Host "📋 Checking Prerequisites"
    Write-Host "================================"
    Write-Host ""
    
    $allGood = $true
    
    # Check Node.js
    Write-Status "Checking Node.js..."
    if (-not (Check-Command "node" "Node.js")) {
        $allGood = $false
    }
    
    # Check npm
    Write-Status "Checking npm..."
    if (-not (Check-Command "npm" "npm")) {
        $allGood = $false
    }
    
    # Check Flutter
    Write-Status "Checking Flutter..."
    if (-not (Check-Command "flutter" "Flutter")) {
        Write-Status "Note: Flutter is required for web/mobile builds" "WARNING"
        # Don't fail for this, as backend can run without Flutter
    }
    
    # Check .env file
    Write-Status "Checking .env file..."
    $envFile = Join-Path $BACKEND_DIR ".env"
    if (Test-Path $envFile) {
        Write-Status ".env file found" "SUCCESS"
    } else {
        Write-Status ".env file NOT found - using defaults" "WARNING"
    }
    
    Write-Host ""
    return $allGood
}

function Check-Database {
    Write-Host ""
    Write-Host "================================"
    Write-Host "🗄️  Checking Database"
    Write-Host "================================"
    Write-Host ""
    
    Write-Status "Checking database connection..." "INFO"
    
    $testScript = Join-Path $BACKEND_DIR "test_db.js"
    
    if (Test-Path $testScript) {
        Write-Status "Running database test..." "INFO"
        try {
            $result = & node $testScript 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Status "Database connection successful" "SUCCESS"
                return $true
            } else {
                Write-Status "Database connection failed" "ERROR"
                Write-Status "Make sure SQL Server is running and .env is configured" "WARNING"
                return $false
            }
        } catch {
            Write-Status "Could not run database test" "ERROR"
            return $false
        }
    } else {
        Write-Status "Database test file not found - skipping" "WARNING"
        return $true
    }
}

function Start-Backend {
    Write-Host ""
    Write-Host "================================"
    Write-Host "🔧 Starting Backend Server"
    Write-Host "================================"
    Write-Host ""
    
    Push-Location $BACKEND_DIR
    
    Write-Status "Installing dependencies..." "INFO"
    & npm install --silent 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Failed to install dependencies" "ERROR"
        Pop-Location
        return $false
    }
    
    Write-Status "Dependencies installed" "SUCCESS"
    Write-Host ""
    Write-Status "Starting backend server (npm run dev)..." "INFO"
    Write-Host ""
    
    # Start backend in a new window or in background
    Start-Process -FilePath "cmd.exe" -ArgumentList "/k cd /d $BACKEND_DIR && npm run dev" -WindowTitle "SecondHand Backend"
    
    Write-Status "Backend started in new window" "SUCCESS"
    Start-Sleep -Seconds 3
    
    Pop-Location
    return $true
}

function Start-Flutter {
    param([string]$Port = "7856")
    
    Write-Host ""
    Write-Host "================================"
    Write-Host "📱 Starting Flutter Web"
    Write-Host "================================"
    Write-Host ""
    
    # Check if flutter is installed
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Status "Flutter not installed" "ERROR"
        Write-Status "Install from: https://flutter.dev/docs/get-started/install" "WARNING"
        return $false
    }
    
    Push-Location $ROOT_DIR
    
    Write-Status "Get dependencies..." "INFO"
    & flutter pub get --quiet
    
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Failed to get dependencies" "ERROR"
        Pop-Location
        return $false
    }
    
    Write-Status "Dependencies retrieved" "SUCCESS"
    Write-Host ""
    Write-Status "Starting Flutter web on port $Port..." "INFO"
    Write-Host ""
    
    # Start Flutter in a new window
    Start-Process -FilePath "cmd.exe" -ArgumentList "/k cd /d $ROOT_DIR && flutter run -d chrome --web-port=$Port" -WindowTitle "SecondHand Flutter Web"
    
    Write-Status "Flutter started in new window" "SUCCESS"
    Start-Sleep -Seconds 2
    
    Pop-Location
    return $true
}

function Show-Summary {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗"
    Write-Host "║   ✅ Application Started Successfully ║"
    Write-Host "╚════════════════════════════════════════╝"
    Write-Host ""
    Write-Host "📋 Services Running:"
    Write-Host "   🔧 Backend: http://localhost:8000"
    Write-Host "   📱 Frontend: http://localhost:7856"
    Write-Host ""
    Write-Host "📚 Documentation:"
    Write-Host "   Backend Routes: /api/health"
    Write-Host "   AI Search: /api/ai/search-suggestions"
    Write-Host "   Products: /api/products"
    Write-Host ""
    Write-Host "💡 Tips:"
    Write-Host "   • Check backend logs in the terminal window"
    Write-Host "   • Check Flutter logs in another terminal window"
    Write-Host "   • Press Ctrl+C in any terminal to stop that service"
    Write-Host ""
    Write-Host "🐛 Debugging:"
    Write-Host "   Backend:  http://localhost:8000/api/health"
    Write-Host "   Flutter:  Auto-reload on save"
    Write-Host ""
}

# ============================================
# MAIN EXECUTION
# ============================================

Clear-Host

Write-Host ""
Write-Host "╔════════════════════════════════════════╗"
Write-Host "║  🚀 SecondHand App - Startup Script 🚀║"
Write-Host "╚════════════════════════════════════════╝"
Write-Host ""

# Check prerequisites
if (-not $NoCheck) {
    if (-not (Check-Prerequisites)) {
        Write-Status "Some prerequisites are missing. Continuing anyway..." "WARNING"
    }
    
    # Check database
    if (-not (Check-Database)) {
        Write-Status "Database check failed. Backend may not work properly." "WARNING"
        $continue = Read-Host "Continue anyway? (y/n)"
        if ($continue -ne "y" -and $continue -ne "yes") {
            Write-Status "Startup cancelled" "ERROR"
            exit 1
        }
    }
}

# Start services
$errorCount = 0

if (-not $FlutterOnly) {
    Write-Status "Backend only mode: -BackendOnly" "INFO" 
    if (-not (Start-Backend)) {
        $errorCount++
    }
}

if (-not $BackendOnly) {
    if (-not (Start-Flutter -Port $WebPort)) {
        $errorCount++
    }
}

# Show summary
if ($errorCount -eq 0) {
    Show-Summary
    Write-Status "All services started successfully! 🎉" "SUCCESS"
} else {
    Write-Status "Some services failed to start. Check the error messages above." "ERROR"
}

Write-Host ""
Write-Status "Press Ctrl+C to stop the startup script (services will continue running)" "INFO"
Write-Host ""

# Keep script running to show logs
while ($true) {
    Start-Sleep -Seconds 60
}
