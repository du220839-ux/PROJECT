# 🚀 SecondHand App - Quick Setup

**Run one command to start everything:**

### Windows (PowerShell)
```powershell
.\start-app.ps1
```

### Linux / Mac (Bash)
```bash
bash start-app.sh
# or
chmod +x start-app.sh
./start-app.sh
```

---

## What This Does

✅ Checks Node.js, Flutter installed  
✅ Tests database connection  
✅ Starts backend server on port 8000  
✅ Starts Flutter web on port 7856  
✅ Opens everything in browser  

---

## 📖 Full Documentation

See [STARTUP_GUIDE.md](./STARTUP_GUIDE.md) for:
- Detailed setup instructions
- Manual step-by-step setup
- Troubleshooting guide
- Available npm commands
- Performance optimization
- Deployment checklist

---

## ⚡ Quick Options

```powershell
# Backend only
.\start-app.ps1 -BackendOnly

# Flutter only  
.\start-app.ps1 -FlutterOnly

# Custom port
.\start-app.ps1 -WebPort 8080

# Skip database check
.\start-app.ps1 -NoCheck
```

---

## 🔍 Verify It's Working

| Service | URL |
|---------|-----|
| Backend API | http://localhost:8000/api/health |
| Frontend | http://localhost:7856 |

---

## 📱 Using the App

1. Open http://localhost:7856
2. Sign up or login
3. Start selling/buying!

---

**Need help?** Read [STARTUP_GUIDE.md](./STARTUP_GUIDE.md) 📖
