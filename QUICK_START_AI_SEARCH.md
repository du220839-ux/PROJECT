# 🚀 AI Search - Quick Start (5 Minutes)

## OPTION 1: FREE LOCAL SEARCH (Recommended) ✅

### Step 1: Edit `.env` file
```bash
cd backend
# Make sure OPENAI_API_KEY is empty or not set:
# OPENAI_API_KEY=
```

### Step 2: Install & Run
```bash
npm install
npm run dev
```

### Step 3: Test
```bash
# In another terminal
curl -X POST http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{"query": "iphone", "limit": 5}'
```

**Result:** You get search suggestions for FREE! 🎉

---

## OPTION 2: OPENAI SEARCH (Optional) 🔵

### Step 1: Get API Key
1. Go to: https://platform.openai.com/api-keys
2. Create new API key
3. Copy key

### Step 2: Edit `.env` file
```bash
cd backend
# Add your OpenAI API key:
OPENAI_API_KEY=sk-your-actual-key-here
```

### Step 3: Install & Run
```bash
npm install
npm run dev
```

### Step 4: Test
```bash
curl -X POST http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{"query": "iphone", "limit": 5}'
```

**Result:** You get SMART search suggestions (but costs money) 💰

---

## Which One to Choose?

| Question | Local ✅ | OpenAI 🔵 |
|----------|---------|---------|
| Do I want to pay? | NO | YES |
| Is it fast? | YES | NO (500ms) |
| Quality? | GOOD | EXCELLENT |
| For production? | For MVP | For scale |
| Just testing? | BEST | Overkill |

**Recommendation:** Start with **LOCAL** (free), upgrade later if needed.

---

## Response Format

Both modes return same format:

```json
{
  "suggestions": ["gợi ý 1", "gợi ý 2", "gợi ý 3"],
  "mode": "local" or "openai"
}
```

The `"mode"` field tells you which one was used! 🎯

---

## Costs Comparison

| Action | Local | OpenAI |
|--------|-------|--------|
| 1 search | $0 | $0.001 |
| 100 searches | $0 | $0.1 |
| 1 month (daily) | $0 | $3-6 |

---

## Troubleshooting

### "No suggestions appearing"
```bash
# Check if backend is running
curl http://localhost:8000/api/health
# Should return: {"status":"ok"}
```

### "Getting expensive bills"
```
# You're using OpenAI. Either:
# 1. Remove OPENAI_API_KEY from .env
# 2. Or disable OpenAI mode in .env
```

### "Suggestions are not good"
```
# Getting LOCAL search? Try OpenAI (costs $)
# Already using OpenAI? Quality should be better
```

---

## Files You Need to Know

**Backend:**
- `backend/src/services/localSearchService.js` - Local search logic
- `backend/src/utils/searchUtils.js` - String similarity algorithms
- `backend/src/controllers/aiController.js` - Both modes

**Frontend:**
- `lib/screens/ai_search_screen.dart` - UI (works with both)
- `lib/services/ai_search_service.dart` - Service layer
- `lib/providers/search_provider.dart` - State management

---

## How System Chooses Mode

```
┌─ Backend starts ─┐
│                 │
└─ Check .env ────┐
│                 │
┌─ OPENAI key set?
│  ├─ YES → Use OpenAI (paid)
│  └─ NO → Use Local (free)
│
└─ Request comes in
   └─ Call appropriate function
      └─ Return results
```

**Result:** You don't need to change code! Just set/unset the env var.

---

## Advanced: How Local Search Works

1. **Extract Keywords** from all products in database
2. **Calculate Similarity** using Levenshtein distance
3. **Rank Results** by relevance score
4. **Return Top N** suggestions

**Example:**
```
User searches: "iphone"

Database has: ["iPhone 13", "iPhone 14 Pro", "iPhone 12", "Samsung Galaxy"]

Score for each:
- "iPhone 13": 95% similar → Rank 1
- "iPhone 14 Pro": 85% similar → Rank 2
- "iPhone 12": 85% similar → Rank 3
- "Samsung Galaxy": 10% similar → Filtered out

Return: ["iPhone 13", "iPhone 14 Pro", "iPhone 12"]
```

---

## Production Deployment

### Recommended Setup:

```bash
# For MVP / Startup
OPENAI_API_KEY=
# (Don't set OpenAI, use free local search)

# For Mature Product
OPENAI_API_KEY=sk-your-production-key
# (Pay small fee for better UX)
```

---

## Next Steps

1. ✅ Choose LOCAL or OpenAI
2. ✅ Set `.env` file
3. ✅ Run `npm install`
4. ✅ Run `npm run dev`
5. ✅ Test with curl
6. ✅ Open app and search!

---

## Still Questions?

📖 Full Docs: Read `LOCAL_AI_SEARCH_GUIDE.md`
🧪 Test It: Run `node test_local_search.js`
🐛 Issues: Check `.env` configuration

---

**TL;DR:** Do nothing → Get FREE search. Set OpenAI key → Better search ($$).

That's it! Enjoy your smart search! 🚀
