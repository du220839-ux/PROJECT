# AI Search Feature Documentation

## Overview

This document describes the AI-powered product search feature added to the SecondHand application. The feature uses OpenAI's GPT-3.5-turbo model to provide intelligent search suggestions and smart product recommendations.

## Architecture

### Backend Architecture

```
User Input → API Request → AI Controller → OpenAI API
                              ↓
                        Database Query
                              ↓
                         Response
```

#### Components

1. **AI Controller** (`backend/src/controllers/aiController.js`)
   - `getSearchSuggestions()`: Generates search suggestions based on user input
   - `getSmartProductSearch()`: Performs smart filtered search and provides AI explanation

2. **AI Routes** (`backend/src/routes/aiRoutes.js`)
   - Exposes two POST endpoints:
     - `/api/ai/search-suggestions`
     - `/api/ai/smart-search`

### Frontend Architecture

```
User Types → SearchProvider → AI Search Service → Backend API
                ↓
           UI Updates
           (Suggestions)
```

#### Components

1. **AI Search Service** (`lib/services/ai_search_service.dart`)
   - Singleton pattern for single instance
   - Methods:
     - `getSearchSuggestions()`: Fetches AI suggestions
     - `getSmartProductSearch()`: Searches products and gets explanation

2. **Search Provider** (`lib/providers/search_provider.dart`)
   - Extends `ChangeNotifier` for state management
   - Key features:
     - Search query management
     - Suggestion fetching
     - Result pagination
     - Recent searches persistence

3. **AI Search Screen** (`lib/screens/ai_search_screen.dart`)
   - User interface for search
   - Features:
     - Live search input with suggestions
     - Product result cards
     - AI explanation display
     - Recent searches shortcuts
     - Error handling and loading states

## API Specifications

### Endpoint 1: Search Suggestions

**Request:**
```
POST /api/ai/search-suggestions
Content-Type: application/json

{
  "query": "string (required)",
  "limit": "number (optional, default: 5)",
  "price_range": {
    "min": "number (optional)",
    "max": "number (optional)"
  },
  "category_id": "number (optional)"
}
```

**Response:**
```json
{
  "suggestions": [
    "suggestion 1",
    "suggestion 2",
    "..."
  ]
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{
    "query": "iphone",
    "limit": 5,
    "category_id": 1
  }'
```

### Endpoint 2: Smart Search

**Request:**
```
POST /api/ai/smart-search
Content-Type: application/json

{
  "query": "string (required)",
  "limit": "number (optional, default: 10)",
  "page": "number (optional, default: 1)"
}
```

**Response:**
```json
{
  "products": [
    {
      "id": 123,
      "title": "iPhone 13 Pro",
      "description": "...",
      "price": 15000000,
      "category_name": "Điện thoại",
      "image_count": 3,
      "created_at": "2024-03-20T10:30:00Z"
    },
    "..."
  ],
  "explanation": "AI explanation about the search results..."
}
```

## Setup Instructions

### Prerequisites

- Node.js 14+ (Backend)
- Flutter SDK (Frontend)
- OpenAI API key

### Backend Setup

1. **Install Dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Environment Variables:**
   
   Create `.env` file in the backend directory:
   ```env
   # Database Configuration
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_SERVER=your_db_server
   DB_NAME=secondhand_db
   DB_PORT=1433
   DB_ENCRYPT=true
   DB_TRUST_CERT=true

   # API Configuration
   PORT=8000

   # OpenAI Configuration
   OPENAI_API_KEY=sk-your-openai-api-key-here
   ```

3. **Get OpenAI API Key:**
   - Go to https://platform.openai.com/api-keys
   - Create a new API key
   - Copy and paste into `.env`

4. **Start Server:**
   ```bash
   npm run dev  # Development with auto-reload
   # or
   npm start    # Production
   ```

### Frontend Setup

1. **Ensure Provider is Added:**
   - Check `lib/app.dart` has `SearchProvider` in MultiProvider
   - Check `lib/config/routes.dart` has `/search` route

2. **Run Flutter App:**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Navigate to Search:**
   - Tap search icon in home screen
   - Or navigate to `/search` route

## Usage Examples

### Example 1: Search iPhone

**User Flow:**
1. User navigates to AI Search screen
2. Types "iphone" in search box
3. AI suggests: "iphone 13", "iphone 14 pro max", "iphone 12", etc.
4. User selects "iphone 14 pro max"
5. System searches for products and shows results
6. AI explanation: "These products match your search for iphone 14 pro max..."

### Example 2: Search with Filters

**For Future Implementation - Currently Planning:**
```dart
// Future: Search with price filter
searchProvider.setPriceRangeFilter({'min': 5000000, 'max': 15000000});
await searchProvider.fetchSuggestions();
```

## State Management Flow

```
┌─────────────────────────────────────────────────┐
│         SearchProvider (ChangeNotifier)         │
├─────────────────────────────────────────────────┤
│ Properties:                                     │
│  - _searchQuery                                 │
│  - _suggestions[]                               │
│  - _searchResults[]                             │
│  - _recentSearches[]                            │
│  - _isLoadingSuggestions                        │
│  - _isLoadingResults                            │
│                                                 │
│ Methods:                                        │
│  - updateSearchQuery()                          │
│  - fetchSuggestions()                           │
│  - searchProducts()                             │
│  - clearSearch()                                │
│  - setCategoryFilter()                          │
│  - setPriceRangeFilter()                        │
│  - loadNextPage()                               │
│  - loadPreviousPage()                           │
└─────────────────────────────────────────────────┘
```

## Performance Considerations

1. **API Rate Limiting:**
   - OpenAI API has rate limits
   - Implement backoff strategy for retries
   - Monitor API usage in OpenAI dashboard

2. **Search Optimization:**
   - Suggestions fetched asynchronously
   - Results limited to 10 per page
   - Local caching of recent searches

3. **Database Queries:**
   - Uses LIKE operator for text search
   - Fetches extra results for AI ranking
   - Indexes on title, description recommended

## Error Handling

### Client-Side Errors

- Network errors: Shown to user with retry option
- Invalid queries: Helper text displayed
- API errors: Logged and user-friendly message shown

### Server-Side Errors

- Missing OPENAI_API_KEY: Returns 500 error
- OpenAI API failures: Returns 500 error
- Database errors: Returns 500 error
- Invalid input: Returns 400 error

## Security Considerations

1. **API Key Protection:**
   - Always use `.env` for keys
   - Never commit `.env` to git
   - Rotate keys periodically

2. **Input Validation:**
   - Validate search queries on both frontend and backend
   - Sanitize inputs before passing to OpenAI

3. **Rate Limiting:**
   - Implement rate limiting on backend (future enhancement)
   - Prevent abuse of AI API

## Testing

### Manual Testing Checklist

- [ ] Search suggestions appear as user types
- [ ] Suggestions update when typing stops
- [ ] Search button works
- [ ] Products display in results
- [ ] AI explanation shows
- [ ] Recent searches save
- [ ] Recent searches can be removed
- [ ] Recent searches clear all works
- [ ] Pagination works
- [ ] Load next page fetches data
- [ ] Error messages display correctly
- [ ] Connection errors handled gracefully

### Test Cases

```dart
// Test: Get search suggestions
Future<void> testGetSuggestions() async {
  final service = AISearchService();
  final suggestions = await service.getSearchSuggestions("iPhone");
  assert(suggestions.isNotEmpty);
}

// Test: Search products
Future<void> testSmartSearch() async {
  final service = AISearchService();
  final result = await service.getSmartProductSearch("iPhone");
  assert(result['products'] != null);
  assert(result['explanation'].isNotEmpty);
}
```

## Troubleshooting

### Issue: No suggestions appearing

**Solution:**
- Check OPENAI_API_KEY is set
- Check API key is valid
- Check network connectivity
- Check backend is running

### Issue: Search returns no results

**Solution:**
- Check database has products with status='approved'
- Verify search query matches product titles/descriptions
- Check price range filters aren't too restrictive

### Issue: API rate limiting

**Solution:**
- Wait a few minutes
- Check OpenAI usage in console
- Consider upgrading plan

## Future Enhancements

1. **Advanced Filters:**
   - Price range filter UI
   - Category filter UI
   - Condition filter (new/used)

2. **Personalization:**
   - Search history
   - Search preferences
   - Saved searches

3. **Performance:**
   - Full-text search indexing
   - Elasticsearch integration
   - Caching layer

4. **Features:**
   - Image search support
   - Voice search
   - Search analytics

## Dependencies

### Backend
- `openai@^4.52.0` - OpenAI API client
- `express@^4.19.2` - Web framework
- `mssql@^10.0.2` - Database driver

### Frontend
- `provider@^6.0.5` - State management
- `dio@^4.0.6` - HTTP client
- `shared_preferences@^2.0.20` - Local storage
- `go_router@^6.5.8` - Navigation

## References

- OpenAI API Docs: https://platform.openai.com/docs/api-reference
- Provider Package: https://pub.dev/packages/provider
- Go Router: https://pub.dev/packages/go_router
- Dio Package: https://pub.dev/packages/dio

## Support

For questions or issues with the AI Search feature:
1. Check this documentation
2. Review error logs
3. Check OpenAI API status
4. Contact development team

---

**Last Updated:** March 20, 2024
**Version:** 1.0.0
