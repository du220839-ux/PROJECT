const sql = require('mssql');

const config = {
  user: 'sa',
  password: '123456',
  server: '127.0.0.1',
  port: 1433,
  database: 'SecondHandDB',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

async function checkFavoritesTable() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Check if favorites table exists
    const tableCheck = await pool.request().query(`
      SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'favorites'
    `);
    
    if (tableCheck.recordset.length === 0) {
      console.log('❌ Favorites table not found, creating...');
      
      await pool.request().query(`
        CREATE TABLE favorites (
          id INT IDENTITY(1,1) PRIMARY KEY,
          user_id INT NOT NULL,
          product_id INT NOT NULL,
          created_at DATETIME DEFAULT GETDATE(),
          FOREIGN KEY (user_id) REFERENCES users(id),
          FOREIGN KEY (product_id) REFERENCES products(id),
          CONSTRAINT UQ_Favorite UNIQUE (user_id, product_id)
        );
        
        CREATE INDEX idx_favorites_user ON favorites(user_id);
        CREATE INDEX idx_favorites_product ON favorites(product_id);
        
        PRINT 'Created favorites table'
      `);
      
      console.log('✅ Created favorites table');
    } else {
      console.log('✅ Favorites table exists');
      
      // Check columns
      const columns = await pool.request().query(`
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'favorites'
        ORDER BY ORDINAL_POSITION
      `);
      
      console.log('📋 Favorites table columns:');
      columns.recordset.forEach(col => {
        console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} (${col.IS_NULLABLE})`);
      });
    }
    
    console.log('🎉 Favorites table check completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Check failed:', err.message);
  }
}

checkFavoritesTable();
