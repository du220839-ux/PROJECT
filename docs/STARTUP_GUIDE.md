# 🚀 SecondHand App - Startup Guide

Hướng dẫn chi tiết cách chạy ứng dụng từ A đến Z.

## ⚡ Quick Start (1 Command)

Dành cho những ai muốn run nhanh nhất:

```powershell
# Run this in PowerShell from root directory
.\start-app.ps1
```

**That's it!** ✅

Đó là toàn bộ những gì bạn cần. Script sẽ:
1. ✅ Check Node.js, Flutter installed
2. ✅ Test database connection
3. ✅ Start backend server (http://localhost:8000)
4. ✅ Start Flutter web (http://localhost:7856)
5. ✅ Open everything tự động

---

## 📋 Manual Setup (Advanced)

Nếu muốn chạy từng bước một:

### Step 1: Setup Backend

```powershell
cd backend

# Install dependencies
npm install

# Test database
npm run test:db

# Start backend (in new terminal)
npm run dev

# Check health
npm run health
```

**Expected output:**
```
API is running on http://localhost:8000
```

### Step 2: Setup Frontend

```powershell
# In root directory
flutter pub get

# Start web (in new terminal)
flutter run -d chrome --web-port=7856
```

**Expected output:**
```
Chrome will be started as follows:
http://localhost:7856
```

### Step 3: Test AI Search

```powershell
# In backend directory
npm run test:ai

# Or test with curl
curl -X POST http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{"query": "iphone", "limit": 5}'
```

---

## 🛠️ Backend - npm Scripts

```bash
# Development
npm run dev          # Start with auto-reload (best for development)
npm run start        # Start normally (production)

# Testing
npm run test:db      # Test database connection
npm run test:api     # Test API endpoints
npm run test:ai      # Test AI search (local mode, free)

# Database
npm run seed:samples # Add sample products
npm run reset:demo   # Reset to demo data

# Utilities
npm run health       # Check if server is alive
npm run help         # Show all available commands
npm run setup        # Full setup: install + test
```

---

## 🎯 Common Scenarios

### Scenario 1: First Time Setup ✅

```powershell
# Easy way
.\start-app.ps1

# Or manual
cd backend
npm run setup        # This does: npm install + test:db
npm run dev

# In another terminal
flutter pub get
flutter run -d chrome --web-port=7856
```

### Scenario 2: Backend-Only (API Testing)

```powershell
# Using script
.\start-app.ps1 -BackendOnly

# Or manual
cd backend
npm run dev
```

Then test: `http://localhost:8000/api/health`

### Scenario 3: Flutter-Only (if Backend Already Running)

```powershell
# Using script
.\start-app.ps1 -FlutterOnly

# Or manual
flutter run -d chrome --web-port=7856
```

### Scenario 4: Custom Web Port

```powershell
# If port 7856 is busy
.\start-app.ps1 -WebPort 8080

# Or manual
flutter run -d chrome --web-port=8080
```

### Scenario 5: Skip Database Check

```powershell
# If you know database is working
.\start-app.ps1 -NoCheck
```

---

## 🔍 Verification Checklist

### Backend Running?
```bash
npm run health
# Should return: {"status":"ok","service":"secondhand-backend"}
```

### Database Connected?
```bash
npm run test:db
# Should say: ✓ Database connected
```

### AI Search Working (Free Mode)?
```bash
npm run test:ai
# Should generate local suggestions (no API needed)
```

### Frontend Running?
- Open: http://localhost:7856
- Should see login screen

### API Available?
```bash
curl http://localhost:8000/api/products
# Should return product list
```

---

## 📍 Service URLs

| Service | URL | Default Port |
|---------|-----|--------------|
| Backend API | http://localhost:8000 | 8000 |
| Flutter Web | http://localhost:7856 | 7856 |
| Database | (configured in .env) | 1433 |

---

## 🔐 Configuration

### What's Needed (.env file)

**Backend** requires `.env` in `backend/` folder:

```env
# Database (SQL Server)
DB_USER=your_username
DB_PASSWORD=your_password
DB_SERVER=your_server
DB_NAME=secondhand_db
DB_PORT=1433

# API
PORT=8000

# Optional: AI Search with OpenAI (if you want paid mode)
OPENAI_API_KEY=sk-your-key-or-leave-empty

# Other optional configs
JWT_SECRET=your_secret_key
```

**Frontend** uses:
- `lib/config/app_config.dart` - Already configured
- `lib/config/google_signin_config.dart` - For OAuth

No additional setup needed for frontend!

---

## 🐛 Troubleshooting

### "Port 8000 already in use"
```bash
# Kill existing process on port 8000
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Or run on different port in .env
PORT=8001 npm run dev
```

### "Database connection failed"
```bash
# Check .env is configured correctly
# Check SQL Server is running
# Check credentials

npm run test:db  # Get specific error message
```

### "Flutter: Command not found"
```bash
# Flutter not installed
# Install from: https://flutter.dev/docs/get-started/install

# Or check PATH
flutter --version
```

### "Website won't load"
```bash
# Check backend is running
curl http://localhost:8000/api/health

# Check Flutter port is correct (7856)
# Clear cache: flutter clean
# Restart Flutter
```

### "AI Search not working"
```bash
# Test local search (free, always works)
npm run test:ai

# Check if backend is responding
curl http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{"query":"test"}'
```

---

## 📊 Performance Optimization

### For Development
```bash
# Use hot-reload for Flutter
flutter run -d chrome

# Use nodemon for backend (auto-restart)
npm run dev
```

### For Production
```bash
# Build frontend
flutter build web

# Run optimized backend
npm run start
```

---

## 🎯 Development Workflow

### Daily Development

**Terminal 1 - Backend**
```bash
cd backend
npm run dev
```

**Terminal 2 - Frontend**
```bash
flutter run -d chrome --web-port=7856
```

**Terminal 3 - Testing (Optional)**
```bash
# Run tests as needed
npm run test:api
npm run test:ai
```

### Making Changes

**Backend Changes:**
- Edit `backend/src/**/*`
- Auto-reload via nodemon (should be instant)

**Frontend Changes:**
- Edit `lib/**/*.dart`
- Auto-reload via Flutter hot-reload

---

## 📚 Useful Commands

```bash
# Format code
dartfmt -w lib/          # Frontend
npx prettier backend/    # Backend

# Run tests
npm run test:db
npm run test:api
npm run test:ai

# Reset database to demo
npm run reset:demo

# Add sample data
npm run seed:samples

# Update dependencies
npm update
flutter pub upgrade
```

---

## 🚀 Deployment Checklist

Before deploying to production:

```bash
# Backend
□ npm run test:db        # Database working?
□ npm run test:api       # APIs responding?
□ NODE_ENV=production npm run start

# Frontend  
□ flutter build web      # Build production bundle
□ Deploy to hosting service
```

---

## 🆘 Getting Help

### Debug Mode

```bash
# Backend with verbose logging
DEBUG=* npm run dev

# Flutter with verbose
flutter run -v
```

### Check Logs

```bash
# Backend logs are in terminal
# Frontend logs appear in browser console (F12)

# Check .env is loaded
cat backend/.env
```

### System Info

```bash
# Check versions
node --version
npm --version
flutter --version
dart --version

# Check paths
where node
where npm
where flutter
```

---

## ✨ Tips & Tricks

### Faster Startup
```bash
# Skip database check on quick test
.\start-app.ps1 -NoCheck
```

### Parallel Development
```bash
# Use split terminal or multiple windows
# Right-click terminal tab → Split pane (VS Code)
```

### Reset Everything
```bash
cd backend
npm run reset:demo
npm run seed:samples
npm run dev

# In new terminal
flutter clean
flutter pub get
flutter run -d chrome
```

### Monitor Performance
```bash
# Check backend performance
curl http://localhost:8000/api/health

# Check if database is slow
npm run test:db --verbose
```

---

## 📖 More Documentation

- [AI Search Guide](./LOCAL_AI_SEARCH_GUIDE.md)
- [Backend API Docs](./backend/README.txt)
- [Frontend Architecture](./lib/README.md)
- [Database Schema](./database/sqlserver_schema.sql)

---

## 🎉 You're Ready!

Everything is set up. Now:

1. Run: `.\start-app.ps1`
2. Wait for both services to start
3. Go to: http://localhost:7856
4. Start developing! 🎊

---

**Questions?** Check the troubleshooting section or debug the specific error message.

**Last Updated:** March 20, 2024
