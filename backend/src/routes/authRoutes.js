const express = require('express');
const { login, register, getProfile, updateProfile } = require('../controllers/authController');
const auth = require('../middleware/auth');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.post('/check-user', (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ message: 'Email is required' });
  }

  // For now, just return null to indicate user doesn't exist
  // The actual check will be implemented in authController
  res.json({ user: null });
});
router.post('/logout', (req, res) => {
  // For JWT tokens, logout is handled client-side by removing token
  res.json({ message: 'Logout successful' });
});
router.get('/profile', auth, getProfile);
router.put('/profile', auth, updateProfile);

module.exports = router;
