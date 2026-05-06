const sql = require('mssql');
const fs = require('fs');

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

async function runAdminSchema() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Read and execute admin schema
    const schemaSQL = fs.readFileSync('./src/database/admin_schema.sql', 'utf8');
    
    // Split by GO statements for SQL Server
    const statements = schemaSQL.split(/\\r?\\nGO\\r?\\n/);
    
    for (const statement of statements) {
      if (statement.trim()) {
        try {
          await pool.request().query(statement.trim());
          console.log('✅ Admin schema statement executed');
        } catch (err) {
          console.log('⚠️  Admin schema statement error:', err.message);
        }
      }
    }
    
    console.log('🎉 Admin schema execution completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Admin schema execution failed:', err.message);
  }
}

runAdminSchema();
