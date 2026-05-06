const express = require('express');
const {
  getWallet,
  topUp,
  withdraw,
  transfer,
  getTransactions,
  linkBank,
  getLinkedBanks,
  withdrawToBank
} = require('../controllers/walletController');
const auth = require('../middleware/auth');

const router = express.Router();

// Protected routes
router.get('/', auth, getWallet); // Use req.user.id instead of parameter
router.post('/topup', auth, topUp);
router.post('/withdraw', auth, withdraw);
router.post('/transfer', auth, transfer);
router.get('/transactions', auth, getTransactions); // Also use req.user.id

// Bank linking routes
router.post('/link-bank', auth, linkBank);
router.get('/linked-banks', auth, getLinkedBanks);
router.post('/withdraw-bank', auth, withdrawToBank);

module.exports = router;
