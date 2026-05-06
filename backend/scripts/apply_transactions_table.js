const { query } = require('../src/config/db');

async function main() {
  const sql = `
IF OBJECT_ID('dbo.transactions', 'U') IS NULL
BEGIN
  CREATE TABLE dbo.transactions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    buyer_id INT NOT NULL,
    seller_id INT NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_transactions_status DEFAULT 'pending',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_transactions_created_at DEFAULT SYSUTCDATETIME(),
    confirmed_at DATETIME2 NULL,
    CONSTRAINT FK_transactions_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
    CONSTRAINT FK_transactions_buyer FOREIGN KEY (buyer_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_transactions_seller FOREIGN KEY (seller_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_transactions_status CHECK (status IN ('pending', 'completed', 'cancelled'))
  );

  CREATE INDEX IX_transactions_seller_status ON dbo.transactions(seller_id, status, created_at DESC);
  CREATE INDEX IX_transactions_buyer_status ON dbo.transactions(buyer_id, status, created_at DESC);
  CREATE INDEX IX_transactions_product_status ON dbo.transactions(product_id, status);
END
`;

  await query(sql);
  const result = await query("SELECT OBJECT_ID('dbo.transactions', 'U') AS table_id");
  console.log(JSON.stringify(result.recordset[0]));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
