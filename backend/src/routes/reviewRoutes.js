const express = require('express');
const auth = require('../middleware/auth');
const { getSellerReviews, createReview } = require('../controllers/reviewController');

const router = express.Router();

router.get('/seller/:sellerId', getSellerReviews);
router.post('/', auth, createReview);

module.exports = router;
