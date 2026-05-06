/**
 * String similarity utilities for local search
 * No external API needed - everything runs locally
 */

/**
 * Calculate Levenshtein distance between two strings
 * Used for fuzzy matching and typo tolerance
 */
function levenshteinDistance(str1, str2) {
  const track = Array(str2.length + 1)
    .fill(null)
    .map(() => Array(str1.length + 1).fill(0));

  for (let i = 0; i <= str1.length; i += 1) {
    track[0][i] = i;
  }
  for (let j = 0; j <= str2.length; j += 1) {
    track[j][0] = j;
  }

  for (let j = 1; j <= str2.length; j += 1) {
    for (let i = 1; i <= str1.length; i += 1) {
      const indicator = str1[i - 1] === str2[j - 1] ? 0 : 1;
      track[j][i] = Math.min(
        track[j][i - 1] + 1,
        track[j - 1][i] + 1,
        track[j - 1][i - 1] + indicator
      );
    }
  }

  return track[str2.length][str1.length];
}

/**
 * Calculate similarity score (0-1)
 * Higher is more similar
 */
function calculateSimilarity(str1, str2) {
  const maxLength = Math.max(str1.length, str2.length);
  if (maxLength === 0) return 1;

  const distance = levenshteinDistance(str1.toLowerCase(), str2.toLowerCase());
  return 1 - distance / maxLength;
}

/**
 * Calculate TF-IDF style score
 * Combines: exact match > prefix match > partial match > fuzzy match
 */
function calculateRelevanceScore(query, text) {
  const q = query.toLowerCase();
  const t = text.toLowerCase();

  // Exact match
  if (t === q) return 100;

  // Prefix match
  if (t.startsWith(q)) return 90;

  // Word prefix match
  const words = t.split(/\s+/);
  if (words.some(w => w.startsWith(q))) return 80;

  // Contains match
  if (t.includes(q)) return 70;

  // Fuzzy match
  const similarity = calculateSimilarity(q, t);
  return similarity * 60; // 0-60 points for fuzzy match
}

/**
 * Generate search suggestions from list of keywords
 */
function generateSuggestions(query, keywords, limit = 5) {
  if (!query || query.trim().length === 0) {
    return [];
  }

  const scored = keywords
    .map(keyword => ({
      keyword,
      score: calculateRelevanceScore(query, keyword),
    }))
    .filter(item => item.score > 20) // Filter low relevance
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);

  return scored.map(item => item.keyword);
}

/**
 * Extract keywords from products
 */
function extractKeywords(products) {
  const keywords = new Set();

  products.forEach(product => {
    // Add title
    if (product.title) {
      keywords.add(product.title);
      // Add title words
      product.title.split(/\s+/).forEach(word => {
        if (word.length > 3) keywords.add(word);
      });
    }

    // Add category
    if (product.category_name) {
      keywords.add(product.category_name);
    }

    // Add description words (common ones)
    if (product.description) {
      const words = product.description.split(/\s+/).slice(0, 10); // First 10 words
      words.forEach(word => {
        if (word.length > 4) keywords.add(word);
      });
    }
  });

  return Array.from(keywords);
}

/**
 * Generate AI-like explanations for search results
 * Uses templates to create natural language explanations
 */
function generateExplanation(query, resultCount, categoryName) {
  const explanations = {
    0: `Không tìm thấy sản phẩm nào khớp với "${query}". Hãy thử tìm kiếm với từ khóa khác.`,
    1: `Tìm thấy 1 sản phẩm khớp với "${query}".`,
  };

  if (explanations[resultCount]) {
    return explanations[resultCount];
  }

  if (categoryName) {
    return `Tìm thấy ${resultCount} sản phẩm ${categoryName} phù hợp với "${query}".`;
  }

  return `Tìm thấy ${resultCount} sản phẩm phù hợp với "${query}".`;
}

/**
 * Simple ranking algorithm
 * Ranks products based on:
 * - Match quality
 * - Price (newer lower priced items rank higher)
 * - Recency
 */
function rankProducts(products, query) {
  const q = query.toLowerCase();
  const now = new Date();

  return products
    .map(product => {
      let score = 0;

      // Title match (50 points)
      score += calculateRelevanceScore(q, product.title || '');

      // Description match (30 points)
      if (product.description) {
        score += calculateRelevanceScore(q, product.description) * 0.6;
      }

      // Category match (20 points)
      if (product.category_name) {
        score += calculateRelevanceScore(q, product.category_name) * 0.4;
      }

      // Recency bonus (newer is better)
      const ageInDays =
        (now - new Date(product.created_at)) / (1000 * 60 * 60 * 24);
      if (ageInDays < 7) score += 10;
      if (ageInDays < 30) score += 5;

      return {
        ...product,
        relevanceScore: score,
      };
    })
    .filter(p => p.relevanceScore > 10)
    .sort((a, b) => b.relevanceScore - a.relevanceScore);
}

module.exports = {
  levenshteinDistance,
  calculateSimilarity,
  calculateRelevanceScore,
  generateSuggestions,
  extractKeywords,
  generateExplanation,
  rankProducts,
};
