#!/bin/bash
# Setup guide for AI Search Feature
# Cho phép switch giữa OpenAI và Free Local Search

echo "================================"
echo "SecondHand App - AI Search Setup"
echo "================================"
echo ""

# Check current environment
echo "🔍 Checking environment..."
echo ""

if [ -f ".env" ]; then
    if grep -q "OPENAI_API_KEY=" .env; then
        OPENAI_KEY=$(grep "OPENAI_API_KEY=" .env | cut -d'=' -f2)
        if [ -z "$OPENAI_KEY" ] || [ "$OPENAI_KEY" = "sk-" ]; then
            echo "❌ OPENAI_API_KEY not configured (empty or default)"
            USING_MODE="LOCAL"
        else
            echo "✅ OPENAI_API_KEY configured"
            USING_MODE="OPENAI"
        fi
    else
        echo "❌ OPENAI_API_KEY not found in .env"
        USING_MODE="LOCAL"
    fi
else
    echo "⚠️  .env file not found"
    USING_MODE="LOCAL"
fi

echo ""
echo "📊 Current Mode: $USING_MODE"
echo ""

echo "================================"
echo "Available Modes:"
echo "================================"
echo ""
echo "1️⃣  LOCAL SEARCH (FREE)"
echo "   - No API key needed"
echo "   - Free, instant, runs locally"
echo "   - Uses smart algorithms"
echo "   - Perfect for development/testing"
echo ""

echo "2️⃣  OPENAI SEARCH (PAID)"
echo "   - Needs OpenAI API key"
echo "   - Better suggestions"
echo "   - Small cost ($0.001-0.002 per search)"
echo "   - Better for production"
echo ""

# Instructions
echo "================================"
echo "Setup Instructions:"
echo "================================"
echo ""

echo "To use LOCAL SEARCH (Recommended for starting):"
echo "  1. Don't set OPENAI_API_KEY in .env"
echo "  2. Just run: npm run dev"
echo "  3. System will auto-use local search"
echo ""

echo "To use OPENAI SEARCH:"
echo "  1. Get API key from: https://platform.openai.com/api-keys"
echo "  2. Add to .env: OPENAI_API_KEY=sk-your-key"
echo "  3. Run: npm run dev"
echo "  4. System will auto-detect and use OpenAI"
echo ""

echo "================================"
echo "Testing:"
echo "================================"
echo ""

echo "Test Local Search:"
echo "  curl -X POST http://localhost:8000/api/ai/search-suggestions \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"query\": \"iphone\"}'"
echo ""

echo "Response will include 'mode' field:"
echo "  - 'local' = Using free local search"
echo "  - 'openai' = Using OpenAI API"
echo ""
