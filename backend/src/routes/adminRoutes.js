const express = require('express');
const {
  getDashboard,
  freezeUser,
  unfreezeUser,
  resolveDispute,
  approveWithdrawal,
  adjustBalance,
  getFrozenUsers,
  getPendingWithdrawals
} = require('../controllers/adminController');
const { requireAdmin, requirePermission } = require('../middleware/adminAuth');

const router = express.Router();

// Dashboard
router.get('/dashboard', requireAdmin, getDashboard);

// User management
router.post('/freeze-user', requireAdmin, requirePermission('freeze'), freezeUser);
router.post('/unfreeze-user', requireAdmin, requirePermission('freeze'), unfreezeUser);
router.get('/frozen-users', requireAdmin, requirePermission('users'), getFrozenUsers);

// Dispute management
router.post('/resolve-dispute', requireAdmin, requirePermission('disputes'), resolveDispute);

// Withdrawal management
router.post('/approve-withdrawal', requireAdmin, requirePermission('withdrawals'), approveWithdrawal);
router.get('/pending-withdrawals', requireAdmin, requirePermission('withdrawals'), getPendingWithdrawals);

// Balance adjustment
router.post('/adjust-balance', requireAdmin, requirePermission('wallet'), adjustBalance);

module.exports = router;
