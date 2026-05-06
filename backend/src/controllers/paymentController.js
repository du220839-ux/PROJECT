const { query } = require('../config/db');

async function ensurePaymentTables() {
  await query(`
    IF OBJECT_ID('dbo.banks', 'U') IS NULL
    BEGIN
      CREATE TABLE dbo.banks (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        bank_name NVARCHAR(255),
        bank_code NVARCHAR(50)
      );
    END

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
  `);
}

async function seedBanksIfEmpty() {
  const existing = await query(`SELECT COUNT(*) AS total FROM dbo.banks`);
  if (Number(existing.recordset[0].total || 0) > 0) return;

  const banks = [
    ['Ngân hàng TMCP Ngoại thương Việt Nam', 'VCB'],
    ['Ngân hàng TMCP Công thương Việt Nam', 'CTG'],
    ['Ngân hàng TMCP Đầu tư và Phát triển Việt Nam', 'BIDV'],
    ['Ngân hàng Nông nghiệp và Phát triển Nông thôn', 'AGRIBANK'],
    ['Ngân hàng TMCP Kỹ thương Việt Nam', 'TCB'],
    ['Ngân hàng TMCP Việt Nam Thịnh Vượng', 'VPB'],
    ['Ngân hàng TMCP Quân đội', 'MBBANK'],
    ['Ngân hàng TMCP Á Châu', 'ACB'],
    ['Ngân hàng TMCP Tiên Phong', 'TPBANK'],
    ['Ngân hàng TMCP Sài Gòn Thương Tín', 'SACOMBANK']
  ];

  for (const [name, code] of banks) {
    await query(
      `INSERT INTO dbo.banks (bank_name, bank_code) VALUES (@name, @code)`,
      { name, code }
    );
  }
}

async function listBanks(req, res) {
  try {
    await ensurePaymentTables();
    await seedBanksIfEmpty();

    const result = await query(
      `SELECT id, bank_name, bank_code
       FROM dbo.banks
       ORDER BY bank_name ASC`
    );

    return res.json({ data: result.recordset });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load banks', error: error.message });
  }
}

async function getMyBankAccount(req, res) {
  try {
    await ensurePaymentTables();
    const userId = Number(req.user.id);

    const result = await query(
      `SELECT TOP 1 uba.id, uba.user_id, uba.bank_id, uba.account_number, uba.account_name, uba.created_at,
              b.bank_name, b.bank_code
       FROM dbo.user_bank_accounts uba
       INNER JOIN dbo.banks b ON b.id = uba.bank_id
       WHERE uba.user_id = @user_id`,
      { user_id: userId }
    );

    if (!result.recordset.length) {
      return res.json({ account: null });
    }

    return res.json({ account: result.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load bank account', error: error.message });
  }
}

async function linkBankAccount(req, res) {
  try {
    await ensurePaymentTables();
    await seedBanksIfEmpty();

    const userId = Number(req.user.id);
    const bankId = Number(req.body.bank_id);
    const accountNumber = String(req.body.account_number || '').trim();
    const accountName = String(req.body.account_name || '').trim();

    if (!bankId || !accountNumber || !accountName) {
      return res.status(400).json({ message: 'bank_id, account_number, account_name are required' });
    }

    const bankExists = await query(
      `SELECT TOP 1 id FROM dbo.banks WHERE id = @id`,
      { id: bankId }
    );

    if (!bankExists.recordset.length) {
      return res.status(404).json({ message: 'Bank not found' });
    }

    const existed = await query(
      `SELECT TOP 1 id FROM dbo.user_bank_accounts WHERE user_id = @user_id`,
      { user_id: userId }
    );

    if (existed.recordset.length) {
      await query(
        `UPDATE dbo.user_bank_accounts
         SET bank_id = @bank_id,
             account_number = @account_number,
             account_name = @account_name
         WHERE user_id = @user_id`,
        {
          user_id: userId,
          bank_id: bankId,
          account_number: accountNumber,
          account_name: accountName
        }
      );
    } else {
      await query(
        `INSERT INTO dbo.user_bank_accounts (user_id, bank_id, account_number, account_name)
         VALUES (@user_id, @bank_id, @account_number, @account_name)`,
        {
          user_id: userId,
          bank_id: bankId,
          account_number: accountNumber,
          account_name: accountName
        }
      );
    }

    const account = await query(
      `SELECT TOP 1 uba.id, uba.user_id, uba.bank_id, uba.account_number, uba.account_name, uba.created_at,
              b.bank_name, b.bank_code
       FROM dbo.user_bank_accounts uba
       INNER JOIN dbo.banks b ON b.id = uba.bank_id
       WHERE uba.user_id = @user_id`,
      { user_id: userId }
    );

    return res.json({ message: 'Bank account linked', account: account.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Link bank account failed', error: error.message });
  }
}

async function createPayment(req, res) {
  try {
    await ensurePaymentTables();

    const userId = Number(req.user.id);
    const productId = Number(req.body.product_id);
    const paymentMethod = String(req.body.payment_method || '').trim().toUpperCase();

    if (!productId || !paymentMethod) {
      return res.status(400).json({ message: 'product_id and payment_method are required' });
    }

    const productResult = await query(
      `SELECT TOP 1 id, user_id, title, price, [status]
       FROM dbo.products
       WHERE id = @id`,
      { id: productId }
    );

    if (!productResult.recordset.length) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const product = productResult.recordset[0];
    if (Number(product.user_id) === userId) {
      return res.status(400).json({ message: 'You cannot buy your own product' });
    }

    if (String(product.status).toLowerCase() !== 'approved') {
      return res.status(409).json({ message: 'This product is not available for purchase' });
    }

    const amount = Number(product.price);

    const sellerBankResult = await query(
      `SELECT TOP 1 uba.account_number, uba.account_name, b.bank_name, b.bank_code
       FROM dbo.user_bank_accounts uba
       INNER JOIN dbo.banks b ON b.id = uba.bank_id
       WHERE uba.user_id = @seller_id`,
      { seller_id: Number(product.user_id) }
    );

    const sellerBank = sellerBankResult.recordset[0] || null;
    if (paymentMethod === 'BANK_TRANSFER' && !sellerBank) {
      return res.status(409).json({ message: 'Người bán chưa liên kết tài khoản ngân hàng' });
    }

    const inserted = await query(
      `INSERT INTO dbo.payments (order_id, amount, payment_method, status)
       OUTPUT INSERTED.id, INSERTED.order_id, INSERTED.amount, INSERTED.payment_method, INSERTED.status, INSERTED.created_at
       VALUES (NULL, @amount, @payment_method, 'pending')`,
      {
        amount,
        payment_method: paymentMethod
      }
    );

    const payment = inserted.recordset[0];
    const paymentUrl = `https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?txnRef=${payment.id}&amount=${Math.round(amount)}`;
    const addInfo = encodeURIComponent(`DH${payment.id}-SP${product.id}`);
    const accountName = encodeURIComponent(String(sellerBank?.account_name || ''));
    const qrUrl = sellerBank
      ? `https://img.vietqr.io/image/${sellerBank.bank_code}-${sellerBank.account_number}-compact2.png?amount=${Math.round(amount)}&addInfo=${addInfo}&accountName=${accountName}`
      : null;

    return res.status(201).json({
      message: 'Payment session created',
      payment,
      payment_url: paymentUrl,
      bank_transfer: sellerBank
        ? {
            ...sellerBank,
            qr_url: qrUrl
          }
        : null,
      checkout: {
        product_id: product.id,
        seller_id: Number(product.user_id),
        buyer_id: userId,
        amount
      }
    });
  } catch (error) {
    return res.status(500).json({ message: 'Create payment failed', error: error.message });
  }
}

async function markPaymentSuccess(req, res) {
  try {
    await ensurePaymentTables();

    const userId = Number(req.user.id);
    const paymentId = Number(req.params.id);
    const productId = Number(req.body.product_id);
    const shippingAddress = String(req.body.shipping_address || '').trim();

    if (!paymentId || !productId) {
      return res.status(400).json({ message: 'payment id and product_id are required' });
    }

    const paymentResult = await query(
      `SELECT TOP 1 id, order_id, amount, payment_method, status
       FROM dbo.payments
       WHERE id = @id`,
      { id: paymentId }
    );

    if (!paymentResult.recordset.length) {
      return res.status(404).json({ message: 'Payment not found' });
    }

    const payment = paymentResult.recordset[0];
    const normalizedStatus = String(payment.status).toLowerCase();
    if (normalizedStatus === 'paid' || normalizedStatus === 'released') {
      return res.status(200).json({
        message: 'Payment already processed',
        payment: {
          ...payment,
          status: normalizedStatus
        }
      });
    }

    const productResult = await query(
      `SELECT TOP 1 id, user_id, title, [status]
       FROM dbo.products
       WHERE id = @id`,
      { id: productId }
    );

    if (!productResult.recordset.length) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const product = productResult.recordset[0];
    const sellerId = Number(product.user_id);

    if (sellerId === userId) {
      return res.status(400).json({ message: 'You cannot pay for your own product' });
    }

    if (String(product.status).toLowerCase() !== 'approved') {
      return res.status(409).json({ message: 'Product is not available' });
    }

    // Prevent double payment for the same product by the same buyer
    const existingOrder = await query(
      `SELECT TOP 1 order_id
       FROM dbo.orders
       WHERE product_id = @product_id
         AND buyer_id = @buyer_id
         AND status IN ('PENDING', 'PAID_HOLDING', 'DELIVERED', 'COMPLETED')
       ORDER BY created_at DESC`,
      {
        product_id: productId,
        buyer_id: userId
      }
    );

    if (existingOrder.recordset.length) {
      return res.status(409).json({ message: 'A transaction already exists for this product' });
    }

    // Create an order record to associate with this payment
    const orderInserted = await query(
      `INSERT INTO dbo.orders (buyer_id, seller_id, product_id, total_price, shipping_address, shipping_fee, status)
       OUTPUT INSERTED.order_id
       VALUES (@buyer_id, @seller_id, @product_id, @total_price, @shipping_address, 0, 'PAID_HOLDING')`,
      {
        buyer_id: userId,
        seller_id: sellerId,
        product_id: productId,
        total_price: Number(payment.amount) || 0,
        shipping_address: shippingAddress || null
      }
    );

    const order = orderInserted.recordset[0];

    // Create transaction record
    const txInserted = await query(
      `INSERT INTO dbo.transactions (
         order_id, user_id, product_id, buyer_id, seller_id, amount, type, payment_method, status, product_name, processed_at
       )
       OUTPUT INSERTED.transaction_id, INSERTED.order_id, INSERTED.user_id, INSERTED.product_id, INSERTED.buyer_id, INSERTED.seller_id, INSERTED.amount, INSERTED.type, INSERTED.payment_method, INSERTED.status, INSERTED.created_at
       VALUES (@order_id, @user_id, @product_id, @buyer_id, @seller_id, @amount, 'PAYMENT', @payment_method, 'PENDING', @product_name, GETDATE())`,
      {
        order_id: order.order_id,
        user_id: userId,
        product_id: productId,
        buyer_id: userId,
        seller_id: sellerId,
        amount: Number(payment.amount) || 0,
        payment_method: payment.payment_method || null,
        product_name: product.title
      }
    );

    const tx = txInserted.recordset[0];

    await query(
      `UPDATE dbo.payments
       SET [status] = 'paid',
           order_id = @order_id
       WHERE id = @id`,
      {
        id: paymentId,
        order_id: order.order_id
      }
    );

    await query(
      `INSERT INTO dbo.notifications (user_id, title, content, is_read)
       VALUES (@user_id, @title, @content, 0)`,
      {
        user_id: sellerId,
        title: 'Don mua da thanh toan',
        content: `Nguoi mua da thanh toan cho san pham "${product.title}". Vui long xac nhan giao dich.`
      }
    );

    return res.json({
      message: 'Payment success. Transaction created and waiting seller confirmation.',
      payment: {
        ...payment,
        status: 'paid',
        order_id: order.order_id
      },
      transaction: tx
    });
  } catch (error) {
    return res.status(500).json({ message: 'Mark payment success failed', error: error.message });
  }
}

module.exports = {
  listBanks,
  getMyBankAccount,
  linkBankAccount,
  createPayment,
  markPaymentSuccess,
  ensurePaymentTables,
  seedBanksIfEmpty
};
