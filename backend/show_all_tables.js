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

async function showAllTables() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    console.log('🗄️  DATABASE: SecondHandDB');
    console.log('=====================================\n');

    // Get all tables
    const tablesResult = await pool.request().query(`
      SELECT TABLE_NAME 
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_TYPE = 'BASE TABLE' 
      ORDER BY TABLE_NAME
    `);

    console.log('📋 DANH SÁCH BẢNG:');
    tablesResult.recordset.forEach((table, index) => {
      console.log(`${index + 1}. ${table.TABLE_NAME}`);
    });

    console.log('\n=====================================');
    console.log('📊 CHI TIẾT CÁC BẢNG:\n');

    // Show details for each table
    for (const table of tablesResult.recordset) {
      const tableName = table.TABLE_NAME;
      
      console.log(`📁 TABLE: ${tableName}`);
      console.log('─'.repeat(50));

      const columnsResult = await pool.request()
        .input('tableName', sql.NVarChar, tableName)
        .query(`
          SELECT 
            COLUMN_NAME,
            DATA_TYPE,
            IS_NULLABLE,
            COLUMN_DEFAULT,
            CHARACTER_MAXIMUM_LENGTH
          FROM INFORMATION_SCHEMA.COLUMNS 
          WHERE TABLE_NAME = @tableName
          ORDER BY ORDINAL_POSITION
        `);

      columnsResult.recordset.forEach(col => {
        const nullable = col.IS_NULLABLE === 'YES' ? 'NULL' : 'NOT NULL';
        const length = col.CHARACTER_MAXIMUM_LENGTH 
          ? `(${col.CHARACTER_MAXIMUM_LENGTH})` 
          : '';
        const defaultVal = col.COLUMN_DEFAULT 
          ? ` DEFAULT ${col.COLUMN_DEFAULT}` 
          : '';
        
        console.log(`  • ${col.COLUMN_NAME}: ${col.DATA_TYPE}${length} ${nullable}${defaultVal}`);
      });

      // Get row count
      const countResult = await pool.request().query(`
        SELECT COUNT(*) as row_count FROM ${tableName}
      `);
      const rowCount = countResult.recordset[0].row_count;
      console.log(`  📈 Rows: ${rowCount}`);
      console.log('');
    }

    console.log('=====================================');
    console.log('✅ Hoàn thành!');
    
    await pool.close();
  } catch (err) {
    console.error('❌ Lỗi:', err.message);
  }
}

showAllTables();
