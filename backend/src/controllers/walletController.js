const { query } = require('../config/db');

// Lấy thông tin ví của user
async function getWallet(req, res) {
  try {
    const userId = req.user.id; // Use authenticated user ID instead of params
    
    const result = await query(`
      SELECT 
        id,
        name,
        email,
        wallet_balance,
        pending_balance,
        created_at
      FROM users 
      WHERE id = @userId
    `, { userId });

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = result.recordset[0];

    // Lấy lịch sử giao dịch ví đơn giản hơn
    const transactionsResult = await query(`
      SELECT 
        transaction_id,
        amount,
        type,
        status,
        product_name,
        created_at
      FROM transactions 
      WHERE user_id = @userId
      ORDER BY created_at DESC
      OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY
    `, { userId });

    res.json({
      success: true,
      wallet: {
        user_id: user.id,
        name: user.name,
        email: user.email,
        wallet_balance: user.wallet_balance || 0,
        pending_balance: user.pending_balance || 0,
        total_balance: (user.wallet_balance || 0) + (user.pending_balance || 0)
      },
      transactions: transactionsResult.recordset
    });
  } catch (error) {
    console.error('Get wallet error:', error);
    res.status(500).json({ message: 'Failed to get wallet', error: error.message });
  }
}

// Nạp tiền vào ví
async function topUp(req, res) {
  try {
    const { amount, payment_method, payment_reference } = req.body;
    const userId = req.user.id; // Use authenticated user ID
    
    if (amount <= 0) {
      return res.status(400).json({ message: 'Amount must be greater than 0' });
    }

    // Cập nhật số dư ví
    await query(`
      UPDATE users 
      SET wallet_balance = wallet_balance + @amount
      WHERE id = @userId
    `, { amount, userId });

    // Ghi nhận giao dịch nạp tiền
    await query(`
      INSERT INTO transactions (
        user_id, amount, type, payment_method, payment_reference, 
        status, product_name, from_user_name, to_user_name, 
        processed_at, created_at
      )
      VALUES (
        @userId, @amount, 'TOPUP', @payment_method, @payment_reference, 
        'SUCCESS', 'Top Up', 'System', 'User', 
        GETDATE(), GETDATE()
      )
    `, { userId, amount, payment_method, payment_reference });

    // Lấy thông tin ví mới
    const walletResult = await query(`
      SELECT wallet_balance, pending_balance FROM users WHERE id = @userId
    `, { userId });

    res.json({
      success: true,
      message: 'Top up successful',
      new_balance: walletResult.recordset[0].wallet_balance
    });
  } catch (error) {
    console.error('Top up error:', error);
    res.status(500).json({ message: 'Failed to top up', error: error.message });
  }
}

// Rút tiền từ ví
async function withdraw(req, res) {
  try {
    const { amount, bank_account_id, withdraw_reason } = req.body;
    const userId = req.user.id; // Use authenticated user ID
    
    if (amount <= 0) {
      return res.status(400).json({ message: 'Amount must be greater than 0' });
    }

    // Kiểm tra số dư
    const balanceResult = await query(
      `SELECT wallet_balance FROM users WHERE id = @userId`,
      { userId }
    );

    const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;
    if (currentBalance < amount) {
      return res.status(400).json({ message: 'Insufficient balance' });
    }

    // Trừ tiền từ ví
    await query(`
      UPDATE users 
      SET wallet_balance = wallet_balance - @amount
      WHERE id = @userId
    `, { amount, userId });

    // Ghi nhận giao dịch rút tiền
    await query(`
      INSERT INTO transactions (
        user_id, amount, type, status, payment_method, 
        product_name, from_user_name, to_user_name, 
        processed_at, created_at
      )
      VALUES (
        @userId, @amount, 'WITHDRAW', 'PENDING', 'BANK_TRANSFER',
        'Withdraw', 'User', 'Bank', 
        GETDATE(), GETDATE()
      )
    `, { userId, amount });

    // Lấy thông tin ví mới
    const walletResult = await query(`
      SELECT wallet_balance, pending_balance FROM users WHERE id = @userId
    `, { userId });

    res.json({
      success: true,
      message: 'Withdraw request submitted',
      new_balance: walletResult.recordset[0].wallet_balance
    });
  } catch (error) {
    console.error('Withdraw error:', error);
    res.status(500).json({ message: 'Failed to withdraw', error: error.message });
  }
}

// Chuyển tiền giữa các user
async function transfer(req, res) {
  try {
    const { from_user_id, to_user_id, amount, message } = req.body;
    
    if (amount <= 0) {
      return res.status(400).json({ message: 'Amount must be greater than 0' });
    }

    if (from_user_id === to_user_id) {
      return res.status(400).json({ message: 'Cannot transfer to yourself' });
    }

    // Kiểm tra số dư người gửi
    const balanceResult = await query(`
      SELECT wallet_balance FROM users WHERE id = @from_user_id
    `, { from_user_id });

    const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;

    if (currentBalance < amount) {
      return res.status(400).json({ message: 'Insufficient balance' });
    }

    // Bắt đầu transaction
    await query('BEGIN TRANSACTION');

    try {
      // Trừ tiền người gửi
      await query(`
        UPDATE users 
        SET wallet_balance = wallet_balance - @amount
        WHERE id = @from_user_id
      `, { amount, from_user_id });

      // Cộng tiền người nhận
      await query(`
        UPDATE users 
        SET wallet_balance = wallet_balance + @amount
        WHERE id = @to_user_id
      `, { amount, to_user_id });

      // Ghi nhận giao dịch người gửi
      await query(`
        INSERT INTO transactions (user_id, amount, type, status)
        VALUES (@from_user_id, @amount, 'TRANSFER_OUT', 'SUCCESS')
      `, { from_user_id, amount });

      // Ghi nhận giao dịch người nhận
      await query(`
        INSERT INTO transactions (user_id, amount, type, status)
        VALUES (@to_user_id, @amount, 'TRANSFER_IN', 'SUCCESS')
      `, { to_user_id, amount });

      await query('COMMIT TRANSACTION');

      res.json({
        success: true,
        message: 'Transfer successful',
        amount: amount,
        remaining_balance: currentBalance - amount
      });
    } catch (innerError) {
      await query('ROLLBACK TRANSACTION');
      throw innerError;
    }
  } catch (error) {
    console.error('Transfer error:', error);
    res.status(500).json({ message: 'Failed to transfer' });
  }
}

// Lấy lịch sử giao dịch
async function getTransactions(req, res) {
  try {
    const { type, page = 1, limit = 20 } = req.query;
    const userId = req.user.id; // Use authenticated user ID
    
    let whereClause = 'WHERE t.user_id = @userId';
    const params = { userId };
    
    if (type) {
      whereClause += ' AND t.type = @type';
      params.type = type;
    }

    const offset = (parseInt(page) - 1) * parseInt(limit);

    const result = await query(`
      SELECT 
        t.transaction_id,
        t.amount,
        t.type,
        t.status,
        t.created_at,
        t.payment_method,
        t.payment_reference,
        o.order_id,
        p.name as product_name,
        u_from.name as from_user_name,
        u_to.name as to_user_name
      FROM transactions t
      LEFT JOIN orders o ON t.order_id = o.order_id
      LEFT JOIN products p ON o.product_id = p.id
      LEFT JOIN users u_from ON t.user_id = u_from.id AND t.type = 'TRANSFER_OUT'
      LEFT JOIN users u_to ON t.user_id = u_to.id AND t.type = 'TRANSFER_IN'
      ${whereClause}
      ORDER BY t.created_at DESC
      OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY
    `, { ...params, offset, limit: parseInt(limit) });

    res.json({
      success: true,
      transactions: result.recordset
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({ message: 'Failed to get transactions' });
  }
}

// Liên kết ngân hàng
async function linkBank(req, res) {
  try {
    const { bank_id, account_number, account_name } = req.body;
    const userId = req.user.id;

    if (!bank_id || !account_number || !account_name) {
      return res.status(400).json({ message: 'All bank fields are required' });
    }

    // Kiểm tra tài khoản ngân hàng đã tồn tại chưa
    const existingResult = await query(
      `SELECT id FROM user_bank_accounts 
       WHERE user_id = @userId AND account_number = @accountNumber`,
      { userId, accountNumber }
    );

    if (existingResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Bank account already linked' });
    }

    // Thêm tài khoản ngân hàng mới
    await query(`
      INSERT INTO user_bank_accounts (user_id, bank_id, account_number, account_name, created_at)
      VALUES (@userId, @bankId, @accountNumber, @accountName, GETDATE())
    `, { userId, bankId, accountNumber, accountName });

    res.json({
      success: true,
      message: 'Bank account linked successfully'
    });
  } catch (error) {
    console.error('Link bank error:', error);
    res.status(500).json({ message: 'Failed to link bank account' });
  }
}

// Lấy danh sách ngân hàng đã liên kết
async function getLinkedBanks(req, res) {
  try {
    const userId = req.user.id;

    const result = await query(`
      SELECT 
        uba.id,
        uba.bank_id,
        b.name as bank_name,
        uba.account_number,
        uba.account_name,
        uba.created_at
      FROM user_bank_accounts uba
      LEFT JOIN banks b ON uba.bank_id = b.id
      WHERE uba.user_id = @userId
      ORDER BY uba.created_at DESC
    `, { userId });

    res.json({
      success: true,
      banks: result.recordset
    });
  } catch (error) {
    console.error('Get linked banks error:', error);
    res.status(500).json({ message: 'Failed to get linked banks' });
  }
}

// Rút tiền về ngân hàng
async function withdrawToBank(req, res) {
  try {
    const { amount, bank_account_id, note } = req.body;
    const userId = req.user.id;

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: 'Amount must be greater than 0' });
    }

    if (!bank_account_id) {
      return res.status(400).json({ message: 'Bank account ID is required' });
    }

    await query('BEGIN TRANSACTION');

    try {
      // Kiểm tra số dư
      const balanceResult = await query(
        `SELECT wallet_balance FROM users WHERE id = @userId`,
        { userId }
      );

      const currentBalance = balanceResult.recordset[0]?.wallet_balance || 0;
      if (currentBalance < amount) {
        await query('ROLLBACK TRANSACTION');
        return res.status(400).json({ message: 'Insufficient balance' });
      }

      // Kiểm tra tài khoản ngân hàng thuộc user và lấy thông tin ngân hàng
      const bankResult = await query(`
        SELECT 
          uba.bank_id,
          uba.account_number,
          uba.account_name,
          b.name as bank_name
        FROM user_bank_accounts uba
        LEFT JOIN banks b ON uba.bank_id = b.id
        WHERE uba.id = @bankAccountId AND uba.user_id = @userId
      `, { bankAccountId, userId });

      if (bankResult.recordset.length === 0) {
        await query('ROLLBACK TRANSACTION');
        return res.status(400).json({ message: 'Bank account not found' });
      }

      const bankInfo = bankResult.recordset[0];

      // Trừ tiền từ ví
      await query(`
        UPDATE users 
        SET wallet_balance = wallet_balance - @amount
        WHERE id = @userId
      `, { userId, amount });

      // Tạo giao dịch rút tiền
      await query(`
        INSERT INTO transactions (
          user_id, amount, type, status, payment_method, 
          product_name, from_user_name, to_user_name, 
          processed_at, created_at
        )
        VALUES (
          @userId, @amount, 'WITHDRAW', 'PENDING', 'BANK_TRANSFER',
          'Withdraw to ${bankInfo.bank_name || 'Bank'}', 'User', bankInfo.account_name,
          GETDATE(), GETDATE()
        )
      `, { userId, amount });

      await query('COMMIT TRANSACTION');

      res.json({
        success: true,
        message: 'Withdrawal request submitted successfully',
        amount: amount,
        bank_info: bankInfo
      });
    } catch (innerError) {
      await query('ROLLBACK TRANSACTION');
      throw innerError;
    }
  } catch (error) {
    console.error('Withdraw to bank error:', error);
    res.status(500).json({ message: 'Failed to process withdrawal' });
  }
}

module.exports = {
  getWallet,
  topUp,
  withdraw,
  transfer,
  getTransactions,
  linkBank,
  getLinkedBanks,
  withdrawToBank
};
