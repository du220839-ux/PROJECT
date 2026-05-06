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

async function checkUsersTable() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Check users table columns
    const result = await pool.request().query(`
      SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        IS_NULLABLE,
        COLUMN_DEFAULT
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'users'
      ORDER BY ORDINAL_POSITION
    `);

    console.log('📋 Users table columns:');
    result.recordset.forEach(col => {
      console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} (${col.IS_NULLABLE})${col.COLUMN_DEFAULT ? ` DEFAULT: ${col.COLUMN_DEFAULT}` : ''}`);
    });

    // Check if wallet_balance columns exist
    const hasWalletBalance = result.recordset.some(col => col.COLUMN_NAME === 'wallet_balance');
    const hasPendingBalance = result.recordset.some(col => col.COLUMN_NAME === 'pending_balance');

    if (!hasWalletBalance || !hasPendingBalance) {
      console.log('\n⚠️  Missing wallet columns, adding them...');
      
      if (!hasWalletBalance) {
        await pool.request().query(`
          ALTER TABLE users ADD wallet_balance DECIMAL(15, 2) DEFAULT 0
        `);
        console.log('✅ Added wallet_balance column');
      }
      
      if (!hasPendingBalance) {
        await pool.request().query(`
          ALTER TABLE users ADD pending_balance DECIMAL(15, 2) DEFAULT 0
        `);
        console.log('✅ Added pending_balance column');
      }
    }

    console.log('\n🎉 Users table check completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Check failed:', err.message);
  }
}

checkUsersTable();
