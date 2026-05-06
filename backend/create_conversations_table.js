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

async function createConversationsTable() {
  try {
    const pool = await sql.connect(config);
    console.log('✅ Connected to SQL Server');
    
    // Create conversations table
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='conversations' AND xtype='U')
      BEGIN
        CREATE TABLE conversations (
          id INT IDENTITY(1,1) PRIMARY KEY,
          product_id INT NOT NULL,
          buyer_id INT NOT NULL,
          seller_id INT NOT NULL,
          created_at DATETIME DEFAULT GETDATE(),
          updated_at DATETIME DEFAULT GETDATE(),
          FOREIGN KEY (product_id) REFERENCES products(id),
          FOREIGN KEY (buyer_id) REFERENCES users(id),
          FOREIGN KEY (seller_id) REFERENCES users(id)
        );
        
        CREATE INDEX idx_conversations_product ON conversations(product_id);
        CREATE INDEX idx_conversations_buyer ON conversations(buyer_id);
        CREATE INDEX idx_conversations_seller ON conversations(seller_id);
        CREATE INDEX idx_conversations_updated ON conversations(updated_at);
        
        PRINT 'Created conversations table'
      END
    `);
    
    // Create messages table
    await pool.request().query(`
      IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='messages' AND xtype='U')
      BEGIN
        CREATE TABLE messages (
          id INT IDENTITY(1,1) PRIMARY KEY,
          conversation_id INT NOT NULL,
          sender_id INT NOT NULL,
          content NVARCHAR(1000) NOT NULL,
          is_read BIT DEFAULT 0,
          created_at DATETIME DEFAULT GETDATE(),
          FOREIGN KEY (conversation_id) REFERENCES conversations(id),
          FOREIGN KEY (sender_id) REFERENCES users(id)
        );
        
        CREATE INDEX idx_messages_conversation ON messages(conversation_id);
        CREATE INDEX idx_messages_sender ON messages(sender_id);
        CREATE INDEX idx_messages_created ON messages(created_at);
        
        PRINT 'Created messages table'
      END
    `);
    
    console.log('✅ Created conversations and messages tables');
    console.log('🎉 Chat system setup completed!');
    await pool.close();
  } catch (err) {
    console.error('❌ Setup failed:', err.message);
  }
}

createConversationsTable();
