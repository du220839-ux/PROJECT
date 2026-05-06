const express = require('express');
const auth = require('../middleware/auth');
const {
  listBanks,
  getMyBankAccount,
  linkBankAccount,
  createPayment,
  markPaymentSuccess
} = require('../controllers/paymentController');

const router = express.Router();

router.get('/banks', auth, listBanks);
router.get('/bank-account', auth, getMyBankAccount);
router.post('/bank-account', auth, linkBankAccount);
router.post('/create', auth, createPayment);
router.post('/:id/success', auth, markPaymentSuccess);

module.exports = router;
