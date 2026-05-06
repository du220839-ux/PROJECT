const { query } = require('../src/config/db');

async function main() {
  await query(`
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
END
`);

  // Remove old purchase flow state so app starts clean.
  await query('DELETE FROM dbo.transactions');

  // Make products visible on home by reverting sold/rejected back to approved.
  await query(`
UPDATE dbo.products
SET [status] = 'approved',
    updated_at = SYSUTCDATETIME()
WHERE [status] IN ('sold', 'rejected')
`);

  // Ensure newly created pending posts are visible for demo by approving recent ones.
  await query(`
UPDATE p
SET p.[status] = 'approved',
    p.updated_at = SYSUTCDATETIME()
FROM dbo.products p
INNER JOIN (
  SELECT TOP 10 id
  FROM dbo.products
  ORDER BY created_at DESC
) recent ON recent.id = p.id
WHERE p.[status] = 'pending'
`);

  const counts = await query(`
SELECT
  SUM(CASE WHEN [status] = 'approved' THEN 1 ELSE 0 END) AS approved_count,
  SUM(CASE WHEN [status] = 'pending' THEN 1 ELSE 0 END) AS pending_count,
  SUM(CASE WHEN [status] = 'sold' THEN 1 ELSE 0 END) AS sold_count
FROM dbo.products
`);

  console.log(JSON.stringify({ message: 'reset-demo-ok', ...counts.recordset[0] }));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
