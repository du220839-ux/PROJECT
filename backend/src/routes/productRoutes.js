const express = require('express');
const {
  getProducts,
  getProduct,
  createProduct,
  getMyProducts,
  getPendingProducts,
  updateProductStatus
} = require('../controllers/productController');
const auth = require('../middleware/auth');
const adminOnly = require('../middleware/admin');
const { uploadProductImages } = require('../middleware/upload');

const router = express.Router();

// Public list, but if token exists it will also map is_favorite for that user.
router.get('/', (req, _res, next) => {
  const authHeader = req.headers.authorization || '';
  if (authHeader.startsWith('Bearer ')) {
    return auth(req, _res, next);
  }
  req.user = null;
  return next();
}, getProducts);

router.post('/', auth, uploadProductImages.array('images[]', 5), createProduct);
router.get('/my-products', auth, getMyProducts);
router.get('/admin/pending', auth, adminOnly, getPendingProducts);
router.patch('/admin/:id/status', auth, adminOnly, updateProductStatus);
router.get('/:id', (req, _res, next) => {
  const authHeader = req.headers.authorization || '';
  if (authHeader.startsWith('Bearer ')) {
    return auth(req, _res, next);
  }
  req.user = null;
  return next();
}, getProduct);

module.exports = router;
