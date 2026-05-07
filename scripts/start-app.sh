#!/bin/bash
# SecondHand App - Complete Startup Script (Linux/Mac)
# Usage: bash start-app.sh [options]
# Options: --backend-only, --flutter-only, --no-check, --web-port=PORT

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
WEB_PORT=7856
BACKEND_ONLY=false
FLUTTER_ONLY=false
NO_CHECK=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --backend-only)
            BACKEND_ONLY=true
            shift
            ;;
        --flutter-only)
            FLUTTER_ONLY=true
            shift
            ;;
        --no-check)
            NO_CHECK=true
            shift
            ;;
        --web-port=*)
            WEB_PORT="${arg#*=}"
            shift
            ;;
    esac
done

# Helper functions
write_status() {
    local message=$1
    local status=$2
    local timestamp=$(date '+%H:%M:%S')
    
    case $status in
        SUCCESS)
            echo -e "[$timestamp] ${GREEN}[SUCCESS]${NC} $message"
            ;;
        ERROR)
            echo -e "[$timestamp] ${RED}[ERROR]${NC} $message"
            ;;
        WARNING)
            echo -e "[$timestamp] ${YELLOW}[WARNING]${NC} $message"
            ;;
        INFO)
            echo -e "[$timestamp] ${BLUE}[INFO]${NC} $message"
            ;;
    esac
}

check_command() {
    local command=$1
    local display_name=$2
    
    if command -v "$command" &> /dev/null; then
        write_status "$display_name installed" "SUCCESS"
        return 0
    else
        write_status "$display_name NOT found" "ERROR"
        return 1
    fi
}

check_prerequisites() {
    echo ""
    echo "================================"
    echo "📋 Checking Prerequisites"
    echo "================================"
    echo ""
    
    local all_good=true
    
    # Check Node.js
    write_status "Checking Node.js..." "INFO"
    if ! check_command "node" "Node.js"; then
        all_good=false
        write_status "Install from: https://nodejs.org" "WARNING"
    fi
    
    # Check npm
    write_status "Checking npm..." "INFO"
    if ! check_command "npm" "npm"; then
        all_good=false
        write_status "Install from: https://npmjs.com" "WARNING"
    fi
    
    # Check Flutter
    write_status "Checking Flutter..." "INFO"
    if ! check_command "flutter" "Flutter"; then
        write_status "Note: Flutter is required for web/mobile builds" "WARNING"
    fi
    
    # Check .env file
    write_status "Checking .env file..." "INFO"
    if [ -f "$BACKEND_DIR/.env" ]; then
        write_status ".env file found" "SUCCESS"
    else
        write_status ".env file NOT found - using defaults" "WARNING"
    fi
    
    echo ""
    return $([ "$all_good" = true ] && echo 0 || echo 1)
}

check_database() {
    echo ""
    echo "================================"
    echo "🗄️  Checking Database"
    echo "================================"
    echo ""
    
    write_status "Checking database connection..." "INFO"
    
    local test_script="$BACKEND_DIR/test_db.js"
    
    if [ -f "$test_script" ]; then
        write_status "Running database test..." "INFO"
        if node "$test_script" 2>/dev/null; then
            write_status "Database connection successful" "SUCCESS"
            return 0
        else
            write_status "Database connection failed" "ERROR"
            write_status "Make sure SQL Server is running and .env is configured" "WARNING"
            return 1
        fi
    else
        write_status "Database test file not found - skipping" "WARNING"
        return 0
    fi
}

start_backend() {
    echo ""
    echo "================================"
    echo "🔧 Starting Backend Server"
    echo "================================"
    echo ""
    
    cd "$BACKEND_DIR"
    
    write_status "Installing dependencies..." "INFO"
    npm install --silent 2>/dev/null || {
        write_status "Failed to install dependencies" "ERROR"
        cd - > /dev/null
        return 1
    }
    
    write_status "Dependencies installed" "SUCCESS"
    echo ""
    write_status "Starting backend server (npm run dev)..." "INFO"
    echo ""
    
    # Start in background if running both
    if [ "$FLUTTER_ONLY" = true ]; then
        npm run dev
    else
        # Run in a new terminal (macOS/Linux)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS - use Terminal
            osascript -e "tell application \"Terminal\" to do script \"cd '$BACKEND_DIR' && npm run dev\""
        else
            # Linux - use gnome-terminal or xterm
            if command -v gnome-terminal &> /dev/null; then
                gnome-terminal -- bash -c "cd '$BACKEND_DIR' && npm run dev; exec bash"
            elif command -v xterm &> /dev/null; then
                xterm -e "cd '$BACKEND_DIR' && npm run dev" &
            else
                write_status "Could not open terminal for backend. Running in foreground." "WARNING"
                npm run dev
            fi
        fi
    fi
    
    write_status "Backend started" "SUCCESS"
    sleep 3
    
    cd - > /dev/null
    return 0
}

start_flutter() {
    local port=$1
    
    echo ""
    echo "================================"
    echo "📱 Starting Flutter Web"
    echo "================================"
    echo ""
    
    # Check if flutter is installed
    if ! check_command "flutter" "Flutter"; then
        write_status "Flutter not installed" "ERROR"
        write_status "Install from: https://flutter.dev/docs/get-started/install" "WARNING"
        return 1
    fi
    
    cd "$ROOT_DIR"
    
    write_status "Get dependencies..." "INFO"
    flutter pub get --quiet || {
        write_status "Failed to get dependencies" "ERROR"
        cd - > /dev/null
        return 1
    }
    
    write_status "Dependencies retrieved" "SUCCESS"
    echo ""
    write_status "Starting Flutter web on port $port..." "INFO"
    echo ""
    
    # Start in a new terminal
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        osascript -e "tell application \"Terminal\" to do script \"cd '$ROOT_DIR' && flutter run -d chrome --web-port=$port\""
    else
        # Linux
        if command -v gnome-terminal &> /dev/null; then
            gnome-terminal -- bash -c "cd '$ROOT_DIR' && flutter run -d chrome --web-port=$port; exec bash"
        elif command -v xterm &> /dev/null; then
            xterm -e "cd '$ROOT_DIR' && flutter run -d chrome --web-port=$port" &
        else
            write_status "Could not open terminal for Flutter. Running in foreground." "WARNING"
            flutter run -d chrome --web-port=$port
        fi
    fi
    
    write_status "Flutter started" "SUCCESS"
    sleep 2
    
    cd - > /dev/null
    return 0
}

show_summary() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   ✅ Application Started Successfully ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "📋 Services Running:"
    echo "   🔧 Backend: http://localhost:8000"
    echo "   📱 Frontend: http://localhost:$WEB_PORT"
    echo ""
    echo "📚 Documentation:"
    echo "   Backend Routes: /api/health"
    echo "   AI Search: /api/ai/search-suggestions"
    echo "   Products: /api/products"
    echo ""
    echo "💡 Tips:"
    echo "   • Check backend logs in the terminal window"
    echo "   • Check Flutter logs in another terminal window"
    echo "   • Press Ctrl+C in any terminal to stop that service"
    echo ""
    echo "🐛 Debugging:"
    echo "   Backend:  http://localhost:8000/api/health"
    echo "   Flutter:  Auto-reload on save"
    echo ""
}

# ============================================
# MAIN EXECUTION
# ============================================

clear

echo ""
echo "╔════════════════════════════════════════╗"
echo "║  🚀 SecondHand App - Startup Script 🚀║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check prerequisites
if [ "$NO_CHECK" != true ]; then
    if ! check_prerequisites; then
        write_status "Some prerequisites are missing. Continuing anyway..." "WARNING"
    fi
    
    # Check database
    if ! check_database; then
        write_status "Database check failed. Backend may not work properly." "WARNING"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            write_status "Startup cancelled" "ERROR"
            exit 1
        fi
    fi
fi

# Start services
local error_count=0

if [ "$FLUTTER_ONLY" != true ]; then
    if ! start_backend; then
        ((error_count++))
    fi
fi

if [ "$BACKEND_ONLY" != true ]; then
    if ! start_flutter $WEB_PORT; then
        ((error_count++))
    fi
fi

# Show summary
if [ $error_count -eq 0 ]; then
    show_summary
    write_status "All services started successfully! 🎉" "SUCCESS"
else
    write_status "Some services failed to start. Check the error messages above." "ERROR"
fi

echo ""
write_status "Press Ctrl+C to stop this script" "INFO"
echo ""

# Keep script running
while true; do
    sleep 60
done
