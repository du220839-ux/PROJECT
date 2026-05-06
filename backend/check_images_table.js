const { query } = require('./src/config/db');

(async () => {
  try {
    // Check if product_images exists
    const check = await query(`
      SELECT TABLE_NAME 
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_NAME = 'product_images'
    `);
    
    if (check.recordset.length === 0) {
      console.log('❌ product_images table does NOT exist!');
    } else {
      console.log('✅ product_images table EXISTS');
      
      // Get column info
      const cols = await query(`
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'product_images'
        ORDER BY ORDINAL_POSITION
      `);
      console.log('\nColumns:');
      cols.recordset.forEach(c => {
        console.log(`  - ${c.COLUMN_NAME}: ${c.DATA_TYPE} (${c.IS_NULLABLE === 'YES' ? 'nullable' : 'not null'})`);
      });
      
      // Count records
      const count = await query('SELECT COUNT(*) as cnt FROM dbo.product_images');
      console.log(`\nTotal images: ${count.recordset[0].cnt}`);
      
      // Check indexes
      const indexes = await query(`
        SELECT name, type_desc 
        FROM sys.indexes 
        WHERE object_id = OBJECT_ID('dbo.product_images')
      `);
      console.log('\nIndexes:');
      indexes.recordset.forEach(i => {
        console.log(`  - ${i.name} (${i.type_desc})`);
      });
    }
  } catch(e) {
    console.error('Error:', e.message);
  }
  process.exit(0);
})();
