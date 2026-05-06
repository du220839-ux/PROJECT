const { query } = require('./src/config/db');

(async () => {
  try {
    const r = await query(`
      SELECT name, type_desc 
      FROM sys.indexes 
      WHERE object_id = OBJECT_ID('dbo.product_images')
    `);
    console.log('Indexes on product_images:');
    console.log(JSON.stringify(r.recordset, null, 2));
    
    // Check transaction table indexes
    const t = await query(`
      SELECT name, type_desc 
      FROM sys.indexes 
      WHERE object_id = OBJECT_ID('dbo.transactions')
    `);
    console.log('\nIndexes on transactions:');
    console.log(JSON.stringify(t.recordset, null, 2));
  } catch(e) {
    console.error('Error:', e.message);
  }
  process.exit(0);
})();
