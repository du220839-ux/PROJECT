const { query } = require('../config/db');
const { ensurePaymentTables } = require('./paymentController');

async function ensureTransactionsTable() {
  await ensurePaymentTables();
  await query(`
    IF OBJECT_ID('dbo.transactions', 'U') IS NULL
    BEGIN
      CREATE TABLE dbo.transactions (
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
        FOREIGN KEY (order_id) REFERENCES dbo.orders(order_id),
        FOREIGN KEY (user_id) REFERENCES dbo.users(id)
      );

      CREATE INDEX IX_transactions_order ON dbo.transactions(order_id);
      CREATE INDEX IX_transactions_user ON dbo.transactions(user_id);
      CREATE INDEX IX_transactions_status ON dbo.transactions(status);
    END
  `);

  // Ensure compatibility columns exist for older code paths
  const migrations = [
    { name: 'product_id', definition: 'INT NULL' },
    { name: 'buyer_id', definition: 'INT NULL' },
    { name: 'seller_id', definition: 'INT NULL' },
    { name: 'amount', definition: 'DECIMAL(15, 2) NULL' },
    { name: 'payment_method', definition: 'NVARCHAR(50) NULL' },
    { name: 'shipping_address', definition: 'NVARCHAR(500) NULL' },
    { name: 'confirmed_at', definition: 'DATETIME NULL' },
    { name: 'from_user_name', definition: 'NVARCHAR(255) NULL' },
    { name: 'to_user_name', definition: 'NVARCHAR(255) NULL' },
    { name: 'processed_at', definition: 'DATETIME NULL' },
  ];

  for (const col of migrations) {
    await query(`
      IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'transactions' AND COLUMN_NAME = @col
      )
      BEGIN
        ALTER TABLE dbo.transactions ADD ${col.name} ${col.definition};
      END
    `, { col: col.name });
  }
}

async function createTransaction(req, res) {
  try {
    await ensureTransactionsTable();

    const buyerId = Number(req.user?.id);
    const productId = Number(req.body.product_id);

    if (!Number.isFinite(buyerId) || buyerId <= 0) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    if (!Number.isFinite(productId) || productId <= 0) {
      return res.status(400).json({ message: 'Invalid product id' });
    }

    const productResult = await query(
      `SELECT TOP 1 id, user_id, title, [status], price
       FROM dbo.products
       WHERE id = @id`,
      { id: productId }
    );

    if (!productResult.recordset.length) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const product = productResult.recordset[0];
    const sellerId = Number(product.user_id);
    const amount = Number(product.price ?? 0);
    const paymentMethod = String(req.body.payment_method || 'WALLET').trim().toUpperCase();
    const shippingAddress = String(req.body.shipping_address || '').trim();

    if (buyerId === sellerId) {
      return res.status(400).json({ message: 'You cannot buy your own product' });
    }

    if (!Number.isFinite(amount) || amount <= 0) {
      return res.status(400).json({ message: 'Invalid transaction amount', amount: product.price });
    }

    if (String(product.status).toLowerCase() !== 'approved') {
      return res.status(409).json({ message: 'This product is not available for purchase' });
    }

    const existing = await query(
      `SELECT TOP 1 transaction_id AS id, status
       FROM dbo.transactions
       WHERE product_id = @product_id
         AND buyer_id = @buyer_id
         AND status IN ('pending', 'completed')
       ORDER BY created_at DESC`,
      { product_id: productId, buyer_id: buyerId }
    );

    if (existing.recordset.length) {
      const status = String(existing.recordset[0].status || '').toLowerCase();
      if (status === 'pending') {
        return res.status(409).json({ message: 'You already requested to buy this product' });
      }
      return res.status(409).json({ message: 'You already completed this purchase' });
    }

    // Check buyer balance for wallet payment
    if (String(paymentMethod).toLowerCase() === 'wallet') {
      const balanceResult = await query(
        `SELECT wallet_balance FROM dbo.users WHERE id = @id`,
        { id: buyerId }
      );
      const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;
      if (currentBalance < amount) {
        return res.status(400).json({ 
          message: 'Insufficient wallet balance to create this purchase request',
          requiredAmount: amount,
          currentBalance: currentBalance,
          shortfall: amount - currentBalance
        });
      }
    }

    const inserted = await query(
      `INSERT INTO dbo.transactions (user_id, product_id, buyer_id, seller_id, amount, payment_method, shipping_address, type, status)
       OUTPUT INSERTED.transaction_id AS id, INSERTED.user_id, INSERTED.product_id, INSERTED.buyer_id, INSERTED.seller_id, INSERTED.amount, INSERTED.payment_method, INSERTED.shipping_address, INSERTED.type, INSERTED.status, INSERTED.created_at, INSERTED.confirmed_at
       VALUES (@user_id, @product_id, @buyer_id, @seller_id, @amount, @payment_method, @shipping_address, @type, 'pending')`,
      {
        user_id: buyerId,
        product_id: productId,
        buyer_id: buyerId,
        seller_id: sellerId,
        amount,
        payment_method: paymentMethod,
        shipping_address: shippingAddress,
        type: 'PURCHASE',
      }
    );

    await query(
      `INSERT INTO dbo.notifications (user_id, title, content, is_read)
       VALUES (@user_id, @title, @content, 0)`,
      {
        user_id: sellerId,
        title: 'Yeu cau mua moi',
        content: `Co nguoi vua gui yeu cau mua san pham "${product.title}".`
      }
    );

    return res.status(201).json({
      message: 'Purchase request created. Waiting for seller confirmation.',
      transaction: inserted.recordset[0]
    });
  } catch (error) {
    console.error('Create transaction error:', error);
    return res.status(500).json({
      message: 'Create transaction failed',
      error: error?.message || String(error),
      stack: error?.stack,
    });
  }
}

async function getMyBuyingTransactions(req, res) {
  try {
    await ensureTransactionsTable();

    const buyerId = Number(req.user.id);
    
    // Main query - fast and simple, without complex image joins
    const result = await query(
      `SELECT
          t.transaction_id AS id,
          t.product_id,
          t.buyer_id,
          t.seller_id,
          t.status,
          t.created_at,
          t.confirmed_at,
          p.title AS product_title,
          p.price AS product_price,
          p.[status] AS product_status,
          s.name AS seller_name
       FROM dbo.transactions t
       INNER JOIN dbo.products p ON p.id = t.product_id
       INNER JOIN dbo.users s ON s.id = t.seller_id
       WHERE t.buyer_id = @buyer_id
       ORDER BY t.created_at DESC`,
      { buyer_id: buyerId }
    );

    // Attempt to add images separately - if it fails, continue without them
    try {
      // Get distinct product IDs
      const productIds = [...new Set(result.recordset.map(r => r.product_id))];
      
      if (productIds.length > 0 && productIds.length <= 100) {
        // For small batches, fetch images
        const imageMap = {};
        for (const pid of productIds) {
          const imgRes = await query(
            `SELECT TOP 1 image_url FROM dbo.product_images WHERE product_id = @pid ORDER BY id ASC`,
            { pid }
          );
          if (imgRes.recordset.length > 0) {
            imageMap[pid] = imgRes.recordset[0].image_url;
          }
        }
        
        // Add images to transactions
        result.recordset = result.recordset.map(r => ({
          ...r,
          product_image: imageMap[r.product_id] || null
        }));
      } else if (productIds.length > 100) {
        // For large batches, add null images to avoid query overload
        result.recordset = result.recordset.map(r => ({
          ...r,
          product_image: null
        }));
      } else {
        // No products
        result.recordset = result.recordset.map(r => ({
          ...r,
          product_image: null
        }));
      }
    } catch (imgErr) {
      // If image fetching fails, add null and continue
      console.warn('Image fetch failed (non-critical):', imgErr.message);
      result.recordset = result.recordset.map(r => ({
        ...r,
        product_image: null
      }));
    }

    return res.json({ data: result.recordset });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load buying transactions', error: error.message });
  }
}

async function getMySellingTransactions(req, res) {
  try {
    await ensureTransactionsTable();

    const sellerId = Number(req.user.id);
    
    // Main query - fast and simple, without complex image joins
    const result = await query(
      `SELECT
          t.transaction_id AS id,
          t.product_id,
          t.buyer_id,
          t.seller_id,
          t.status,
          t.created_at,
          t.confirmed_at,
          p.title AS product_title,
          p.price AS product_price,
          p.[status] AS product_status,
          b.name AS buyer_name
       FROM dbo.transactions t
       INNER JOIN dbo.products p ON p.id = t.product_id
       INNER JOIN dbo.users b ON b.id = t.buyer_id
       WHERE t.seller_id = @seller_id
       ORDER BY t.created_at DESC`,
      { seller_id: sellerId }
    );

    // Attempt to add images separately - if it fails, continue without them
    try {
      // Get distinct product IDs
      const productIds = [...new Set(result.recordset.map(r => r.product_id))];
      
      if (productIds.length > 0 && productIds.length <= 100) {
        // For small batches, fetch images
        const imageMap = {};
        for (const pid of productIds) {
          const imgRes = await query(
            `SELECT TOP 1 image_url FROM dbo.product_images WHERE product_id = @pid ORDER BY id ASC`,
            { pid }
          );
          if (imgRes.recordset.length > 0) {
            imageMap[pid] = imgRes.recordset[0].image_url;
          }
        }
        
        // Add images to transactions
        result.recordset = result.recordset.map(r => ({
          ...r,
          product_image: imageMap[r.product_id] || null
        }));
      } else if (productIds.length > 100) {
        // For large batches, add null images to avoid query overload
        result.recordset = result.recordset.map(r => ({
          ...r,
          product_image: null
        }));
      } else {
        // No products
        result.recordset = result.recordset.map(r => ({
          ...r,
          product_image: null
        }));
      }
    } catch (imgErr) {
      // If image fetching fails, add null and continue
      console.warn('Image fetch failed (non-critical):', imgErr.message);
      result.recordset = result.recordset.map(r => ({
        ...r,
        product_image: null
      }));
    }

    return res.json({ data: result.recordset });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load selling transactions', error: error.message });
  }
}

async function confirmTransaction(req, res) {
  try {
    await ensureTransactionsTable();

    const sellerId = Number(req.user.id);
    const transactionId = Number(req.params.id);

    if (!transactionId) {
      return res.status(400).json({ message: 'Invalid transaction id' });
    }

    const txResult = await query(
      `SELECT TOP 1 t.transaction_id AS id, t.order_id, t.product_id, t.buyer_id, t.seller_id, t.amount, t.payment_method, t.shipping_address, t.status, p.[status] AS product_status, p.title AS product_title
       FROM dbo.transactions t
       INNER JOIN dbo.products p ON p.id = t.product_id
       WHERE t.transaction_id = @id`,
      { id: transactionId }
    );

    if (!txResult.recordset.length) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    const tx = txResult.recordset[0];

    if (Number(tx.seller_id) !== sellerId) {
      return res.status(403).json({ message: 'You are not allowed to confirm this transaction' });
    }

    if (String(tx.status).toLowerCase() !== 'pending') {
      return res.status(409).json({ message: 'Transaction is not pending' });
    }

    if (String(tx.product_status).toLowerCase() === 'sold') {
      return res.status(409).json({ message: 'Product is already sold' });
    }

    // For wallet payment, transfer funds between buyer and seller at confirmation time.
    if (String(tx.payment_method || '').toLowerCase() === 'wallet') {
      let amount = Number(tx.amount);

      // If amount is missing/invalid in transaction record, try to use the product price
      if (!Number.isFinite(amount) || amount <= 0) {
        const priceResult = await query(
          `SELECT price FROM dbo.products WHERE id = @id`,
          { id: tx.product_id }
        );
        const price = Number(priceResult.recordset[0]?.price ?? 0);

        if (!Number.isFinite(price) || price <= 0) {
          return res.status(400).json({
            message: `Invalid transaction amount (tx.amount=${tx.amount}, product_id=${tx.product_id}, product_price=${priceResult.recordset[0]?.price})`,
          });
        }

        amount = price;
        await query(
          `UPDATE dbo.transactions SET amount = @amount WHERE transaction_id = @id`,
          { amount, id: transactionId }
        );
      }

      // Check buyer balance
      const balanceResult = await query(
        `SELECT wallet_balance FROM dbo.users WHERE id = @id`,
        { id: tx.buyer_id }
      );
      const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;
      if (currentBalance < amount) {
        return res.status(400).json({ message: 'Insufficient wallet balance' });
      }

      // Begin transaction for wallet transfer
      await query('BEGIN TRANSACTION');

      try {
        // Deduct from buyer
        await query(
          `UPDATE dbo.users SET wallet_balance = wallet_balance - @amount WHERE id = @id`,
          { amount, id: tx.buyer_id }
        );

        // Credit to seller
        await query(
          `UPDATE dbo.users SET wallet_balance = wallet_balance + @amount WHERE id = @id`,
          { amount, id: tx.seller_id }
        );

        // Mark transaction as completed
        const confirmed = await query(
          `UPDATE dbo.transactions
           SET status = 'completed',
               confirmed_at = SYSUTCDATETIME()
           OUTPUT INSERTED.transaction_id AS id, INSERTED.order_id, INSERTED.product_id, INSERTED.buyer_id, INSERTED.seller_id, INSERTED.status, INSERTED.created_at, INSERTED.confirmed_at
           WHERE transaction_id = @id AND seller_id = @seller_id AND status = 'pending'`,
          {
            id: transactionId,
            seller_id: sellerId
          }
        );

        if (!confirmed.recordset || confirmed.recordset.length === 0) {
          await query('ROLLBACK TRANSACTION');
          return res.status(409).json({ message: 'Transaction could not be confirmed. It may have already been confirmed or cancelled.' });
        }

        // Update product status
        await query(
          `UPDATE dbo.products
           SET [status] = 'sold',
               updated_at = SYSUTCDATETIME()
           WHERE id = @product_id`,
          { product_id: tx.product_id }
        );

        // Cancel other pending transactions for this product
        await query(
          `UPDATE dbo.transactions
           SET status = 'cancelled'
           WHERE product_id = @product_id
             AND transaction_id <> @id
             AND status = 'pending'`,
          {
            product_id: tx.product_id,
            id: transactionId
          }
        );

        // Update payment status if exists
        await query(
          `UPDATE dbo.payments
           SET [status] = 'released'
           WHERE order_id = @order_id
             AND [status] = 'paid'`,
          { order_id: tx.order_id }
        );

        // Notify buyer
        await query(
          `INSERT INTO dbo.notifications (user_id, title, content, is_read)
           VALUES (@user_id, @title, @content, 0)`,
          {
            user_id: tx.buyer_id,
            title: 'Yeu cau mua da duoc chap nhan',
            content: `Nguoi ban da xac nhan giao dich cho san pham "${tx.product_title}."`
          }
        );

        // Commit transaction
        await query('COMMIT TRANSACTION');

        // For debugging: return balances after transfer
        const buyerBalanceResult = await query(
          `SELECT wallet_balance FROM dbo.users WHERE id = @id`,
          { id: tx.buyer_id }
        );
        const sellerBalanceResult = await query(
          `SELECT wallet_balance FROM dbo.users WHERE id = @id`,
          { id: tx.seller_id }
        );
        const buyerBalance = buyerBalanceResult.recordset[0]?.wallet_balance ?? 0;
        const sellerBalance = sellerBalanceResult.recordset[0]?.wallet_balance ?? 0;

        return res.json({
          message: 'Transaction completed. Product marked as sold.',
          transaction: confirmed.recordset[0],
          balances: {
            buyer: buyerBalance,
            seller: sellerBalance,
          }
        });
      } catch (txError) {
        await query('ROLLBACK TRANSACTION');
        throw txError;
      }
    } else {
      // For non-wallet payments, just confirm transaction
      const confirmed = await query(
        `UPDATE dbo.transactions
         SET status = 'completed',
             confirmed_at = SYSUTCDATETIME()
         OUTPUT INSERTED.transaction_id AS id, INSERTED.order_id, INSERTED.product_id, INSERTED.buyer_id, INSERTED.seller_id, INSERTED.status, INSERTED.created_at, INSERTED.confirmed_at
         WHERE transaction_id = @id AND seller_id = @seller_id AND status = 'pending'`,
        {
          id: transactionId,
          seller_id: sellerId
        }
      );

      if (!confirmed.recordset || confirmed.recordset.length === 0) {
        return res.status(409).json({ message: 'Transaction could not be confirmed. It may have already been confirmed or cancelled.' });
      }

      await query(
        `UPDATE dbo.products
         SET [status] = 'sold',
             updated_at = SYSUTCDATETIME()
         WHERE id = @product_id`,
        { product_id: tx.product_id }
      );

      await query(
        `UPDATE dbo.transactions
         SET status = 'cancelled'
         WHERE product_id = @product_id
           AND transaction_id <> @id
           AND status = 'pending'`,
        {
          product_id: tx.product_id,
          id: transactionId
        }
      );

      await query(
        `INSERT INTO dbo.notifications (user_id, title, content, is_read)
         VALUES (@user_id, @title, @content, 0)`,
        {
          user_id: tx.buyer_id,
          title: 'Yeu cau mua da duoc chap nhan',
          content: `Nguoi ban da xac nhan giao dich cho san pham "${tx.product_title}."`
        }
      );

      return res.json({
        message: 'Transaction completed. Product marked as sold.',
        transaction: confirmed.recordset[0]
      });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Confirm transaction failed', error: error.message });
  }
}

async function rejectTransaction(req, res) {
  try {
    await ensureTransactionsTable();

    const sellerId = Number(req.user.id);
    const transactionId = Number(req.params.id);
    const { reason } = req.body;

    if (!transactionId) {
      return res.status(400).json({ message: 'Invalid transaction id' });
    }

    const txResult = await query(
      `SELECT TOP 1 t.transaction_id AS id, t.buyer_id, t.seller_id, t.status, p.title AS product_title
       FROM dbo.transactions t
       INNER JOIN dbo.products p ON p.id = t.product_id
       WHERE t.transaction_id = @id`,
      { id: transactionId }
    );

    if (!txResult.recordset.length) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    const tx = txResult.recordset[0];

    if (Number(tx.seller_id) !== sellerId) {
      return res.status(403).json({ message: 'You are not allowed to reject this transaction' });
    }

    if (String(tx.status).toLowerCase() !== 'pending') {
      return res.status(409).json({ message: 'Only pending transactions can be rejected' });
    }

    // Update transaction status to cancelled
    const rejected = await query(
      `UPDATE dbo.transactions
       SET status = 'cancelled'
       OUTPUT INSERTED.transaction_id AS id, INSERTED.status, INSERTED.product_id, INSERTED.buyer_id, INSERTED.seller_id
       WHERE transaction_id = @id AND seller_id = @seller_id AND status = 'pending'`,
      {
        id: transactionId,
        seller_id: sellerId
      }
    );

    if (!rejected.recordset || rejected.recordset.length === 0) {
      return res.status(409).json({ message: 'Transaction could not be rejected. It may have already been confirmed.' });
    }

    // Notify buyer that seller rejected the transaction
    await query(
      `INSERT INTO dbo.notifications (user_id, title, content, is_read)
       VALUES (@user_id, @title, @content, 0)`,
      {
        user_id: tx.buyer_id,
        title: 'Yeu cau mua da bi tu choi',
        content: `Người bán đã từ chối yêu cầu mua sản phẩm "${tx.product_title}".${reason ? ' Lý do: ' + reason : ''}`
      }
    );

    return res.json({
      message: 'Transaction rejected successfully. Buyer has been notified.',
      transaction: rejected.recordset[0]
    });
  } catch (error) {
    console.error('Reject transaction error:', error);
    return res.status(500).json({ message: 'Reject transaction failed', error: error.message });
  }
}

module.exports = {
  createTransaction,
  getMyBuyingTransactions,
  getMySellingTransactions,
  confirmTransaction,
  rejectTransaction
};
