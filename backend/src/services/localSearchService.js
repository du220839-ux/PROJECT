/**
 * Local Search Service - Free alternative to OpenAI
 * Uses local algorithms for search suggestions and product ranking
 * No API calls, everything runs on your server
 */

const { query: dbQuery } = require('../config/db');
const {
  generateSuggestions,
  extractKeywords,
  generateExplanation,
  rankProducts,
  calculateRelevanceScore,
} = require('../utils/searchUtils');

/**
 * Get search suggestions from existing products
 * Analyzes database to generate relevant suggestions
 */
async function getLocalSearchSuggestions(searchQuery, options = {}) {
  try {
    const { limit = 5, categoryId = null } = options;

    // Get all approved products (with optional category filter)
    let sql = `
      SELECT DISTINCT
        p.title,
        p.category_name,
        p.[description],
        p.created_at
      FROM (
        SELECT 
          p.title,
          c.name as category_name,
          p.[description],
          p.created_at
        FROM dbo.products p
        LEFT JOIN dbo.categories c ON c.id = p.category_id
        WHERE p.[status] = 'approved'
    `;

    const params = {};

    if (categoryId) {
      sql += ` AND p.category_id = @categoryId`;
      params.categoryId = categoryId;
    }

    sql += `) AS p
      ORDER BY p.created_at DESC`;

    const result = await dbQuery(sql, params);
    const products = result.recordset || [];

    if (products.length === 0) {
      // If no products, generate generic suggestions
      return generateGenericSuggestions(searchQuery, limit);
    }

    // Extract keywords from products
    const keywords = extractKeywords(products);

    // Generate suggestions
    const suggestions = generateSuggestions(searchQuery, keywords, limit);

    return suggestions;
  } catch (error) {
    console.error('Local search suggestions error:', error);
    return [];
  }
}

/**
 * Generate generic suggestions when no products exist
 */
function generateGenericSuggestions(query, limit) {
  const q = query.toLowerCase();

  // Common categories and variations
  const categories = [
    'Điện thoại',
    'Laptop',
    'Phụ kiện',
    'Xe cộ',
    'Quần áo',
    'Nội thất',
    'Sách',
    'Game',
    'Gia dụng',
  ];

  // Create variations
  const suggestions = [];

  // Add exact query
  suggestions.push(query);

  // Add category matches
  categories.forEach(cat => {
    if (calculateRelevanceScore(q, cat) > 0.4) {
      suggestions.push(`${query} ${cat}`);
    }
  });

  // Add common extensions
  const extensions = ['cũ', 'mới', 'giá rẻ', 'chính hãng', 'thanh lý'];
  extensions.forEach(ext => {
    if (suggestions.length < limit) {
      suggestions.push(`${query} ${ext}`);
    }
  });

  return suggestions.slice(0, limit);
}

/**
 * Smart product search using local algorithms
 * Returns ranked products and explanation
 */
async function getLocalSmartSearch(searchQuery, options = {}) {
  try {
    const { limit = 10, page = 1, categoryId = null, priceRange = null } =
      options;

    const offset = (page - 1) * limit;

    // Build SQL query
    let sql = `
      SELECT
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
    `;

    const params = {};
    let paramIndex = 1;

    // Add search filter
    if (searchQuery && searchQuery.trim()) {
      sql += ` AND (
        p.title LIKE @query
        OR p.[description] LIKE @query
        OR c.name LIKE @query
      )`;
      params.query = `%${searchQuery}%`;
    }

    // Add category filter
    if (categoryId) {
      sql += ` AND p.category_id = @categoryId`;
      params.categoryId = categoryId;
    }

    // Add price range filter
    if (priceRange && priceRange.min !== undefined && priceRange.max !== undefined) {
      sql += ` AND p.price >= @minPrice AND p.price <= @maxPrice`;
      params.minPrice = priceRange.min;
      params.maxPrice = priceRange.max;
    }

    // Get more results for ranking
    sql += ` ORDER BY p.created_at DESC`;

    const result = await dbQuery(sql, params);
    let products = result.recordset || [];

    // Rank products locally
    if (searchQuery && searchQuery.trim()) {
      products = rankProducts(products, searchQuery);
    }

    // Apply pagination
    const totalProducts = products.length;
    const paginatedProducts = products.slice(offset, offset + limit);

    // Determine category for explanation
    const categoryName =
      paginatedProducts.length > 0 ? paginatedProducts[0].category_name : '';

    // Generate explanation
    const explanation = generateExplanation(
      searchQuery,
      paginatedProducts.length,
      categoryName
    );

    return {
      products: paginatedProducts.map(p => ({
        id: p.id,
        title: p.title,
        description: p.description,
        price: Number(p.price),
        category_name: p.category_name,
        image_count: p.image_count,
        created_at: p.created_at,
      })),
      explanation,
      total: totalProducts,
      page,
      limit,
      hasMore: offset + limit < totalProducts,
    };
  } catch (error) {
    console.error('Local smart search error:', error);
    return {
      products: [],
      explanation: 'Lỗi tìm kiếm. Vui lòng thử lại.',
      total: 0,
      page: 1,
      limit: options.limit || 10,
      hasMore: false,
    };
  }
}

module.exports = {
  getLocalSearchSuggestions,
  getLocalSmartSearch,
};
