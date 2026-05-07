#!/bin/bash
# Quick AI Backend Health Check
# Run this from the project root: bash backend-health-check.sh

echo "🔍 AI Backend Health Check"
echo "================================"

# Check if backend is running
echo ""
echo "1️⃣ Checking if backend is running on localhost:8000..."
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ Backend is running!"
else
    echo "❌ Backend is NOT running!"
    echo "   Run: cd backend && npm run dev"
    exit 1
fi

# Test health endpoint
echo ""
echo "2️⃣ Testing health endpoint..."
HEALTH=$(curl -s http://localhost:8000/api/health)
echo "Response: $HEALTH"

# Test search suggestions endpoint
echo ""
echo "3️⃣ Testing AI search suggestions endpoint..."
SUGGESTIONS=$(curl -s -X POST http://localhost:8000/api/ai/search-suggestions \
  -H "Content-Type: application/json" \
  -d '{"query":"iphone","limit":5}')

if echo "$SUGGESTIONS" | grep -q '"suggestions"'; then
    echo "✅ Search suggestions working!"
    echo "Response: $SUGGESTIONS" | head -c 200
    echo "..."
else
    echo "❌ Search suggestions failed!"
    echo "Response: $SUGGESTIONS"
fi

# Test smart search endpoint  
echo ""
echo "4️⃣ Testing AI smart search endpoint..."
SMART=$(curl -s -X POST http://localhost:8000/api/ai/smart-search \
  -H "Content-Type: application/json" \
  -d '{"query":"laptop","limit":5,"page":1}')

if echo "$SMART" | grep -q '"products"'; then
    echo "✅ Smart search working!"
    echo "Response: $SMART" | head -c 200
    echo "..."
else
    echo "❌ Smart search failed!"
    echo "Response: $SMART"
fi

echo ""
echo "================================"
echo "✅ Health check complete!"
echo ""
echo "If all tests passed, your AI search should work!"
echo "If some failed, check:"
echo "1. Backend is running: cd backend && npm run dev"
echo "2. Database connection: check .env file"
echo "3. Terminal logs for error messages"
