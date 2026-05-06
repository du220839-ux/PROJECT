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

async function checkMessagesTable() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Check messages table columns
    const result = await pool.request().query(`
      SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        IS_NULLABLE,
        COLUMN_DEFAULT
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'messages'
      ORDER BY ORDINAL_POSITION
    `);

    console.log('📋 Messages table columns:');
    if (result.recordset.length === 0) {
      console.log('❌ Messages table not found!');
    } else {
      result.recordset.forEach(col => {
        console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} (${col.IS_NULLABLE})${col.COLUMN_DEFAULT ? ` DEFAULT: ${col.COLUMN_DEFAULT}` : ''}`);
      });
      
      // Check if content column exists
      const hasContent = result.recordset.some(col => col.COLUMN_NAME === 'content');
      if (!hasContent) {
        console.log('⚠️  Missing content column, adding it...');
        await pool.request().query(`
          ALTER TABLE messages ADD content NVARCHAR(1000) NOT NULL DEFAULT ''
        `);
        console.log('✅ Added content column');
      }
    }

    console.log('🎉 Messages table check completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Check failed:', err.message);
  }
}

checkMessagesTable();
