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

async function fixTransactionsSchema() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Add missing columns to transactions table
    const columns = [
      { name: 'type', type: 'NVARCHAR(50)', default: "'PAYMENT'" },
      { name: 'status', type: 'NVARCHAR(20)', default: "'PENDING'" },
      { name: 'payment_method', type: 'NVARCHAR(50)', nullable: true },
      { name: 'payment_reference', type: 'NVARCHAR(100)', nullable: true },
      { name: 'admin_id', type: 'INT', nullable: true },
      { name: 'processed_at', type: 'DATETIME', nullable: true },
      { name: 'rejection_reason', type: 'NVARCHAR(500)', nullable: true }
    ];

    for (const column of columns) {
      try {
        await pool.request().query(`
          IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'transactions' AND COLUMN_NAME = '${column.name}')
          BEGIN
            ALTER TABLE transactions ADD ${column.name} ${column.type} ${column.nullable ? 'NULL' : `DEFAULT ${column.default}`}
            PRINT 'Added column ${column.name}'
          END
        `);
        console.log(`✅ Added column ${column.name}`);
      } catch (err) {
        console.log(`⚠️  Column ${column.name} error:`, err.message);
      }
    }

    // Add foreign key for admin_id
    try {
      await pool.request().query(`
        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_transactions_admin')
        BEGIN
          ALTER TABLE transactions ADD CONSTRAINT FK_transactions_admin FOREIGN KEY (admin_id) REFERENCES users(id)
          PRINT 'Added FK for admin_id'
        END
      `);
      console.log('✅ Added foreign key for admin_id');
    } catch (err) {
      console.log('⚠️  Foreign key error:', err.message);
    }

    console.log('🎉 Transactions schema fixed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Schema fix failed:', err.message);
  }
}

fixTransactionsSchema();
