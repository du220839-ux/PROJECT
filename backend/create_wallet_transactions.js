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

async function createWalletTransactions() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Rename existing transactions table to product_transactions
    try {
      await pool.request().query(`
        IF EXISTS (SELECT * FROM sysobjects WHERE name='transactions' AND xtype='U')
        BEGIN
          EXEC sp_rename 'transactions', 'product_transactions'
          PRINT 'Renamed transactions to product_transactions'
        END
      `);
    } catch (err) {
      console.log('⚠️  Rename error:', err.message);
    }

    // Create new transactions table for wallet
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='transactions' AND xtype='U')
      BEGIN
        CREATE TABLE transactions (
          transaction_id INT IDENTITY(1,1) PRIMARY KEY,
          order_id INT NULL,
          user_id INT NOT NULL,
          amount DECIMAL(15, 2) NOT NULL,
          type NVARCHAR(50) NOT NULL DEFAULT 'PAYMENT',
          status NVARCHAR(20) NOT NULL DEFAULT 'PENDING',
          payment_method NVARCHAR(50) NULL,
          payment_reference NVARCHAR(100) NULL,
          product_name NVARCHAR(200) NULL,
          from_user_name NVARCHAR(100) NULL,
          to_user_name NVARCHAR(100) NULL,
          admin_id INT NULL,
          processed_at DATETIME NULL,
          rejection_reason NVARCHAR(500) NULL,
          created_at DATETIME DEFAULT GETDATE(),
          FOREIGN KEY (user_id) REFERENCES users(id),
          FOREIGN KEY (order_id) REFERENCES orders(order_id),
          FOREIGN KEY (admin_id) REFERENCES users(id)
        );
        
        CREATE INDEX idx_transactions_user ON transactions(user_id);
        CREATE INDEX idx_transactions_type ON transactions(type);
        CREATE INDEX idx_transactions_status ON transactions(status);
        CREATE INDEX idx_transactions_created ON transactions(created_at);
        
        PRINT 'Created wallet transactions table'
      END
    `);

    console.log('✅ Created wallet transactions table');
    console.log('🎉 Wallet transactions setup completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Setup failed:', err.message);
  }
}

createWalletTransactions();
