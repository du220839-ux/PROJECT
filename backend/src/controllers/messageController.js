const { query } = require('../config/db');

async function getMessages(req, res) {
  try {
    console.log('Get messages - Conversation ID:', req.params.conversationId, 'User ID:', req.user?.id);
    
    const conversationId = Number(req.params.conversationId);
    const userId = Number(req.user.id);
    
    // For now, get messages by product_id since we don't have conversation_id in messages table
    const result = await query(`
      SELECT 
        m.id,
        m.message as content,
        m.is_read,
        m.created_at,
        m.sender_id,
        u.name as sender_name,
        u.avatar as sender_avatar
      FROM messages m
      INNER JOIN users u ON m.sender_id = u.id
      WHERE m.product_id = @conversationId
      ORDER BY m.created_at ASC
    `, { conversationId });

    console.log('Found messages:', result.recordset.length, 'for product:', conversationId);
    
    res.json({
      success: true,
      messages: result.recordset
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ message: 'Get messages failed', error: error.message });
  }
}

async function sendMessage(req, res) {
  try {
    console.log('Send message - Product ID:', req.params.conversationId, 'User ID:', req.user?.id);
    
    const productId = Number(req.params.conversationId);
    const userId = Number(req.user.id);
    const { content, receiver_id } = req.body;
    
    if (!content || content.trim().length === 0) {
      return res.status(400).json({ message: 'Message content is required' });
    }
    
    if (!receiver_id) {
      return res.status(400).json({ message: 'Receiver ID is required' });
    }
    
    // Insert message using existing table structure
    const result = await query(`
      INSERT INTO messages (sender_id, receiver_id, product_id, message)
      VALUES (@userId, @receiverId, @productId, @content);
      
      SELECT SCOPE_IDENTITY() as message_id;
    `, { 
      userId, 
      receiverId: Number(receiver_id), 
      productId, 
      content: content.trim() 
    });
    
    const messageId = result.recordset[0].message_id;
    
    // Get the message with sender info
    const messageResult = await query(`
      SELECT 
        m.id,
        m.message as content,
        m.is_read,
        m.created_at,
        m.sender_id,
        u.name as sender_name,
        u.avatar as sender_avatar
      FROM messages m
      INNER JOIN users u ON m.sender_id = u.id
      WHERE m.id = @messageId
    `, { messageId });
    
    console.log('Message sent:', messageId, 'for product:', productId);
    
    res.json({
      success: true,
      message: messageResult.recordset[0]
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ message: 'Send message failed', error: error.message });
  }
}

async function createConversation(req, res) {
  try {
    console.log('Create conversation - User ID:', req.user?.id, 'Product ID:', req.body.product_id);
    
    const userId = Number(req.user.id);
    const productId = Number(req.body.product_id);
    
    if (!productId) {
      return res.status(400).json({ message: 'product_id is required' });
    }
    
    // Get product info and seller
    const productResult = await query(
      `SELECT id, user_id as seller_id FROM products WHERE id = @productId`,
      { productId }
    );
    
    if (productResult.recordset.length === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }
    
    const sellerId = productResult.recordset[0].seller_id;
    
    if (sellerId === userId) {
      return res.status(400).json({ message: 'Cannot start conversation with yourself' });
    }
    
    // Check if conversation already exists
    const existingResult = await query(
      `SELECT id FROM conversations 
       WHERE product_id = @productId AND buyer_id = @userId AND seller_id = @sellerId`,
      { productId, userId, sellerId }
    );
    
    if (existingResult.recordset.length > 0) {
      return res.json({
        success: true,
        conversation_id: existingResult.recordset[0].id,
        message: 'Conversation already exists'
      });
    }
    
    // Create new conversation
    const result = await query(`
      INSERT INTO conversations (product_id, buyer_id, seller_id)
      VALUES (@productId, @userId, @sellerId);
      
      SELECT SCOPE_IDENTITY() as conversation_id;
    `, { productId, userId, sellerId });
    
    const conversationId = result.recordset[0].conversation_id;
    
    console.log('Created conversation:', conversationId, 'for product:', productId);
    
    res.json({
      success: true,
      conversation_id: conversationId
    });
  } catch (error) {
    console.error('Create conversation error:', error);
    res.status(500).json({ message: 'Create conversation failed', error: error.message });
  }
}

module.exports = {
  getMessages,
  sendMessage,
  createConversation
};
