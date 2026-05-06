IF OBJECT_ID('dbo.banks', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.banks (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    bank_name NVARCHAR(255),
    bank_code NVARCHAR(50)
  );
END
GO

IF OBJECT_ID('dbo.user_bank_accounts', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.user_bank_accounts (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    bank_id BIGINT,
    account_number NVARCHAR(50),
    account_name NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    FOREIGN KEY (bank_id) REFERENCES dbo.banks(id)
  );

  CREATE UNIQUE INDEX UX_user_bank_accounts_user_id ON dbo.user_bank_accounts(user_id);
END
GO

IF OBJECT_ID('dbo.payments', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.payments (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT,
    amount DECIMAL(12,2),
    payment_method NVARCHAR(50),
    status NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE()
  );
END
GO
