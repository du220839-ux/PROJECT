const express = require('express');
const { toggleFavorite, getFavorites } = require('../controllers/favoriteController');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/', auth, getFavorites);
router.post('/toggle', auth, toggleFavorite);

module.exports = router;
