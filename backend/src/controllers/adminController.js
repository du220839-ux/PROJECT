const { query } = require('../config/db');

// Lấy dashboard admin
async function getDashboard(req, res) {
  try {
    // Thống kê tổng quan
    const statsResult = await query(`
      SELECT 
        COUNT(DISTINCT u.id) as total_users,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(CASE WHEN o.status = 'COMPLETED' THEN o.total_price ELSE 0 END) as total_revenue,
        SUM(u.wallet_balance) as total_wallet_balance,
        SUM(u.pending_balance) as total_pending_balance,
        COUNT(DISTINCT d.dispute_id) as active_disputes
      FROM users u
      LEFT JOIN orders o ON 1=1
      LEFT JOIN disputes d ON d.status IN ('PENDING', 'INVESTIGATING')
    `);

    // Đơn hàng cần xử lý
    const ordersResult = await query(`
      SELECT TOP 10 
        o.order_id,
        o.total_price,
        o.status,
        o.created_at,
        u1.name as buyer_name,
        u2.name as seller_name,
        p.name as product_name
      FROM orders o
      LEFT JOIN users u1 ON o.buyer_id = u1.id
      LEFT JOIN users u2 ON o.seller_id = u2.id
      LEFT JOIN products p ON o.product_id = p.id
      WHERE o.status IN ('DELIVERED', 'REFUNDING')
      ORDER BY o.created_at DESC
    `);

    // Tranh chấp đang xử lý
    const disputesResult = await query(`
      SELECT TOP 10 
        d.dispute_id,
        d.order_id,
        d.reason,
        d.status,
        d.created_at,
        u1.name as complainant_name,
        u2.name as respondent_name
      FROM disputes d
      LEFT JOIN users u1 ON d.complainant_id = u1.id
      LEFT JOIN users u2 ON d.respondent_id = u2.id
      WHERE d.status IN ('PENDING', 'INVESTIGATING')
      ORDER BY d.created_at DESC
    `);

    // Giao dịch gần đây
    const transactionsResult = await query(`
      SELECT TOP 10 
        t.transaction_id,
        t.amount,
        t.type,
        t.status,
        t.created_at,
        u.name as user_name,
        o.order_id
      FROM transactions t
      LEFT JOIN users u ON t.user_id = u.id
      LEFT JOIN orders o ON t.order_id = o.order_id
      ORDER BY t.created_at DESC
    `);

    res.json({
      success: true,
      stats: statsResult.recordset[0],
      recent_orders: ordersResult.recordset,
      active_disputes: disputesResult.recordset,
      recent_transactions: transactionsResult.recordset
    });
  } catch (error) {
    console.error('Get dashboard error:', error);
    res.status(500).json({ message: 'Failed to get dashboard' });
  }
}

// Đóng băng giao dịch user
async function freezeUser(req, res) {
  try {
    const { user_id, reason, admin_id } = req.body;

    // Thêm vào bảng frozen_users
    await query(`
      IF NOT EXISTS (SELECT * FROM frozen_users WHERE user_id = @user_id AND status = 'FROZEN')
      BEGIN
        INSERT INTO frozen_users (user_id, reason, admin_id, status)
        VALUES (@user_id, @reason, @admin_id, 'FROZEN')
      END
    `, { user_id, reason, admin_id });

    res.json({
      success: true,
      message: 'User frozen successfully'
    });
  } catch (error) {
    console.error('Freeze user error:', error);
    res.status(500).json({ message: 'Failed to freeze user' });
  }
}

// Mở băng giao dịch user
async function unfreezeUser(req, res) {
  try {
    const { user_id, reason, admin_id } = req.body;

    await query(`
      UPDATE frozen_users 
      SET status = 'UNFROZEN', unfreeze_reason = @reason, unfreeze_admin_id = @admin_id, unfreeze_at = GETDATE()
      WHERE user_id = @user_id AND status = 'FROZEN'
    `, { user_id, reason, admin_id });

    res.json({
      success: true,
      message: 'User unfrozen successfully'
    });
  } catch (error) {
    console.error('Unfreeze user error:', error);
    res.status(500).json({ message: 'Failed to unfreeze user' });
  }
}

// Giải quyết tranh chấp
async function resolveDispute(req, res) {
  try {
    const { dispute_id, resolution, winner, admin_id, refund_amount } = req.body;

    // Lấy thông tin tranh chấp
    const disputeResult = await query(`
      SELECT * FROM disputes WHERE dispute_id = @dispute_id
    `, { dispute_id });

    const dispute = disputeResult.recordset[0];
    if (!dispute) {
      return res.status(404).json({ message: 'Dispute not found' });
    }

    // Bắt đầu transaction
    await query('BEGIN TRANSACTION');

    try {
      // Cập nhật trạng thái tranh chấp
      await query(`
        UPDATE disputes 
        SET status = 'RESOLVED', resolution = @resolution, admin_id = @admin_id, resolved_at = GETDATE()
        WHERE dispute_id = @dispute_id
      `, { dispute_id, resolution, admin_id });

      // Lấy thông tin đơn hàng
      const orderResult = await query(`
        SELECT * FROM orders WHERE order_id = @order_id
      `, { order_id: dispute.order_id });

      const order = orderResult.recordset[0];

      if (winner === 'buyer') {
        // Hoàn tiền cho buyer
        await query(`
          UPDATE users 
          SET wallet_balance = wallet_balance + @refund_amount
          WHERE id = @buyer_id
        `, { refund_amount: refund_amount || order.total_price, buyer_id: order.buyer_id });

        // Ghi nhận giao dịch
        await query(`
          INSERT INTO transactions (user_id, order_id, amount, type, status)
          VALUES (@buyer_id, @order_id, @refund_amount, 'REFUND', 'SUCCESS')
        `, { buyer_id: order.buyer_id, order_id: dispute.order_id, refund_amount: refund_amount || order.total_price });

        // Cập nhật trạng thái đơn hàng
        await query(`
          UPDATE orders SET status = 'REFUNDED' WHERE order_id = @order_id
        `, { order_id: dispute.order_id });

      } else if (winner === 'seller') {
        // Chuyển tiền cho seller
        await query(`
          UPDATE users 
          SET wallet_balance = wallet_balance + @total_price
          WHERE id = @seller_id
        `, { total_price: order.total_price, seller_id: order.seller_id });

        // Ghi nhận giao dịch
        await query(`
          INSERT INTO transactions (user_id, order_id, amount, type, status)
          VALUES (@seller_id, @order_id, @total_price, 'PAYOUT', 'SUCCESS')
        `, { seller_id: order.seller_id, order_id: dispute.order_id, total_price: order.total_price });

        // Cập nhật trạng thái đơn hàng
        await query(`
          UPDATE orders SET status = 'COMPLETED' WHERE order_id = @order_id
        `, { order_id: dispute.order_id });
      }

      // Cập nhật payment_holding
      await query(`
        UPDATE payment_holding 
        SET status = 'RELEASED', release_reason = @resolution, released_at = GETDATE()
        WHERE order_id = @order_id
      `, { order_id: dispute.order_id, resolution });

      await query('COMMIT TRANSACTION');

      res.json({
        success: true,
        message: `Dispute resolved in favor of ${winner}`,
        winner: winner,
        amount: winner === 'buyer' ? (refund_amount || order.total_price) : order.total_price
      });
    } catch (innerError) {
      await query('ROLLBACK TRANSACTION');
      throw innerError;
    }
  } catch (error) {
    console.error('Resolve dispute error:', error);
    res.status(500).json({ message: 'Failed to resolve dispute' });
  }
}

// Duyệt lệnh rút tiền
async function approveWithdrawal(req, res) {
  try {
    const { transaction_id, admin_id, status, reason } = req.body;

    // Lấy thông tin giao dịch rút tiền
    const transactionResult = await query(`
      SELECT * FROM transactions WHERE transaction_id = @transaction_id AND type = 'WITHDRAW' AND status = 'PENDING'
    `, { transaction_id });

    const transaction = transactionResult.recordset[0];
    if (!transaction) {
      return res.status(404).json({ message: 'Withdrawal request not found' });
    }

    if (status === 'APPROVED') {
      // Cập nhật trạng thái giao dịch
      await query(`
        UPDATE transactions 
        SET status = 'SUCCESS', admin_id = @admin_id, processed_at = GETDATE()
        WHERE transaction_id = @transaction_id
      `, { transaction_id, admin_id });

      res.json({
        success: true,
        message: 'Withdrawal approved successfully'
      });
    } else if (status === 'REJECTED') {
      // Từ chối rút tiền - hoàn lại tiền vào ví
      await query('BEGIN TRANSACTION');

      try {
        // Hoàn tiền vào ví user
        await query(`
          UPDATE users 
          SET wallet_balance = wallet_balance + @amount
          WHERE id = @user_id
        `, { amount: transaction.amount, user_id: transaction.user_id });

        // Cập nhật trạng thái giao dịch
        await query(`
          UPDATE transactions 
          SET status = 'FAILED', admin_id = @admin_id, processed_at = GETDATE(), rejection_reason = @reason
          WHERE transaction_id = @transaction_id
        `, { transaction_id, admin_id, reason });

        // Ghi nhận giao dịch hoàn tiền
        await query(`
          INSERT INTO transactions (user_id, amount, type, status)
          VALUES (@user_id, @amount, 'WITHDRAW_REFUND', 'SUCCESS')
        `, { user_id: transaction.user_id, amount: transaction.amount });

        await query('COMMIT TRANSACTION');

        res.json({
          success: true,
          message: 'Withdrawal rejected and refunded'
        });
      } catch (innerError) {
        await query('ROLLBACK TRANSACTION');
        throw innerError;
      }
    }
  } catch (error) {
    console.error('Approve withdrawal error:', error);
    res.status(500).json({ message: 'Failed to approve withdrawal' });
  }
}

// Điều chỉnh số dư user
async function adjustBalance(req, res) {
  try {
    const { user_id, amount, type, reason, admin_id } = req.body;

    if (!['ADD', 'SUBTRACT'].includes(type)) {
      return res.status(400).json({ message: 'Type must be ADD or SUBTRACT' });
    }

    const actualAmount = type === 'ADD' ? amount : -amount;

    // Bắt đầu transaction
    await query('BEGIN TRANSACTION');

    try {
      // Lấy thông tin user để log
      const userResult = await query(
        `SELECT name FROM users WHERE id = @user_id`,
        { user_id }
      );
      const userName = userResult.recordset[0]?.name || 'Unknown';

      // Cập nhật số dư user
      await query(`
        UPDATE users 
        SET wallet_balance = wallet_balance + @actualAmount
        WHERE id = @user_id
      `, { actualAmount, user_id });

      // Ghi nhận giao dịch điều chỉnh với đầy đủ thông tin
      await query(`
        INSERT INTO transactions (
          user_id, amount, type, status, admin_id, 
          product_name, from_user_name, to_user_name, 
          processed_at, created_at
        )
        VALUES (
          @user_id, @amount, 'ADJUSTMENT', 'SUCCESS', @admin_id,
          'Balance Adjustment', 'Admin', @userName,
          GETDATE(), GETDATE()
        )
      `, { user_id, amount, admin_id, userName });

      // Ghi log admin action
      await query(`
        INSERT INTO admin_logs (admin_id, user_id, action, amount, reason, created_at)
        VALUES (@admin_id, @user_id, @type, @amount, @reason, GETDATE())
      `, { admin_id, user_id, type, amount, reason });

      await query('COMMIT TRANSACTION');

      // Lấy số dư mới của user
      const balanceResult = await query(
        `SELECT wallet_balance FROM users WHERE id = @user_id`,
        { user_id }
      );
      const newBalance = balanceResult.recordset[0]?.wallet_balance || 0;

      res.json({
        success: true,
        message: `Balance ${type.toLowerCase()}ed successfully`,
        new_balance: newBalance,
        adjustment_amount: actualAmount
      });
    } catch (innerError) {
      await query('ROLLBACK TRANSACTION');
      throw innerError;
    }
  } catch (error) {
    console.error('Adjust balance error:', error);
    res.status(500).json({ message: 'Failed to adjust balance', error: error.message });
  }
}

// Lấy danh sách user bị đóng băng
async function getFrozenUsers(req, res) {
  try {
    const result = await query(`
      SELECT 
        fu.*,
        u.name as user_name,
        u.email as user_email,
        a1.name as freeze_admin_name,
        a2.name as unfreeze_admin_name
      FROM frozen_users fu
      LEFT JOIN users u ON fu.user_id = u.id
      LEFT JOIN users a1 ON fu.admin_id = a1.id
      LEFT JOIN users a2 ON fu.unfreeze_admin_id = a2.id
      ORDER BY fu.created_at DESC
    `);

    res.json({
      success: true,
      frozen_users: result.recordset
    });
  } catch (error) {
    console.error('Get frozen users error:', error);
    res.status(500).json({ message: 'Failed to get frozen users' });
  }
}

// Lấy danh sách rút tiền chờ duyệt
async function getPendingWithdrawals(req, res) {
  try {
    const result = await query(`
      SELECT 
        t.*,
        u.name as user_name,
        u.email as user_email,
        ba.account_number,
        ba.account_name,
        b.bank_name
      FROM transactions t
      LEFT JOIN users u ON t.user_id = u.id
      LEFT JOIN user_bank_accounts ba ON u.id = ba.user_id
      LEFT JOIN banks b ON ba.bank_id = b.id
      WHERE t.type = 'WITHDRAW' AND t.status = 'PENDING'
      ORDER BY t.created_at DESC
    `);

    res.json({
      success: true,
      pending_withdrawals: result.recordset
    });
  } catch (error) {
    console.error('Get pending withdrawals error:', error);
    res.status(500).json({ message: 'Failed to get pending withdrawals' });
  }
}

module.exports = {
  getDashboard,
  freezeUser,
  unfreezeUser,
  resolveDispute,
  approveWithdrawal,
  adjustBalance,
  getFrozenUsers,
  getPendingWithdrawals
};
