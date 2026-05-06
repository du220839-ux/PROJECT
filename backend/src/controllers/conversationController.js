const { query } = require('../config/db');

async function getConversations(req, res) {
  try {
    console.log('Get conversations - User ID:', req.user?.id);
    
    const userId = Number(req.user.id);
    
    // Get conversations from messages table since we don't have conversations table
    const result = await query(`
      SELECT DISTINCT
        m.product_id as id,
        m.created_at,
        CASE 
          WHEN m.sender_id = @userId THEN u_receiver.name
          ELSE u_sender.name 
        END as other_user_name,
        CASE 
          WHEN m.sender_id = @userId THEN u_receiver.avatar
          ELSE u_sender.avatar 
        END as other_user_avatar,
        CASE 
          WHEN m.sender_id = @userId THEN u_receiver.id
          ELSE u_sender.id 
        END as other_user_id,
        p.title as product_title,
        p.price as product_price,
        (SELECT TOP 1 m2.message 
         FROM messages m2 
         WHERE (m2.sender_id = @userId AND m2.receiver_id = CASE WHEN m.sender_id = @userId THEN u_receiver.id ELSE u_sender.id END)
            OR (m2.receiver_id = @userId AND m2.sender_id = CASE WHEN m.sender_id = @userId THEN u_receiver.id ELSE u_sender.id END)
            AND m2.product_id = m.product_id
         ORDER BY m2.created_at DESC
        ) as last_message,
        (SELECT TOP 1 m2.created_at 
         FROM messages m2 
         WHERE (m2.sender_id = @userId AND m2.receiver_id = CASE WHEN m.sender_id = @userId THEN u_receiver.id ELSE u_sender.id END)
            OR (m2.receiver_id = @userId AND m2.sender_id = CASE WHEN m.sender_id = @userId THEN u_receiver.id ELSE u_sender.id END)
            AND m2.product_id = m.product_id
         ORDER BY m2.created_at DESC
        ) as last_message_time
      FROM messages m
      INNER JOIN products p ON m.product_id = p.id
      INNER JOIN users u_sender ON m.sender_id = u_sender.id
      INNER JOIN users u_receiver ON m.receiver_id = u_receiver.id
      WHERE m.sender_id = @userId OR m.receiver_id = @userId
      ORDER BY m.created_at DESC
    `, { userId });

    console.log('Found conversations:', result.recordset.length, 'for user:', userId);
    
    res.json({
      success: true,
      data: result.recordset
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({ message: 'Get conversations failed', error: error.message });
  }
}

async function getConversation(req, res) {
  try {
    const conversationId = Number(req.params.id);
    const userId = Number(req.user.id);
    
    const result = await query(`
      SELECT 
        c.*,
        p.title as product_title,
        p.thumbnail_url as product_thumbnail,
        u_buyer.name as buyer_name,
        u_buyer.avatar as buyer_avatar,
        u_seller.name as seller_name,
        u_seller.avatar as seller_avatar
      FROM conversations c
      INNER JOIN products p ON c.product_id = p.id
      INNER JOIN users u_buyer ON c.buyer_id = u_buyer.id
      INNER JOIN users u_seller ON c.seller_id = u_seller.id
      WHERE c.id = @conversationId AND (c.buyer_id = @userId OR c.seller_id = @userId)
    `, { conversationId, userId });

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Conversation not found' });
    }

    res.json({
      success: true,
      conversation: result.recordset[0]
    });
  } catch (error) {
    console.error('Get conversation error:', error);
    res.status(500).json({ message: 'Get conversation failed', error: error.message });
  }
}

module.exports = {
  getConversations,
  getConversation
};
