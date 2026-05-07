# SecondHand App - Run Everything Guide

Complete reference for running all components of the SecondHand app.

---

## 📋 Files Created

| File | Purpose |
|------|---------|
| `start-app.ps1` | PowerShell autostart script (Windows) |
| `start-app.sh` | Bash autostart script (Linux/Mac) |
| `STARTUP_GUIDE.md` | Detailed setup & troubleshooting guide |
| `START_HERE.md` | Quick reference (read this first!) |
| `backend/show-help.js` | CLI help for all npm commands |

---

## 🚀 ONE COMMAND STARTUP

### Windows (PowerShell)
```powershell
cd d:\appSenconhand_fluter
.\start-app.ps1
```

### Linux / Mac (Bash)
```bash
cd ~/your-project
chmod +x start-app.sh
./start-app.sh
```

**What happens:**
1. ✅ Checks prerequisites (Node, Flutter)
2. ✅ Tests database connection
3. ✅ Starts backend on http://localhost:8000
4. ✅ Starts frontend on http://localhost:7856
5. ✅ Opens in browser

---

## 📖 Documentation Files

### For Quick Reference
- **START_HERE.md** - Read this first! 5min overview
- **QUICK_START_AI_SEARCH.md** - AI search setup (5 min)

### For Detailed Setup
- **STARTUP_GUIDE.md** - Full guide with all options
- **LOCAL_AI_SEARCH_GUIDE.md** - AI search deep dive

### For Backend Commands
- Run `npm run help` in backend folder
- OR read backend/show-help.js

### API Documentation
- **AI_SEARCH_FEATURE.md** - Full API specs
- Backend API endpoints: http://localhost:8000/api

---

## 🛠️ Backend NPM Commands

**Quick reference (detailed in STARTUP_GUIDE.md):**

```bash
cd backend

# Core
npm run dev              # Start with auto-reload
npm run start            # Start normally

# Setup
npm run setup            # Full setup (install + test)
npm run install:deps     # Install dependencies

# Testing
npm run test:db          # Test database connection
npm run test:api         # Test API endpoints  
npm run test:ai          # Test AI search (free)

# Database
npm run seed:samples     # Add sample products
npm run reset:demo       # Reset to demo data

# Utils
npm run health           # Check if server alive
npm run help             # Show all commands
npm run logs             # Show service URLs
```

---

## 📱 Frontend (Flutter)

**Manual commands (start-app.ps1 runs these):**

```bash
# Get dependencies
flutter pub get

# Run web
flutter run -d chrome --web-port=7856

# Build web
flutter build web

# Run on mobile device
flutter run -d <device-id>
```

---

## 🔍 Verify Everything Works

**Test Backend:**
```bash
curl http://localhost:8000/api/health
# Should return: {"status":"ok","service":"secondhand-backend"}
```

**Test Database:**
```bash
cd backend
npm run test:db
# Should say: ✓ Database connected
```

**Test AI Search (Free):**
```bash
cd backend
npm run test:ai
# Should generate local suggestions
```

**Test Frontend:**
- Open: http://localhost:7856
- Should see login screen

---

## ⚙️ Configuration Files

### Backend (.env)
```env
# Database (SQL Server)
DB_USER=your_username
DB_PASSWORD=your_password
DB_SERVER=your_server
DB_NAME=secondhand_db
DB_PORT=1433
DB_ENCRYPT=true

# API
PORT=8000

# Optional: OpenAI (leave empty for free mode)
OPENAI_API_KEY=
```

Location: `backend/.env`

### Frontend
- Automatic via `lib/config/app_config.dart`
- No .env file needed

---

## 🚦 Common Workflows

### First Time Setup
```powershell
.\start-app.ps1           # This handles everything
```

### Daily Development
```powershell
# Terminal 1: Backend
cd backend && npm run dev

# Terminal 2: Frontend  
flutter run -d chrome --web-port=7856
```

### Quick Database Reset
```bash
cd backend
npm run reset:demo        # Reset data
npm run seed:samples      # Add test products
npm run dev               # Start server
```

### Testing Changes
```bash
# All tests
cd backend
npm run test:db           # Database OK?
npm run test:api          # APIs working?
npm run test:ai           # Search working?
```

---

## 📝 Script Options

### PowerShell Options

```powershell
# Backend only
.\start-app.ps1 -BackendOnly

# Frontend only
.\start-app.ps1 -FlutterOnly

# Custom web port
.\start-app.ps1 -WebPort 8080

# Skip checks
.\start-app.ps1 -NoCheck

# Combine options
.\start-app.ps1 -BackendOnly -NoCheck
```

### Bash Options

```bash
./start-app.sh --backend-only

./start-app.sh --flutter-only

./start-app.sh --web-port=8080

./start-app.sh --no-check
```

---

## 🐛 Troubleshooting

### Port Already in Use

**Windows:**
```powershell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

**Linux/Mac:**
```bash
lsof -i :8000
kill -9 <PID>
```

### Database Won't Connect
```bash
cd backend
npm run test:db           # Check error
# Verify .env is configured
# Verify SQL Server is running
```

### Flutter Not Found
```bash
# Check installation
flutter --version

# Add to PATH if missing
# https://flutter.dev/docs/get-started/install
```

### API Not Responding
```bash
cd backend
npm run health            # Test endpoint
npm run test:api          # Full API test
```

---

## 📊 Service URLs

| Service | URL | Port |
|---------|-----|------|
| Backend API | http://localhost:8000 | 8000 |
| Backend Health | http://localhost:8000/api/health | 8000 |
| AI Search | http://localhost:8000/api/ai | 8000 |
| Flutter Web | http://localhost:7856 | 7856 |
| Database | localhost (configured) | 1433 |

---

## 🔄 Data Management

### Add Sample Products
```bash
cd backend
npm run seed:samples
```

### Reset to Demo Data
```bash
cd backend
npm run reset:demo
```

### Custom Database Operations
```bash
# Direct SQL scripts in database/ folder
database/sqlserver_schema.sql
database/sqlserver_seed_test.sql
```

---

## 📚 For More Information

| Topic | File |
|-------|------|
| Quick overview | START_HERE.md |
| Detailed setup | STARTUP_GUIDE.md |
| AI search | LOCAL_AI_SEARCH_GUIDE.md |
| Backend commands | backend/show-help.js |
| Database schema | database/sqlserver_schema.sql |

---

## ✅ Checklist for First Time

- [ ] Clone repository
- [ ] Create `.env` in `backend/` folder
- [ ] Run `.\start-app.ps1` (or `./start-app.sh`)
- [ ] Wait for both services to start
- [ ] Open http://localhost:7856
- [ ] Login/Register
- [ ] Test search functionality
- [ ] Check backend logs for errors

---

## 🎯 Quick Links

```
Root Directory:
├── START_HERE.md                  👈 Read this first
├── STARTUP_GUIDE.md               👈 Full guide
├── QUICK_START_AI_SEARCH.md       👈 AI setup
├── LOCAL_AI_SEARCH_GUIDE.md       👈 AI deep dive
├── start-app.ps1                  👈 Windows autostart
├── start-app.sh                   👈 Linux/Mac autostart
├── backend/
│   ├── package.json               👈 npm scripts
│   ├── show-help.js               👈 npm run help
│   └── .env                       👈 Configuration
├── lib/
│   ├── screens/ai_search_screen.dart
│   ├── services/ai_search_service.dart
│   ├── providers/search_provider.dart
│   └── config/app_config.dart
└── pubspec.yaml                   👈 Flutter config
```

---

## 🎉 You're Ready!

Everything is set up and documented.

**To start:** Run `.\start-app.ps1` (Windows) or `./start-app.sh` (Linux/Mac)

**Questions?** Check `STARTUP_GUIDE.md` for detailed troubleshooting.

Happy coding! 🚀

---

**Last Updated:** March 20, 2024
**Version:** 1.0.0
