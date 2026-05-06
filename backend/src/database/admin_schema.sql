-- Admin Control System Schema
-- Created: 2026-03-15

-- 1. Create frozen_users table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='frozen_users' AND xtype='U')
BEGIN
    CREATE TABLE frozen_users (
        freeze_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        reason NVARCHAR(500) NOT NULL,
        admin_id INT NOT NULL,
        status NVARCHAR(20) DEFAULT 'FROZEN', -- 'FROZEN', 'UNFROZEN'
        unfreeze_reason NVARCHAR(500),
        unfreeze_admin_id INT NULL,
        unfreeze_at DATETIME NULL,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (admin_id) REFERENCES users(id),
        FOREIGN KEY (unfreeze_admin_id) REFERENCES users(id)
    );
    
    CREATE INDEX idx_frozen_users_user ON frozen_users(user_id);
    CREATE INDEX idx_frozen_users_status ON frozen_users(status);
    PRINT 'Created frozen_users table';
END;

-- 2. Create admin_logs table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='admin_logs' AND xtype='U')
BEGIN
    CREATE TABLE admin_logs (
        log_id INT IDENTITY(1,1) PRIMARY KEY,
        admin_id INT NOT NULL,
        user_id INT NULL,
        action NVARCHAR(50) NOT NULL, -- 'FREEZE', 'UNFREEZE', 'ADJUSTMENT', 'APPROVE_WITHDRAW', 'REJECT_WITHDRAW', 'RESOLVE_DISPUTE'
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
    
    CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_id);
    CREATE INDEX idx_admin_logs_user ON admin_logs(user_id);
    CREATE INDEX idx_admin_logs_action ON admin_logs(action);
    CREATE INDEX idx_admin_logs_created ON admin_logs(created_at);
    PRINT 'Created admin_logs table';
END;

-- 3. Update transactions table to add admin fields
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transactions' AND COLUMN_NAME = 'admin_id')
BEGIN
    ALTER TABLE transactions ADD admin_id INT NULL;
    ALTER TABLE transactions ADD processed_at DATETIME NULL;
    ALTER TABLE transactions ADD rejection_reason NVARCHAR(500) NULL;
    PRINT 'Added admin fields to transactions table';
END;

-- 4. Update disputes table to add winner field
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'disputes' AND COLUMN_NAME = 'winner')
BEGIN
    ALTER TABLE disputes ADD winner NVARCHAR(20) NULL; -- 'buyer', 'seller', 'draw'
    PRINT 'Added winner field to disputes table';
END;

-- 5. Create admin_roles table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='admin_roles' AND xtype='U')
BEGIN
    CREATE TABLE admin_roles (
        role_id INT IDENTITY(1,1) PRIMARY KEY,
        role_name NVARCHAR(50) NOT NULL UNIQUE,
        permissions NVARCHAR(1000) NOT NULL, -- JSON array of permissions
        description NVARCHAR(500),
        created_at DATETIME DEFAULT GETDATE()
    );
    
    -- Insert default admin roles
    INSERT INTO admin_roles (role_name, permissions, description) VALUES
    ('SUPER_ADMIN', '["*"]', 'Full system access'),
    ('FINANCE_ADMIN', '["wallet", "transactions", "withdrawals"]', 'Manage wallet and transactions'),
    ('DISPUTE_ADMIN', '["disputes", "orders"]', 'Handle disputes and orders'),
    ('USER_ADMIN', '["users", "freeze"]', 'Manage user accounts');
    
    PRINT 'Created admin_roles table';
END;

-- 6. Create admin_users table (link users to roles)
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
    
    CREATE INDEX idx_admin_users_user ON admin_users(user_id);
    CREATE INDEX idx_admin_users_role ON admin_users(role_id);
    PRINT 'Created admin_users table';
END;

-- 7. Create system_settings table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='system_settings' AND xtype='U')
BEGIN
    CREATE TABLE system_settings (
        setting_id INT IDENTITY(1,1) PRIMARY KEY,
        setting_key NVARCHAR(100) NOT NULL UNIQUE,
        setting_value NVARCHAR(1000) NOT NULL,
        setting_type NVARCHAR(20) DEFAULT 'STRING', -- 'STRING', 'NUMBER', 'BOOLEAN', 'JSON'
        description NVARCHAR(500),
        is_public BIT DEFAULT 0, -- Whether this setting is visible to users
        updated_by INT NULL,
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (updated_by) REFERENCES users(id)
    );
    
    -- Insert default system settings
    INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
    ('min_withdrawal_amount', '50000', 'NUMBER', 'Minimum withdrawal amount', 1),
    ('max_withdrawal_amount', '5000000', 'NUMBER', 'Maximum withdrawal amount', 1),
    ('withdrawal_fee_percent', '2', 'NUMBER', 'Withdrawal fee percentage', 1),
    ('auto_complete_days', '7', 'NUMBER', 'Days to auto-complete orders', 0),
    ('maintenance_mode', 'false', 'BOOLEAN', 'System maintenance mode', 1),
    ('app_version', '1.0.0', 'STRING', 'Current app version', 1);
    
    PRINT 'Created system_settings table';
END;

-- 8. Create triggers for admin logging
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tr_admin_log_freeze' AND xtype='TR')
BEGIN
    EXEC('
    CREATE TRIGGER tr_admin_log_freeze
    ON frozen_users
    AFTER INSERT
    AS
    BEGIN
        INSERT INTO admin_logs (admin_id, user_id, action, reason, created_at)
        VALUES (INSERTED.admin_id, INSERTED.user_id, ''FREEZE'', INSERTED.reason, GETDATE())
    END
    ');
    PRINT 'Created trigger for freeze logging';
END;

PRINT 'Admin system schema created successfully!';
