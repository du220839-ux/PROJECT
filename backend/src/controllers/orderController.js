const { query } = require('../config/db');

// Tạo đơn hàng mới
async function createOrder(req, res) {
  try {
    const { buyer_id, seller_id, product_id, total_price, shipping_address, shipping_fee } = req.body;
    
    const result = await query(`
      INSERT INTO orders (buyer_id, seller_id, product_id, total_price, shipping_address, shipping_fee)
      OUTPUT INSERTED.order_id, INSERTED.*
      VALUES (@buyer_id, @seller_id, @product_id, @total_price, @shipping_address, @shipping_fee)
    `, {
      buyer_id,
      seller_id,
      product_id,
      total_price,
      shipping_address,
      shipping_fee
    });

    res.json({
      success: true,
      order: result.recordset[0]
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ message: 'Failed to create order' });
  }
}

// Cập nhật trạng thái đơn hàng sau khi thanh toán
async function markAsPaid(req, res) {
  try {
    const { order_id, payment_method, payment_reference } = req.body;
    
    // Cập nhật trạng thái đơn hàng
    await query(`
      UPDATE orders 
      SET status = 'PAID_HOLDING'
      WHERE order_id = @order_id
    `, { order_id });

    // Lấy thông tin đơn hàng
    const orderResult = await query(`
      SELECT * FROM orders WHERE order_id = @order_id
    `, { order_id });

    const order = orderResult.recordset[0];

    // Ghi nhận giao dịch thanh toán
    await query(`
      INSERT INTO transactions (order_id, user_id, amount, type, payment_method, payment_reference, status)
      VALUES (@order_id, @buyer_id, @total_price, 'PAYMENT', @payment_method, @payment_reference, 'SUCCESS')
    `, {
      order_id,
      buyer_id: order.buyer_id,
      total_price: order.total_price,
      payment_method,
      payment_reference
    });

    // Tạo bản ghi giữ tiền
    await query(`
      INSERT INTO payment_holding (order_id, amount, buyer_id, seller_id, status)
      VALUES (@order_id, @total_price, @buyer_id, @seller_id, 'HOLDING')
    `, {
      order_id,
      total_price: order.total_price,
      buyer_id: order.buyer_id,
      seller_id: order.seller_id
    });

    res.json({
      success: true,
      message: 'Order paid successfully',
      status: 'PAID_HOLDING'
    });
  } catch (error) {
    console.error('Mark as paid error:', error);
    res.status(500).json({ message: 'Failed to mark order as paid' });
  }
}

// Cập nhật trạng thái giao hàng
async function markAsDelivered(req, res) {
  try {
    const { order_id } = req.body;
    
    // Cập nhật trạng thái và thời gian giao hàng
    await query(`
      UPDATE orders 
      SET status = 'DELIVERED', 
          delivery_at = GETDATE(),
          auto_completed_at = DATEADD(day, 7, GETDATE())
      WHERE order_id = @order_id
    `, { order_id });

    res.json({
      success: true,
      message: 'Order marked as delivered',
      auto_complete_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    });
  } catch (error) {
    console.error('Mark as delivered error:', error);
    res.status(500).json({ message: 'Failed to mark order as delivered' });
  }
}

// Xử lý khiếu nại
async function createDispute(req, res) {
  try {
    const { order_id, complainant_id, reason, evidence_images } = req.body;
    
    // Lấy thông tin đơn hàng
    const orderResult = await query(`
      SELECT * FROM orders WHERE order_id = @order_id
    `, { order_id });

    const order = orderResult.recordset[0];
    
    // Khóa đơn hàng
    await query(`
      UPDATE orders SET status = 'REFUNDING', is_disputed = 1 WHERE order_id = @order_id
    `, { order_id });

    // Tạo khiếu nại
    await query(`
      INSERT INTO disputes (order_id, complainant_id, respondent_id, reason, evidence_images, status)
      VALUES (@order_id, @complainant_id, @respondent_id, @reason, @evidence_images, 'PENDING')
    `, {
      order_id,
      complainant_id,
      respondent_id: order.seller_id,
      reason,
      evidence_images: JSON.stringify(evidence_images || [])
    });

    res.json({
      success: true,
      message: 'Dispute created successfully'
    });
  } catch (error) {
    console.error('Create dispute error:', error);
    res.status(500).json({ message: 'Failed to create dispute' });
  }
}

// Hoàn tiền
async function processRefund(req, res) {
  try {
    const { order_id, admin_id, resolution } = req.body;
    
    // Lấy thông tin đơn hàng và giao dịch
    const orderResult = await query(`
      SELECT o.*, t.amount, t.payment_reference 
      FROM orders o
      JOIN transactions t ON o.order_id = t.order_id AND t.type = 'PAYMENT'
      WHERE o.order_id = @order_id
    `, { order_id });

    const order = orderResult.recordset[0];

    // Cập nhật trạng thái đơn hàng
    await query(`
      UPDATE orders SET status = 'REFUNDED' WHERE order_id = @order_id
    `, { order_id });

    // Ghi nhận giao dịch hoàn tiền
    await query(`
      INSERT INTO transactions (order_id, user_id, amount, type, payment_reference, status)
      VALUES (@order_id, @buyer_id, @amount, 'REFUND', @payment_reference, 'SUCCESS')
    `, {
      order_id,
      buyer_id: order.buyer_id,
      amount: order.amount,
      payment_reference: order.payment_reference
    });

    // Cập nhật trạng thái giữ tiền
    await query(`
      UPDATE payment_holding 
      SET status = 'REFUNDED', release_reason = @resolution, released_at = GETDATE()
      WHERE order_id = @order_id
    `, { order_id, resolution });

    // Cập nhật khiếu nại
    await query(`
      UPDATE disputes 
      SET status = 'RESOLVED', resolution = @resolution, admin_id = @admin_id, resolved_at = GETDATE()
      WHERE order_id = @order_id
    `, { order_id, resolution, admin_id });

    res.json({
      success: true,
      message: 'Refund processed successfully'
    });
  } catch (error) {
    console.error('Process refund error:', error);
    res.status(500).json({ message: 'Failed to process refund' });
  }
}

// Quyết toán tiền cho seller
async function completeOrder(req, res) {
  try {
    const { order_id } = req.body;
    
    // Lấy thông tin đơn hàng
    const orderResult = await query(`
      SELECT * FROM orders WHERE order_id = @order_id
    `, { order_id });

    const order = orderResult.recordset[0];

    // Bắt đầu transaction
    const transaction = await query('BEGIN TRANSACTION');

    try {
      // 1. Cập nhật trạng thái đơn hàng
      await query(`
        UPDATE orders SET status = 'COMPLETED' WHERE order_id = @order_id
      `, { order_id });

      // 2. Cộng tiền vào ví của seller
      await query(`
        UPDATE users 
        SET wallet_balance = wallet_balance + @total_price
        WHERE user_id = @seller_id
      `, {
        total_price: order.total_price,
        seller_id: order.seller_id
      });

      // 3. Ghi log quyết toán
      await query(`
        INSERT INTO transactions (order_id, user_id, amount, type, status)
        VALUES (@order_id, @seller_id, @amount, 'PAYOUT', 'SUCCESS')
      `, {
        order_id,
        seller_id: order.seller_id,
        amount: order.total_price
      });

      // 4. Cập nhật trạng thái giữ tiền
      await query(`
        UPDATE payment_holding 
        SET status = 'RELEASED', release_reason = 'Order completed', released_at = GETDATE()
        WHERE order_id = @order_id
      `, { order_id });

      await query('COMMIT TRANSACTION');

      res.json({
        success: true,
        message: 'Order completed successfully',
        payout_amount: order.total_price
      });
    } catch (innerError) {
      await query('ROLLBACK TRANSACTION');
      throw innerError;
    }
  } catch (error) {
    console.error('Complete order error:', error);
    res.status(500).json({ message: 'Failed to complete order' });
  }
}

// Cron job để tự động hoàn tất đơn hàng sau 7 ngày
async function autoCompleteOrders() {
  try {
    const result = await query(`
      SELECT order_id, seller_id, total_price
      FROM orders 
      WHERE status = 'DELIVERED' 
        AND auto_completed_at <= GETDATE()
    `);

    for (const order of result.recordset) {
      await completeOrder({ body: { order_id: order.order_id } }, { 
        json: () => {}, 
        status: () => {} 
      });
    }

    console.log(`Auto-completed ${result.recordset.length} orders`);
  } catch (error) {
    console.error('Auto complete orders error:', error);
  }
}

// Lấy danh sách đơn hàng của user
async function getUserOrders(req, res) {
  try {
    const { user_id, status, page = 1, limit = 10 } = req.query;
    
    let whereClause = 'WHERE (buyer_id = @user_id OR seller_id = @user_id)';
    const params = { user_id };
    
    if (status) {
      whereClause += ' AND status = @status';
      params.status = status;
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const result = await query(`
      SELECT o.*, 
             p.name as product_name, 
             p.image_url as product_image,
             u1.name as buyer_name,
             u2.name as seller_name
      FROM orders o
      LEFT JOIN products p ON o.product_id = p.id
      LEFT JOIN users u1 ON o.buyer_id = u1.id
      LEFT JOIN users u2 ON o.seller_id = u2.id
      ${whereClause}
      ORDER BY o.created_at DESC
      OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY
    `, { ...params, offset, limit: parseInt(limit) });

    res.json({
      success: true,
      orders: result.recordset
    });
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({ message: 'Failed to get user orders' });
  }
}

// Thanh toán đơn hàng bằng ví
async function payWithWallet(req, res) {
  try {
    const { order_id, amount } = req.body;
    const userId = req.user.id; // Use authenticated user ID

    // Lấy thông tin đơn hàng
    const orderResult = await query(`
      SELECT * FROM orders WHERE order_id = @order_id AND buyer_id = @userId
    `, { order_id, userId });

    if (orderResult.recordset.length === 0) {
      return res.status(404).json({ message: 'Order not found' });
    }

    const order = orderResult.recordset[0];

    // Kiểm tra số dư ví
    const balanceResult = await query(`
      SELECT wallet_balance FROM users WHERE id = @userId
    `, { userId });

    const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;
    if (currentBalance < amount) {
      return res.status(400).json({ message: 'Insufficient wallet balance' });
    }

    // Kiểm tra số tiền phải khớp với đơn hàng
    if (amount !== order.total_price + (order.shipping_fee || 0)) {
      return res.status(400).json({ message: 'Amount does not match order total' });
    }

    // Trừ tiền từ ví
    await query(`
      UPDATE users 
      SET wallet_balance = wallet_balance - @amount
      WHERE id = @userId
    `, { amount, userId });

    // Cập nhật trạng thái đơn hàng
    await query(`
      UPDATE orders 
      SET status = 'PAID_HOLDING'
      WHERE order_id = @order_id
    `, { order_id });

    // Tạo payment holding record
    await query(`
      INSERT INTO payment_holding (order_id, amount, buyer_id, seller_id, status)
      VALUES (@order_id, @amount, @userId, @sellerId, 'HOLDING')
    `, { order_id, amount, userId, sellerId: order.seller_id });

    // Ghi nhận giao dịch
    await query(`
      INSERT INTO transactions (
        user_id, amount, type, status, payment_method, 
        product_name, from_user_name, to_user_name, 
        processed_at, created_at
      )
      VALUES (
        @userId, @amount, 'PAYMENT', 'SUCCESS', 'WALLET',
        'Payment for order #${order_id}', 'Buyer', 'Seller', 
        GETDATE(), GETDATE()
      )
    `, { userId, amount, order_id });

    res.json({
      success: true,
      message: 'Payment successful',
      order_id: order_id,
      amount: amount,
      new_balance: currentBalance - amount
    });
  } catch (error) {
    console.error('Pay with wallet error:', error);
    res.status(500).json({ message: 'Failed to process payment' });
  }
}

// Tạo đơn hàng và thanh toán bằng ví trong 1 bước
async function createOrderAndPayWithWallet(req, res) {
  try {
    const { product_id, total_price, shipping_address, shipping_fee } = req.body;
    const userId = req.user.id; // Use authenticated user ID

    const parsedTotalPrice = Number(total_price);
    const parsedShippingFee = Number(shipping_fee || 0);
    if (!Number.isFinite(parsedTotalPrice) || !Number.isFinite(parsedShippingFee)) {
      return res.status(400).json({ message: 'Invalid price or shipping fee' });
    }

    // Lấy thông tin sản phẩm
    const productResult = await query(`
      SELECT * FROM products WHERE id = @product_id
    `, { product_id });

    if (productResult.recordset.length === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const product = productResult.recordset[0];
    const totalAmount = parsedTotalPrice + parsedShippingFee;

    // Kiểm tra số dư ví
    const balanceResult = await query(`
      SELECT wallet_balance FROM users WHERE id = @userId
    `, { userId });

    const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;
    if (currentBalance < totalAmount) {
      return res.status(400).json({ message: 'Insufficient wallet balance' });
    }

    // Tạo đơn hàng
    const orderResult = await query(`
      INSERT INTO orders (buyer_id, seller_id, product_id, total_price, shipping_address, shipping_fee, status)
      OUTPUT INSERTED.*
      VALUES (@userId, @sellerId, @product_id, @totalPrice, @shipping_address, @shippingFee, 'PAID_HOLDING')
    `, { 
      userId, 
      sellerId: product.user_id, 
      product_id, 
      totalPrice: parsedTotalPrice, 
      shipping_address, 
      shippingFee: parsedShippingFee 
    });

    const order = orderResult.recordset[0];

    // Ensure order_id is numeric (mssql parameter validation requires correct type)
    let orderId = Number(order.order_id);

    // Handle edge cases where mssql driver returns duplicated values (e.g. [6, 6])
    if (!Number.isFinite(orderId)) {
      if (Array.isArray(order.order_id)) {
        orderId = Number(order.order_id[0]);
      } else if (typeof order.order_id === 'string' && order.order_id.includes(',')) {
        orderId = Number(order.order_id.split(',')[0]);
      }
    }

    if (!Number.isFinite(orderId)) {
      throw new Error(`Invalid order_id value: ${order.order_id}`);
    }

    // Trừ tiền từ ví
    await query(`
      UPDATE users 
      SET wallet_balance = wallet_balance - @totalAmount
      WHERE id = @userId
    `, { totalAmount, userId });

    // Tạo payment holding record
    await query(`
      INSERT INTO payment_holding (order_id, amount, buyer_id, seller_id, status)
      VALUES (@orderId, @totalAmount, @userId, @sellerId, 'HOLDING')
    `, { orderId, totalAmount, userId, sellerId: product.user_id });

    // Ghi nhận giao dịch
    await query(`
      INSERT INTO transactions (
        user_id, amount, type, status, payment_method, 
        product_name, from_user_name, to_user_name, 
        processed_at, created_at
      )
      VALUES (
        @userId, @totalAmount, 'PAYMENT', 'SUCCESS', 'WALLET',
        @productName, 'Buyer', 'Seller', 
        GETDATE(), GETDATE()
      )
    `, {
      userId,
      totalAmount,
      productName: product.title,
    });

    res.json({
      success: true,
      message: 'Order created and paid successfully',
      order: order,
      amount: totalAmount,
      new_balance: currentBalance - totalAmount
    });
  } catch (error) {
    console.error('Create order and pay with wallet error:', {
      body: req.body,
      error: error?.message || String(error),
      stack: error?.stack
    });

    res.status(500).json({
      message: 'Failed to create order and pay',
      error: error?.message || String(error)
    });
  }
}

module.exports = {
  createOrder,
  markAsPaid,
  markAsDelivered,
  createDispute,
  processRefund,
  completeOrder,
  autoCompleteOrders,
  getUserOrders,
  payWithWallet,
  createOrderAndPayWithWallet
};
