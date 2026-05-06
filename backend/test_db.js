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

async function checkTables() {
  try {
    const pool = await sql.connect(config);
    
    // Check all tables
    const tablesResult = await pool.request()
      .query("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'");
    
    console.log('📋 Tables in database:');
    tablesResult.recordset.forEach(table => {
      console.log('  -', table.TABLE_NAME);
    });
    
    // Check Users table specifically
    try {
      const usersResult = await pool.request()
        .query('SELECT COUNT(*) as count FROM Users');
      
      console.log('👥 Users table count:', usersResult.recordset[0].count);
    } catch (err) {
      console.log('⚠️  Users table does not exist:', err.message);
    }
    
    await pool.close();
  } catch (err) {
    console.error('❌ Database Check Failed:');
    console.error('Error:', err.message);
  }
}

checkTables();
