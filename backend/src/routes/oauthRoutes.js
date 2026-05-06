const express = require('express');
const { signInWithGoogle, signInWithFacebook } = require('../controllers/oauthController');

const router = express.Router();

// OAuth routes (no authentication required)
router.post('/google', signInWithGoogle);
router.post('/facebook', signInWithFacebook);

module.exports = router;
