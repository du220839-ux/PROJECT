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

async function fixSchema() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Fix admin_logs table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='admin_logs' AND xtype='U')
        BEGIN
          CREATE TABLE admin_logs (
            log_id INT IDENTITY(1,1) PRIMARY KEY,
            admin_id INT NOT NULL,
            user_id INT NULL,
            action NVARCHAR(50) NOT NULL,
            amount DECIMAL(15, 2) NULL,
            reason NVARCHAR(1000) NOT NULL,
            order_id INT NULL,
            dispute_id INT NULL,
            transaction_id INT NULL,
            ip_address NVARCHAR(50),
            user_agent NVARCHAR(500),
            created_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (admin_id) REFERENCES users(id),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (order_id) REFERENCES orders(order_id),
            FOREIGN KEY (dispute_id) REFERENCES disputes(dispute_id),
            FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
          );
          PRINT 'Created admin_logs table';
        END
      `);
      console.log('✅ Admin logs table fixed');
    } catch (err) {
      console.log('⚠️  Admin logs error:', err.message);
    }

    // Fix admin_roles table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='admin_roles' AND xtype='U')
        BEGIN
          CREATE TABLE admin_roles (
            role_id INT IDENTITY(1,1) PRIMARY KEY,
            role_name NVARCHAR(50) NOT NULL UNIQUE,
            permissions NVARCHAR(1000) NOT NULL,
            description NVARCHAR(500),
            created_at DATETIME DEFAULT GETDATE()
          );
          
          INSERT INTO admin_roles (role_name, permissions, description) VALUES
          ('SUPER_ADMIN', '["*"]', 'Full system access'),
          ('FINANCE_ADMIN', '["wallet", "transactions", "withdrawals"]', 'Manage wallet and transactions'),
          ('DISPUTE_ADMIN', '["disputes", "orders"]', 'Handle disputes and orders'),
          ('USER_ADMIN', '["users", "freeze"]', 'Manage user accounts');
          
          PRINT 'Created admin_roles table';
        END
      `);
      console.log('✅ Admin roles table fixed');
    } catch (err) {
      console.log('⚠️  Admin roles error:', err.message);
    }

    // Fix admin_users table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='admin_users' AND xtype='U')
        BEGIN
          CREATE TABLE admin_users (
            admin_user_id INT IDENTITY(1,1) PRIMARY KEY,
            user_id INT NOT NULL UNIQUE,
            role_id INT NOT NULL,
            is_active BIT DEFAULT 1,
            assigned_by INT NULL,
            assigned_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (role_id) REFERENCES admin_roles(role_id),
            FOREIGN KEY (assigned_by) REFERENCES users(id)
          );
          PRINT 'Created admin_users table';
        END
      `);
      console.log('✅ Admin users table fixed');
    } catch (err) {
      console.log('⚠️  Admin users error:', err.message);
    }

    // Fix frozen_users table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='frozen_users' AND xtype='U')
        BEGIN
          CREATE TABLE frozen_users (
            freeze_id INT IDENTITY(1,1) PRIMARY KEY,
            user_id INT NOT NULL,
            reason NVARCHAR(500) NOT NULL,
            admin_id INT NOT NULL,
            status NVARCHAR(20) DEFAULT 'FROZEN',
            unfreeze_reason NVARCHAR(500),
            unfreeze_admin_id INT NULL,
            unfreeze_at DATETIME NULL,
            created_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (admin_id) REFERENCES users(id),
            FOREIGN KEY (unfreeze_admin_id) REFERENCES users(id)
          );
          PRINT 'Created frozen_users table';
        END
      `);
      console.log('✅ Frozen users table fixed');
    } catch (err) {
      console.log('⚠️  Frozen users error:', err.message);
    }

    // Fix system_settings table
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='system_settings' AND xtype='U')
        BEGIN
          CREATE TABLE system_settings (
            setting_id INT IDENTITY(1,1) PRIMARY KEY,
            setting_key NVARCHAR(100) NOT NULL UNIQUE,
            setting_value NVARCHAR(1000) NOT NULL,
            setting_type NVARCHAR(20) DEFAULT 'STRING',
            description NVARCHAR(500),
            is_public BIT DEFAULT 0,
            updated_by INT NULL,
            updated_at DATETIME DEFAULT GETDATE(),
            FOREIGN KEY (updated_by) REFERENCES users(id)
          );
          
          INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
          ('min_withdrawal_amount', '50000', 'NUMBER', 'Minimum withdrawal amount', 1),
          ('max_withdrawal_amount', '5000000', 'NUMBER', 'Maximum withdrawal amount', 1),
          ('withdrawal_fee_percent', '2', 'NUMBER', 'Withdrawal fee percentage', 1),
          ('auto_complete_days', '7', 'NUMBER', 'Days to auto-complete orders', 0),
          ('maintenance_mode', 'false', 'BOOLEAN', 'System maintenance mode', 1),
          ('app_version', '1.0.0', 'STRING', 'Current app version', 1);
          
          PRINT 'Created system_settings table';
        END
      `);
      console.log('✅ System settings table fixed');
    } catch (err) {
      console.log('⚠️  System settings error:', err.message);
    }

    console.log('🎉 Schema fix completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Schema fix failed:', err.message);
  }
}

fixSchema();
