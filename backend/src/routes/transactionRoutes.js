const express = require('express');
const auth = require('../middleware/auth');
const {
  createTransaction,
  getMyBuyingTransactions,
  getMySellingTransactions,
  confirmTransaction,
  rejectTransaction
} = require('../controllers/transactionController');

const router = express.Router();

router.post('/', auth, createTransaction);
router.get('/buying', auth, getMyBuyingTransactions);
router.get('/selling', auth, getMySellingTransactions);
router.patch('/:id/confirm', auth, confirmTransaction);
router.patch('/:id/reject', auth, rejectTransaction);

module.exports = router;
