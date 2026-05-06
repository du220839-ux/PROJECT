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

async function checkUsers() {
  try {
    const pool = await sql.connect(config);
    
    // Get all users
    const result = await pool.request()
      .query('SELECT TOP 5 * FROM users');
    
    console.log('👥 Users in database:');
    if (result.recordset.length === 0) {
      console.log('⚠️  No users found!');
    } else {
      result.recordset.forEach((user, index) => {
        console.log(`${index + 1}. ID: ${user.id}`);
        console.log(`   Email: ${user.email}`);
        console.log(`   Name: ${user.name}`);
        console.log(`   Columns: ${Object.keys(user).join(', ')}`);
        console.log('---');
      });
    }
    
    await pool.close();
  } catch (err) {
    console.error('❌ Error:', err.message);
  }
}

checkUsers();
