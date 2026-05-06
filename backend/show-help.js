#!/usr/bin/env node

/**
 * SecondHand Backend - Available Commands
 * 
 * Display help information for all available npm scripts
 * Run: npm run help
 */

const commands = {
  dev: {
    description: 'Start server with auto-reload (hot restart)',
    uses: 'nodemon src/index.js',
    when: 'During development',
    example: 'npm run dev',
  },
  start: {
    description: 'Start server (production mode)',
    uses: 'node src/index.js',
    when: 'Production deployment',
    example: 'npm run start',
  },
  'test:db': {
    description: 'Test database connection',
    uses: 'test_db.js',
    when: 'Verify database is working',
    example: 'npm run test:db',
  },
  'test:api': {
    description: 'Test API endpoints',
    uses: 'test_api.js',
    when: 'Verify API is responding',
    example: 'npm run test:api',
  },
  'test:ai': {
    description: 'Test AI search (local mode, free)',
    uses: 'test_local_search.js',
    when: 'Verify search functionality',
    example: 'npm run test:ai',
  },
  'seed:samples': {
    description: 'Add sample products to database',
    uses: 'scripts/seed_sample_products.js',
    when: 'Initial setup or testing',
    example: 'npm run seed:samples',
  },
  'reset:demo': {
    description: 'Reset database to demo data',
    uses: 'scripts/reset_demo_data.js',
    when: 'Clear data and start fresh',
    example: 'npm run reset:demo',
  },
  'install:deps': {
    description: 'Install or update all dependencies',
    uses: 'npm install',
    when: 'After package.json changes',
    example: 'npm run install:deps',
  },
  health: {
    description: 'Check if server is alive (curl health endpoint)',
    uses: 'curl http://localhost:8000/api/health',
    when: 'Verify server is running',
    example: 'npm run health',
  },
  setup: {
    description: 'Full setup: install deps + test db + verify',
    uses: 'npm install && npm run test:db',
    when: 'First time setup',
    example: 'npm run setup',
  },
  logs: {
    description: 'Show backend service URLs',
    uses: 'echo "Backend running..."',
    when: 'Quick reference',
    example: 'npm run logs',
  },
};

// Print header
console.log('\n╔════════════════════════════════════════════════════════╗');
console.log('║   SecondHand Backend - Available Commands             ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

// Group commands by category
const categories = {
  'Core Commands': ['dev', 'start'],
  'Testing': ['test:db', 'test:api', 'test:ai'],
  'Database': ['seed:samples', 'reset:demo'],
  'Utilities': ['install:deps', 'health', 'setup', 'logs'],
};

// Print commands
Object.entries(categories).forEach(([category, cmds]) => {
  console.log(`\n📋 ${category}`);
  console.log('─'.repeat(60));

  cmds.forEach(cmd => {
    const info = commands[cmd];
    console.log(`\n  ${cmd}`);
    console.log(`    ${info.description}`);
    if (info.uses) {
      console.log(`    Uses: ${info.uses}`);
    }
    if (info.when) {
      console.log(`    When: ${info.when}`);
    }
    console.log(`    Usage: ${info.example}`);
  });
});

// Quick reference
console.log('\n\n╔════════════════════════════════════════════════════════╗');
console.log('║   Quick Reference                                      ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('🚀 First Time Setup:');
console.log('   npm run setup\n');

console.log('💻 Development Mode:');
console.log('   npm run dev\n');

console.log('🧪 Testing Before Commit:');
console.log('   npm run test:db');
console.log('   npm run test:api');
console.log('   npm run test:ai\n');

console.log('🌐 Health Check:');
console.log('   npm run health');
console.log('   curl http://localhost:8000/api/health\n');

console.log('📊 Database Management:');
console.log('   npm run seed:samples    (Add test data)');
console.log('   npm run reset:demo      (Clear data)\n');

// Service info
console.log('\n╔════════════════════════════════════════════════════════╗');
console.log('║   Service URLs                                         ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('  🔧 Backend API:     http://localhost:8000');
console.log('  📱 Frontend:        http://localhost:7856');
console.log('  🗄️  Database:       (configured in .env)\n');

console.log('🔌 API Endpoints:');
console.log('  GET    /api/health                 - Health check');
console.log('  GET    /api/products               - List products');
console.log('  POST   /api/ai/search-suggestions  - AI search');
console.log('  POST   /api/ai/smart-search        - Smart search\n');

// Tips
console.log('╔════════════════════════════════════════════════════════╗');
console.log('║   💡 Tips                                              ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('  ✓ Run npm run setup once after cloning');
console.log('  ✓ During development, use npm run dev for auto-reload');
console.log('  ✓ Always run tests before committing');
console.log('  ✓ Use npm run health to quickly verify server');
console.log('  ✓ Combine commands: npm run test:db && npm run dev\n');

// Environment info
console.log('📝 Configuration:');
console.log('  Make sure .env file exists in backend/ folder');
console.log('  Required variables: DB_SERVER, DB_USER, DB_PASSWORD\n');
