const express = require('express');
const { getConversations, getConversation } = require('../controllers/conversationController');
const auth = require('../middleware/auth');

const router = express.Router();

router.get('/', auth, getConversations);
router.get('/:id', auth, getConversation);

module.exports = router;
