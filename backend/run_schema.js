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

async function runSchema() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // 1. Update users table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'wallet_balance')
        BEGIN
          ALTER TABLE users ADD wallet_balance DECIMAL(15, 2) DEFAULT 0.00;
          ALTER TABLE users ADD pending_balance DECIMAL(15, 2) DEFAULT 0.00;
          PRINT 'Added wallet columns to users table';
        END
      `);
      console.log('✅ Users table updated');
    } catch (err) {
      console.log('⚠️  Users table error:', err.message);
    }

    // 2. Create orders table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='orders' AND xtype='U')
        BEGIN
          CREATE TABLE orders (
            order_id INT IDENTITY(1,1) PRIMARY KEY,
            buyer_id INT NOT NULL,
            seller_id INT NOT NULL,
            product_id INT NOT NULL,
            total_price DECIMAL(15, 2) NOT NULL,
            shipping_address NVARCHAR(500),
            shipping_fee DECIMAL(10, 2) DEFAULT 0.00,
            status NVARCHAR(20) DEFAULT 'PENDING',
            is_disputed BIT DEFAULT 0,
            delivery_at DATETIME NULL,
            auto_completed_at DATETIME NULL,
            created_at DATETIME DEFAULT GETDATE(),
            updated_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (buyer_id) REFERENCES users(id),
            FOREIGN KEY (seller_id) REFERENCES users(id),
            FOREIGN KEY (product_id) REFERENCES products(id)
          );
          PRINT 'Created orders table';
        END
      `);
      console.log('✅ Orders table created');
    } catch (err) {
      console.log('⚠️  Orders table error:', err.message);
    }

    // 3. Create transactions table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='transactions' AND xtype='U')
        BEGIN
          CREATE TABLE transactions (
            transaction_id INT IDENTITY(1,1) PRIMARY KEY,
            order_id INT NULL,
            user_id INT NULL,
            product_id INT NULL,
            buyer_id INT NULL,
            seller_id INT NULL,
            amount DECIMAL(15, 2) NOT NULL,
            type NVARCHAR(20) NOT NULL,
            payment_method NVARCHAR(50),
            payment_reference NVARCHAR(100),
            status NVARCHAR(20) DEFAULT 'PENDING',
            product_name NVARCHAR(500),
            from_user_name NVARCHAR(255),
            to_user_name NVARCHAR(255),
            processed_at DATETIME NULL,
            confirmed_at DATETIME NULL,
            created_at DATETIME DEFAULT GETDATE(),
            updated_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (order_id) REFERENCES orders(order_id),
            FOREIGN KEY (user_id) REFERENCES users(id)
          );
          PRINT 'Created transactions table';
        END
      `);
      console.log('✅ Transactions table created');
    } catch (err) {
      console.log('⚠️  Transactions table error:', err.message);
    }

    // 4. Create payment_holding table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='payment_holding' AND xtype='U')
        BEGIN
          CREATE TABLE payment_holding (
            holding_id INT IDENTITY(1,1) PRIMARY KEY,
            order_id INT NOT NULL UNIQUE,
            amount DECIMAL(15, 2) NOT NULL,
            buyer_id INT NOT NULL,
            seller_id INT NOT NULL,
            status NVARCHAR(20) DEFAULT 'HOLDING',
            release_reason NVARCHAR(200),
            released_at DATETIME NULL,
            created_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (order_id) REFERENCES orders(order_id),
            FOREIGN KEY (buyer_id) REFERENCES users(id),
            FOREIGN KEY (seller_id) REFERENCES users(id)
          );
          PRINT 'Created payment_holding table';
        END
      `);
      console.log('✅ Payment_holding table created');
    } catch (err) {
      console.log('⚠️  Payment_holding table error:', err.message);
    }

    // 5. Create disputes table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='disputes' AND xtype='U')
        BEGIN
          CREATE TABLE disputes (
            dispute_id INT IDENTITY(1,1) PRIMARY KEY,
            order_id INT NOT NULL UNIQUE,
            complainant_id INT NOT NULL,
            respondent_id INT NOT NULL,
            reason NVARCHAR(500) NOT NULL,
            evidence_images NVARCHAR(1000),
            status NVARCHAR(20) DEFAULT 'PENDING',
            resolution NVARCHAR(500),
            admin_id INT NULL,
            created_at DATETIME DEFAULT GETDATE(),
            resolved_at DATETIME NULL,
            FOREIGN KEY (order_id) REFERENCES orders(order_id),
            FOREIGN KEY (complainant_id) REFERENCES users(id),
            FOREIGN KEY (respondent_id) REFERENCES users(id),
            FOREIGN KEY (admin_id) REFERENCES users(id)
          );
          PRINT 'Created disputes table';
        END
      `);
      console.log('✅ Disputes table created');
    } catch (err) {
      console.log('⚠️  Disputes table error:', err.message);
    }

    // 6. Create indexes
    try {
      const indexes = [
        'CREATE INDEX idx_orders_buyer ON orders(buyer_id)',
        'CREATE INDEX idx_orders_seller ON orders(seller_id)',
        'CREATE INDEX idx_orders_status ON orders(status)',
        'CREATE INDEX idx_orders_auto_complete ON orders(auto_completed_at)',
        'CREATE INDEX idx_transactions_order ON transactions(order_id)',
        'CREATE INDEX idx_transactions_user ON transactions(user_id)',
        'CREATE INDEX idx_transactions_type ON transactions(type)',
        'CREATE INDEX idx_payment_holding_order ON payment_holding(order_id)',
        'CREATE INDEX idx_disputes_order ON disputes(order_id)'
      ];

      for (const indexSql of indexes) {
        try {
          await pool.request().query(indexSql);
          console.log('✅ Index created');
        } catch (err) {
          console.log('⚠️  Index error (may already exist):', err.message);
        }
      }
    } catch (err) {
      console.log('⚠️  Indexes error:', err.message);
    }

    console.log('🎉 Schema execution completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Schema execution failed:', err.message);
  }
}

runSchema();
