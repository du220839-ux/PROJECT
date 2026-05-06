const express = require('express');
const {
  createOrder,
  markAsPaid,
  markAsDelivered,
  createDispute,
  processRefund,
  completeOrder,
  getUserOrders,
  payWithWallet,
  createOrderAndPayWithWallet
} = require('../controllers/orderController');
const auth = require('../middleware/auth');

const router = express.Router();

// Public routes
router.post('/', createOrder);
router.get('/user/:user_id', getUserOrders);

// Protected routes
router.post('/paid', auth, markAsPaid);
router.post('/delivered', auth, markAsDelivered);
router.post('/dispute', auth, createDispute);
router.post('/refund', auth, processRefund);
router.post('/complete', auth, completeOrder);

// Wallet payment routes
router.post('/pay-wallet', auth, payWithWallet);
router.post('/create-pay-wallet', auth, createOrderAndPayWithWallet);

module.exports = router;
