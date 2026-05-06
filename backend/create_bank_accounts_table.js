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

async function createBankAccountsTable() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Create user_bank_accounts table
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='user_bank_accounts' AND xtype='U')
      BEGIN
        CREATE TABLE user_bank_accounts (
          id INT IDENTITY(1,1) PRIMARY KEY,
          user_id INT NOT NULL,
          bank_name NVARCHAR(100) NOT NULL,
          account_number NVARCHAR(50) NOT NULL,
          account_holder_name NVARCHAR(200) NOT NULL,
          is_active BIT DEFAULT 1,
          created_at DATETIME DEFAULT GETDATE(),
          updated_at DATETIME DEFAULT GETDATE(),
          FOREIGN KEY (user_id) REFERENCES users(id)
        );
        
        CREATE INDEX idx_user_bank_accounts_user ON user_bank_accounts(user_id);
        CREATE INDEX idx_user_bank_accounts_number ON user_bank_accounts(account_number);
        
        PRINT 'Created user_bank_accounts table'
      END
    `);
    
    console.log('✅ Created user_bank_accounts table');
    console.log('🎉 Bank linking system setup completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Setup failed:', err.message);
  }
}

createBankAccountsTable();
