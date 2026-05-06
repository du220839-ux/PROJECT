let OpenAI = null;
try {
  ({ OpenAI } = require('openai'));
} catch (e) {
  console.warn('OpenAI module not installed. Using local search only. Install with: npm install openai');
}

const { query } = require('../config/db');
const {
  getLocalSearchSuggestions,
  getLocalSmartSearch,
} = require('../services/localSearchService');

// Check if OpenAI API is available
const useOpenAI = OpenAI && process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY.trim().length > 0;
let openai = null;

if (useOpenAI) {
  openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
  });
}

/**
 * AI-powered product search suggestions
 * Falls back to local search if OpenAI is not available
 * POST /api/ai/search-suggestions
 * Body: { query: string, limit?: number, price_range?: { min, max }, category_id?: number }
 * Returns: { suggestions: string[], mode: 'openai' | 'local' }
 */
async function getSearchSuggestions(req, res) {
  try {
    const { query: searchQuery, limit = 5, price_range, category_id } = req.body;

    if (!searchQuery || searchQuery.trim().length === 0) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    // Use OpenAI if available
    if (useOpenAI && openai) {
      console.log('Using OpenAI for search suggestions');
      return await getSearchSuggestionsOpenAI(
        searchQuery,
        limit,
        price_range,
        category_id,
        res
      );
    }

    // Fall back to local search
    console.log('Using local search for suggestions (OpenAI not available)');
    return await getSearchSuggestionsLocal(
      searchQuery,
      limit,
      price_range,
      category_id,
      res
    );
  } catch (error) {
    console.error('Search suggestions error:', error);
    return res.status(500).json({
      message: 'Failed to generate search suggestions',
      error: error.message,
    });
  }
}

/**
 * OpenAI-based search suggestions
 */
async function getSearchSuggestionsOpenAI(
  searchQuery,
  limit,
  priceRange,
  categoryId,
  res
) {
  try {
    // Get category info if provided
    let categoryContext = '';
    if (categoryId) {
      const categoryResult = await query(
        'SELECT name FROM dbo.categories WHERE id = @id',
        { id: categoryId }
      );
      if (categoryResult.recordset.length > 0) {
        categoryContext = ` trong danh mục ${categoryResult.recordset[0].name}`;
      }
    }

    // Build context for AI
    const priceContext = priceRange
      ? ` trong khoảng giá ${priceRange.min} - ${priceRange.max} VNĐ`
      : '';

    const prompt = `Bạn là một trợ lý tìm kiếm sản phẩm thông minh trên một ứng dụng mua bán hàng cũ. 
Người dùng đang tìm kiếm: "${searchQuery}"${categoryContext}${priceContext}

Hãy tạo ${limit} gợi ý tìm kiếm phù hợp và hữu ích. Các gợi ý nên:
1. Liên quan đến search query của người dùng
2. Thực tế và phố biến trên ứng dụng mua bán hàng cũ
3. Cụ thể hơn search query gốc
4. Tính toán cả typo hoặc từ gần giống

Trả lại dưới dạng JSON array: ["gợi ý 1", "gợi ý 2", ...]
Chỉ trả lại JSON array, không cần giải thích thêm.`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.7,
      max_tokens: 500,
    });

    const assistantMessage = completion.choices[0].message.content;

    // Parse JSON response
    let suggestions = [];
    try {
      suggestions = JSON.parse(assistantMessage);
      if (!Array.isArray(suggestions)) {
        suggestions = [assistantMessage];
      }
    } catch (e) {
      suggestions = [assistantMessage];
    }

    return res.json({
      suggestions: suggestions.slice(0, limit),
      mode: 'openai',
    });
  } catch (error) {
    console.error('OpenAI search suggestions error:', error);
    // Fall back to local search on error
    return getSearchSuggestionsLocal(searchQuery, limit, priceRange, categoryId, res);
  }
}

/**
 * Local search suggestions (free alternative)
 */
async function getSearchSuggestionsLocal(
  searchQuery,
  limit,
  priceRange,
  categoryId,
  res
) {
  try {
    const suggestions = await getLocalSearchSuggestions(searchQuery, {
      limit,
      categoryId,
      priceRange,
    });

    return res.json({
      suggestions,
      mode: 'local',
    });
  } catch (error) {
    console.error('Local search suggestions error:', error);
    return res.status(500).json({
      message: 'Failed to generate search suggestions',
      error: error.message,
    });
  }
}

/**
 * AI-powered product recommendations based on search
 * Falls back to local search if OpenAI is not available
 * POST /api/ai/smart-search
 * Body: { query: string, limit?: number, page?: number }
 * Returns: { products: [], explanation: string, mode: 'openai' | 'local' }
 */
async function getSmartProductSearch(req, res) {
  try {
    const { query: searchQuery, limit = 10, page = 1 } = req.body;

    if (!searchQuery || searchQuery.trim().length === 0) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    // Use OpenAI if available
    if (useOpenAI && openai) {
      console.log('Using OpenAI for smart search');
      return await getSmartProductSearchOpenAI(searchQuery, limit, page, res);
    }

    // Fall back to local search
    console.log('Using local search for smart search (OpenAI not available)');
    return await getSmartProductSearchLocal(searchQuery, limit, page, res);
  } catch (error) {
    console.error('Smart search error:', error);
    return res.status(500).json({
      message: 'Failed to perform smart search',
      error: error.message,
    });
  }
}

/**
 * OpenAI-based smart product search
 */
async function getSmartProductSearchOpenAI(searchQuery, limit, page, res) {
  try {
    const offset = (page - 1) * limit;

    // First, get products matching the search
    const productsResult = await query(
      `SELECT 
          p.id,
          p.user_id,
          p.category_id,
          p.title,
          p.[description],
          p.price,
          p.[status],
          p.created_at,
          c.name AS category_name,
          (SELECT COUNT(*) FROM dbo.product_images WHERE product_id = p.id) as image_count
       FROM dbo.products p
       LEFT JOIN dbo.categories c ON c.id = p.category_id
       WHERE p.[status] = 'approved'
         AND (p.title LIKE @query OR p.[description] LIKE @query OR c.name LIKE @query)
       ORDER BY p.created_at DESC
       OFFSET @offset ROWS FETCH NEXT @fetchLimit ROWS ONLY`,
      {
        query: `%${searchQuery}%`,
        fetchLimit: limit * 3,
        offset: offset,
      }
    );

    const products = productsResult.recordset || [];

    // Use AI to rank and explain the results
    if (products.length === 0) {
      return res.json({
        products: [],
        explanation: 'Không tìm thấy sản phẩm phù hợp với tìm kiếm của bạn.',
        mode: 'openai',
      });
    }

    const productsSummary = products
      .slice(0, 10)
      .map(p => `- ${p.title} (${p.category_name}, ${p.price} VNĐ)`)
      .join('\n');

    const prompt = `Bạn là một trợ lý thương mại điện tử thông minh.
Người dùng tìm kiếm: "${searchQuery}"

Dưới đây là danh sách sản phẩm tương ứng:
${productsSummary}

Hãy giải thích ngắn gọn (1-2 dòng) tại sao những sản phẩm này phù hợp với tìm kiếm của người dùng.`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.7,
      max_tokens: 200,
    });

    const explanation = completion.choices[0].message.content;

    return res.json({
      products: products.slice(0, limit).map(p => ({
        id: p.id,
        title: p.title,
        description: p.description,
        price: Number(p.price),
        category_name: p.category_name,
        image_count: p.image_count,
        created_at: p.created_at,
      })),
      explanation,
      mode: 'openai',
    });
  } catch (error) {
    console.error('OpenAI smart search error:', error);
    // Fall back to local search on error
    return getSmartProductSearchLocal(searchQuery, limit, page, res);
  }
}

/**
 * Local smart product search (free alternative)
 */
async function getSmartProductSearchLocal(searchQuery, limit, page, res) {
  try {
    const result = await getLocalSmartSearch(searchQuery, {
      limit,
      page,
    });

    return res.json({
      ...result,
      mode: 'local',
    });
  } catch (error) {
    console.error('Local smart search error:', error);
    return res.status(500).json({
      message: 'Failed to perform smart search',
      error: error.message,
    });
  }
}

module.exports = {
  getSearchSuggestions,
  getSmartProductSearch,
  useOpenAI,
};

