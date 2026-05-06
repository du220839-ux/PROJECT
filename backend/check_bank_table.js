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

async function checkBankTable() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    const result = await pool.request().query(`
      SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'user_bank_accounts'
      ORDER BY ORDINAL_POSITION
    `);

    console.log('📋 User bank accounts table columns:');
    if (result.recordset.length === 0) {
      console.log('❌ Table not found - need to create it');
    } else {
      result.recordset.forEach(col => {
        console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} (${col.IS_NULLABLE})`);
      });
      console.log('✅ Table exists!');
    }
    
    await pool.close();
  } catch (err) {
    console.error('❌ Check failed:', err.message);
  }
}

checkBankTable();
