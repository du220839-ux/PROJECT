# AI Search - Free Alternative Guide

**TL;DR:** Bạn có **2 lựa chọn** cho AI search:
1. **🟢 LOCAL SEARCH** - 100% miễn phí, chạy trên server của bạn
2. **🔵 OPENAI SEARCH** - Tốn $0.001-0.002/search, nhưng chất lượng tốt hơn

## Quick Start - Chọn Mode

### Option 1: LOCAL SEARCH (Recommended - Free) ✅

**Setup:**
1. Mở file `.env` trong thư mục `backend/`
2. Đảm bảo **không có** OpenAI key hoặc để trống:
   ```env
   # Không set OPENAI_API_KEY hoặc để trống
   OPENAI_API_KEY=
   ```
3. Chạy:
   ```bash
   cd backend
   npm install
   npm run dev
   ```

**Kết quả:**
- System tự động dùng **Local Search** 
- **100% free**, không tốn tiền
- Chạy ở **localhost:8000**
- Response có: `"mode": "local"`

**Ưu điểm:**
- ✅ Hoàn toàn miễn phí
- ✅ Chạy quicker (không cần gọi external API)
- ✅ Không phụ thuộc vào OpenAI
- ✅ Perfect cho dev/test

**Nhược điểm:**
- ⚠️ Gợi ý có thể không "thông minh" như OpenAI
- ⚠️ Dựa vào fuzzy matching, không học từ context

---

### Option 2: OPENAI SEARCH (Paid) 🔵

**Setup:**
1. Tạo OpenAI account tại: https://platform.openai.com
2. Lấy API key tại: https://platform.openai.com/api-keys
3. Copy key vào `.env`:
   ```env
   OPENAI_API_KEY=sk-your-actual-key-here
   ```
4. Chạy:
   ```bash
   cd backend
   npm install
   npm run dev
   ```

**Kết quả:**
- System tự động dùng **OpenAI Search**
- Response có: `"mode": "openai"`

**Chi phí chi tiết:**
| Hành động | Chi phí |
|----------|--------|
| 1 lần gợi ý | ~$0.0001-0.0005 |
| 1 lần search | ~$0.001-0.002 |
| 100 searches/ngày | ~$0.1-0.2 |
| 1 tháng (100/ngày) | ~$3-6 |

**Ưu điểm:**
- ✅ Gợi ý "thông minh" từ GPT
- ✅ Giải thích tự nhiên
- ✅ Học context tốt
- ✅ Xử lý typo tốt

**Nhược điểm:**
- ⚠️ Tốn phí
- ⚠️ Phụ thuộc vào OpenAI availability
- ⚠️ Slow hơn (gọi external API)

---

## Cách System Hoạt Động

```
┌─────────────────────────────────────────┐
│  User nhập search query                 │
└──────────────────┬──────────────────────┘
                   │
         ┌─────────▼─────────┐
         │ Check env var:    │
         │ OPENAI_API_KEY    │
         └────┬─────────┬────┘
              │         │
         CÓ  │         │  NÓ
             │         │
    ┌────────▼──┐  ┌───▼─────────┐
    │  Use      │  │ Use         │
    │  OpenAI   │  │ Local       │
    │  API      │  │ Algorithm   │
    └────────┬──┘  └───┬─────────┘
             │         │
         ┌───▴─────────▴───┐
         │ Return Result   │
         │ + Mode info     │
         └─────────────────┘
```

## API Response Format

### Both modes return:
```json
{
  "suggestions": ["gợi ý 1", "gợi ý 2", ...],
  "mode": "local" or "openai"
}
```

### Smart Search Response:
```json
{
  "products": [
    {
      "id": 1,
      "title": "iPhone 13",
      "price": 15000000,
      "category_name": "Điện thoại",
      "image_count": 3,
      ...
    }
  ],
  "explanation": "Tìm thấy X sản phẩm khớp với...",
  "mode": "local" or "openai"
}
```

---

## Local Search Algorithm Chi Tiết

### 1. **String Similarity** (Levenshtein Distance)
Tính độ giống của 2 string:
```
"iphone" vs "iphone" = 100% giống
"iphone" vs "ihpone" = 90% giống (1 ký tự sai)
"iphone" vs "samsung" = 40% giống
```

### 2. **Relevance Scoring**
```
100 điểm: Exact match
90 điểm:  Prefix match (iphone 14 match "iphone")
80 điểm:  Word match
70 điểm:  Contains match
0-60:     Fuzzy match
```

### 3. **Product Ranking**
```
Title match:       50 points
Description:      30 points  
Category match:   20 points
Recency bonus:    +5-10 points (mới hơn rank cao)
```

### 4. **Suggestion Generation**
- Extract keywords từ tất cả products có status='approved'
- Rank keywords bằng relevance score
- Return top N keywords

---

## Testing Local Search

### Test 1: Get Suggestions
```bash
curl -X POST http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{"query": "iphone", "limit": 5}'
```

Expected Response:
```json
{
  "suggestions": ["iPhone 13", "iPhone 14 Pro Max", "iPhone 12", "iPhone 11", "iPhone 13 Pro"],
  "mode": "local"
}
```

### Test 2: Smart Search
```bash
curl -X POST http://localhost:8000/api/ai/smart-search \
  -H "Content-Type: application/json" \
  -d '{"query": "iphone", "limit": 10, "page": 1}'
```

Expected Response:
```json
{
  "products": [...],
  "explanation": "Tìm thấy X sản phẩm điện thoại phù hợp với search của bạn",
  "mode": "local"
}
```

---

## Performance Comparison

| Metric | Local | OpenAI |
|--------|-------|--------|
| Speed | ~10ms | ~500-1000ms |
| Cost | Free | $0.001-0.002 |
| Quality | Good | Excellent |
| Setup | Easy | Medium |
| Reliability | 100% (offline) | 99.9% |

---

## Fallback Logic

Nếu OpenAI API fail mà bạn có key:
1. Try gọi OpenAI
2. Nếu lỗi → **tự động fallback** sang Local Search
3. User vẫn nhận được kết quả tốt

```js
if (useOpenAI && openai) {
  try {
    return getSearchSuggestionsOpenAI(...);
  } catch (error) {
    // Fallback to local search
    return getSearchSuggestionsLocal(...);
  }
}
```

---

## Production Recommendations

### Nếu Startup/MVP:
```env
# Dùng Local Search - free, đối tượng hạn chế
OPENAI_API_KEY=
```

### Nếu Sản phẩm Trưởng Thành:
```env
# Nâng cấp OpenAI sau
# - Scale users
# - Tốn ~$50-100/tháng (tối đa 50k searches/ngày)
OPENAI_API_KEY=sk-your-key
```

### Nếu Large Scale:
```
Xem xét các thay thế:
- Elasticsearch (full-text search)
- Algolia (search service)
- MeiliSearch (open source)
```

---

## Troubleshooting

### Q: Suggestions không xuất hiện?
**A:** Check:
1. Backend running? `npm run dev`
2. Database có products? `SELECT * FROM products WHERE status='approved'`
3. Chạy cURL test

### Q: Chậm quá?
**A:**
- Nếu OpenAI: chuyển sang Local
- Nếu Local: check database indexes

### Q: Chất lượng suggestions kém?
**A:** Dùng OpenAI (phí nhỏ)

### Q: Sao mà lỗi khi dùng OpenAI?
**A:** 
1. Check key valid: https://platform.openai.com/api-keys
2. Check quota
3. Check internet connection
4. Fallback sẽ tự động

---

## Next Steps

### Recommended Path:
1. ✅ **Start với Local Search** (free)
2. ✅ **Test tính năng**
3. ✅ **Collect user feedback**
4. 🔄 **Upgrade lên OpenAI nếu cần tốt hơn**

### Advanced:
- Implement caching (Redis)
- Add analytics
- A/B test Local vs OpenAI
- Integrate Elasticsearch

---

## Files Changed

**Backend:**
- ✅ `backend/src/controllers/aiController.js` - Updated (supports both modes)
- ✅ `backend/src/services/localSearchService.js` - NEW (local algorithm)
- ✅ `backend/src/utils/searchUtils.js` - NEW (string similarity)

**Frontend:**
- ✅ `lib/services/ai_search_service.dart` - Unchanged (works with both)
- ✅ `lib/providers/search_provider.dart` - Unchanged
- ✅ `lib/screens/ai_search_screen.dart` - Unchanged

---

## Summary

| Mode | Cost | Setup | Quality | Status |
|------|------|-------|---------|--------|
| 🟢 Local | Free | 5min | Good | ✅ Ready |
| 🔵 OpenAI | Paid | 5min + API key | Excellent | ✅ Ready |

**Recommendation:** Start với Local, upgrade thanh OpenAI later nếu cần.
