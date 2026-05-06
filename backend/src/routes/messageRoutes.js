const express = require('express');
const { getMessages, sendMessage, createConversation } = require('../controllers/messageController');
const auth = require('../middleware/auth');

const router = express.Router();

// Create new conversation
router.post('/conversations', auth, createConversation);

// Get messages in a conversation
router.get('/conversations/:conversationId/messages', auth, getMessages);

// Send message to a conversation
router.post('/conversations/:conversationId/messages', auth, sendMessage);

// Legacy endpoints for frontend compatibility
router.get('/', auth, (req, res) => {
  // Redirect to conversations for frontend compatibility
  const { receiver_id, product_id } = req.query;
  if (product_id) {
    req.params.conversationId = product_id;
    return getMessages(req, res);
  }
  res.json({ success: true, messages: [] });
});

router.post('/', auth, (req, res) => {
  // Redirect to conversation messages for frontend compatibility
  const { receiver_id, product_id, message } = req.body;
  if (product_id && receiver_id) {
    req.params.conversationId = product_id;
    req.body.content = message;
    return sendMessage(req, res);
  }
  res.status(400).json({ message: 'receiver_id and product_id are required' });
});

module.exports = router;
