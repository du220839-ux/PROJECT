-- Payment System Schema for SecondHand App
-- Created: 2026-03-15

-- 1. Update Users table to add wallet balances
ALTER TABLE users 
ADD COLUMN wallet_balance DECIMAL(15, 2) DEFAULT 0.00,
ADD COLUMN pending_balance DECIMAL(15, 2) DEFAULT 0.00;

-- 2. Create Orders table if not exists
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
        -- Trạng thái: PENDING, PAID_HOLDING, SHIPPING, DELIVERED, COMPLETED, REFUNDING, REFUNDED
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
END;

-- 3. Create Transactions table for payment tracking
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
        type NVARCHAR(20) NOT NULL, -- 'PAYMENT', 'REFUND', 'PAYOUT'
        payment_method NVARCHAR(50), -- 'BANK_TRANSFER', 'CREDIT_CARD', 'EWALLET'
        payment_reference NVARCHAR(100), -- Mã giao dịch từ cổng thanh toán
        status NVARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'SUCCESS', 'FAILED'
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
END;

-- 4. Create Payment_Holding table to track held money
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='payment_holding' AND xtype='U')
BEGIN
    CREATE TABLE payment_holding (
        holding_id INT IDENTITY(1,1) PRIMARY KEY,
        order_id INT NOT NULL UNIQUE,
        amount DECIMAL(15, 2) NOT NULL,
        buyer_id INT NOT NULL,
        seller_id INT NOT NULL,
        status NVARCHAR(20) DEFAULT 'HOLDING', -- 'HOLDING', 'RELEASED', 'REFUNDED'
        release_reason NVARCHAR(200),
        released_at DATETIME NULL,
        created_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
        FOREIGN KEY (buyer_id) REFERENCES users(id),
        FOREIGN KEY (seller_id) REFERENCES users(id)
    );
END;

-- 5. Create Disputes table for handling complaints
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='disputes' AND xtype='U')
BEGIN
    CREATE TABLE disputes (
        dispute_id INT IDENTITY(1,1) PRIMARY KEY,
        order_id INT NOT NULL UNIQUE,
        complainant_id INT NOT NULL, -- Người khiếu nại (buyer)
        respondent_id INT NOT NULL,   -- Người bị khiếu nại (seller)
        reason NVARCHAR(500) NOT NULL,
        evidence_images NVARCHAR(1000), -- JSON array of image URLs
        status NVARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'INVESTIGATING', 'RESOLVED', 'REJECTED'
        resolution NVARCHAR(500),
        admin_id INT NULL, -- Admin xử lý khiếu nại
        created_at DATETIME DEFAULT GETDATE(),
        resolved_at DATETIME NULL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
        FOREIGN KEY (complainant_id) REFERENCES users(id),
        FOREIGN KEY (respondent_id) REFERENCES users(id),
        FOREIGN KEY (admin_id) REFERENCES users(id)
    );
END;

-- 6. Create indexes for performance
CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_seller ON orders(seller_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_auto_complete ON orders(auto_completed_at);
CREATE INDEX idx_transactions_order ON transactions(order_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_payment_holding_order ON payment_holding(order_id);
CREATE INDEX idx_disputes_order ON disputes(order_id);

-- 7. Create trigger to update updated_at column
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tr_orders_update' AND xtype='TR')
BEGIN
    CREATE TRIGGER tr_orders_update
    ON orders
    AFTER UPDATE
    AS
    BEGIN
        UPDATE orders
        SET updated_at = GETDATE()
        WHERE order_id IN (SELECT order_id FROM inserted);
    END;
END;

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tr_transactions_update' AND xtype='TR')
BEGIN
    CREATE TRIGGER tr_transactions_update
    ON transactions
    AFTER UPDATE
    AS
    BEGIN
        UPDATE transactions
        SET updated_at = GETDATE()
        WHERE transaction_id IN (SELECT transaction_id FROM inserted);
    END;
END;

PRINT 'Payment system schema created successfully!';
