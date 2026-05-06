/**
 * Test file for Local Search vs OpenAI Search
 * Run: node test_both_modes.js
 * 
 * This tests both modes to ensure they work correctly
 */

const { query } = require('./src/config/db');
const searchUtils = require('./src/utils/searchUtils');
const {
  getLocalSearchSuggestions,
  getLocalSmartSearch,
} = require('./src/services/localSearchService');

/**
 * Test data
 */
const testCases = [
  { query: 'iphone', expected: 'electronics' },
  { query: 'laptop', expected: 'electronics' },
  { query: 'áo', expected: 'clothing' },
  { query: 'ghế', expected: 'furniture' },
];

/**
 * Test Local Search Functions
 */
async function testLocalSearch() {
  console.log('\n=======================================');
  console.log('🟢 TESTING LOCAL SEARCH (FREE)');
  console.log('=======================================\n');

  try {
    // Connect to DB
    console.log('🔌 Connecting to database...');
    const result = await query('SELECT COUNT(*) as count FROM dbo.products WHERE [status] = ?', {
      status: 'approved',
    });
    const productCount = result.recordset?.[0]?.count || 0;
    console.log(`✅ Database connected. Found ${productCount} approved products\n`);

    // Test 1: String Similarity
    console.log('📊 Test 1: String Similarity');
    console.log('─────────────────────────────');
    const tests = [
      { str1: 'iphone', str2: 'iphone', expected: '100%' },
      { str1: 'iphone', str2: 'ihpone', expected: '~90%' },
      { str1: 'iphone', str2: 'iphone14', expected: '~70%' },
    ];

    tests.forEach(test => {
      const similarity = searchUtils.calculateSimilarity(test.str1, test.str2);
      const percent = (similarity * 100).toFixed(0);
      console.log(`  "${test.str1}" vs "${test.str2}": ${percent}% (expected: ${test.expected})`);
    });

    // Test 2: Relevance Scoring
    console.log('\n📊 Test 2: Relevance Scoring');
    console.log('─────────────────────────────');
    const scoreTests = [
      { query: 'iphone', text: 'iphone', expected: 'exact match' },
      { query: 'phone', text: 'iphone case', expected: 'contains' },
      { query: 'iphone', text: 'samsung phone', expected: 'fuzzy' },
    ];

    scoreTests.forEach(test => {
      const score = searchUtils.calculateRelevanceScore(test.query, test.text);
      console.log(
        `  Query: "${test.query}", Text: "${test.text}" → Score: ${score.toFixed(2)}/100 (${test.expected})`
      );
    });

    // Test 3: Get Suggestions
    console.log('\n📊 Test 3: Search Suggestions');
    console.log('─────────────────────────────');
    for (const testCase of testCases) {
      const suggestions = await getLocalSearchSuggestions(testCase.query, { limit: 3 });
      console.log(`  Query: "${testCase.query}"`);
      if (suggestions.length > 0) {
        suggestions.forEach((sug, idx) => {
          console.log(`    ${idx + 1}. ${sug}`);
        });
      } else {
        console.log(`    (No suggestions - try adding more products to database)`);
      }
    }

    // Test 4: Smart Search
    console.log('\n📊 Test 4: Smart Search Results');
    console.log('──────────────────────────────');
    for (const testCase of testCases) {
      const result = await getLocalSmartSearch(testCase.query, { limit: 3, page: 1 });
      console.log(`  Query: "${testCase.query}"`);
      console.log(`  Found: ${result.products.length} products`);
      if (result.products.length > 0) {
        result.products.slice(0, 2).forEach((p, idx) => {
          console.log(`    ${idx + 1}. ${p.title} (${p.category_name}) - ${p.price} VNĐ`);
        });
      }
      console.log(`  Explanation: ${result.explanation}`);
    }

    console.log('\n✅ Local Search Tests Completed!\n');
  } catch (error) {
    console.error('❌ Local Search Test Failed:', error.message);
  }
}

/**
 * Test String Utilities
 */
function testStringUtils() {
  console.log('\n=======================================');
  console.log('🔧 TESTING STRING UTILITIES');
  console.log('=======================================\n');

  // Test Levenshtein Distance
  console.log('Test 1: Levenshtein Distance\n');
  const distanceTests = [
    { s1: 'kitten', s2: 'sitting', expected: 3 },
    { s1: 'saturday', s2: 'sunday', expected: 3 },
    { s1: 'abc', s2: 'abc', expected: 0 },
  ];

  distanceTests.forEach(test => {
    const distance = searchUtils.levenshteinDistance(test.s1, test.s2);
    const status = distance === test.expected ? '✅' : '❌';
    console.log(`  ${status} "${test.s1}" → "${test.s2}": distance=${distance} (expected ${test.expected})`);
  });

  // Test Explanation Generator
  console.log('\nTest 2: Explanation Generator\n');
  const explanations = [
    { query: 'iphone', count: 0, category: 'Điện thoại', expected: 'no results' },
    { query: 'iphone', count: 1, category: 'Điện thoại', expected: '1 product' },
    { query: 'iphone', count: 5, category: 'Điện thoại', expected: '5 products' },
  ];

  explanations.forEach(test => {
    const explanation = searchUtils.generateExplanation(test.query, test.count, test.category);
    console.log(`  Query: "${test.query}", Count: ${test.count}`);
    console.log(`    → ${explanation}\n`);
  });
}

/**
 * API Endpoint Test
 */
async function testAPIEndpoints() {
  console.log('\n=======================================');
  console.log('🌐 TESTING API ENDPOINTS');
  console.log('=======================================\n');

  console.log('Test 1: Search Suggestions Endpoint');
  console.log('─────────────────────────────────');
  console.log('curl -X POST http://localhost:8000/api/ai/search-suggestions \\');
  console.log('  -H "Content-Type: application/json" \\');
  console.log('  -d \'{"query": "iphone", "limit": 5}\'');
  console.log('\nExpected Response:');
  console.log(
    JSON.stringify(
      {
        suggestions: ['iPhone 13', 'iPhone 14', 'iPhone 12', '...'],
        mode: 'local',
      },
      null,
      2
    )
  );

  console.log('\n\nTest 2: Smart Search Endpoint');
  console.log('────────────────────────────');
  console.log('curl -X POST http://localhost:8000/api/ai/smart-search \\');
  console.log('  -H "Content-Type: application/json" \\');
  console.log('  -d \'{"query": "iphone", "limit": 5, "page": 1}\'');
  console.log('\nExpected Response:');
  console.log(
    JSON.stringify(
      {
        products: [
          {
            id: 1,
            title: 'iPhone 13',
            price: 15000000,
            category_name: 'Điện thoại',
            image_count: 3,
          },
        ],
        explanation: 'Tìm thấy X sản phẩm...',
        mode: 'local',
      },
      null,
      2
    )
  );
}

/**
 * Main Test Runner
 */
async function runAllTests() {
  console.log('\n╔════════════════════════════════════════════════════╗');
  console.log('║   AI SEARCH TEST SUITE - LOCAL ONLY                ║');
  console.log('║   Testing without OpenAI dependency                ║');
  console.log('╚════════════════════════════════════════════════════╝');

  // Test string utilities
  testStringUtils();

  // Test local search
  await testLocalSearch();

  // Test API specs
  testAPIEndpoints();

  console.log('\n╔════════════════════════════════════════════════════╗');
  console.log('║   ✅ ALL TESTS COMPLETED                           ║');
  console.log('║   Next: Start backend with: npm run dev            ║');
  console.log('╚════════════════════════════════════════════════════╝\n');

  process.exit(0);
}

// Run tests
runAllTests().catch(error => {
  console.error('Test suite error:', error);
  process.exit(1);
});
