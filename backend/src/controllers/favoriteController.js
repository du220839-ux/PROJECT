const { query } = require('../config/db');

async function toggleFavorite(req, res) {
  try {
    console.log('Toggle favorite - User ID:', req.user?.id, 'Product ID:', req.body?.product_id);
    
    const userId = Number(req.user.id);
    const productId = Number(req.body.product_id);

    if (!productId) {
      return res.status(400).json({ message: 'product_id is required' });
    }

    const existing = await query(
      `SELECT TOP 1 id
       FROM dbo.favorites
       WHERE user_id = @userId AND product_id = @productId`,
      { userId, productId }
    );

    if (existing.recordset.length) {
      await query(
        `DELETE FROM dbo.favorites
         WHERE user_id = @userId AND product_id = @productId`,
        { userId, productId }
      );

      console.log('Removed from favorites - User:', userId, 'Product:', productId);
      return res.json({
        message: 'Removed from favorites',
        is_favorite: false,
        product_id: productId
      });
    }

    await query(
      `INSERT INTO dbo.favorites (user_id, product_id)
       VALUES (@userId, @productId)`,
      { userId, productId }
    );

    console.log('Added to favorites - User:', userId, 'Product:', productId);
    return res.json({
      message: 'Added to favorites',
      is_favorite: true,
      product_id: productId
    });
  } catch (error) {
    console.error('Toggle favorite error:', error);
    return res.status(500).json({ message: 'Toggle favorite failed', error: error.message });
  }
}

async function getFavorites(req, res) {
  try {
    console.log('Get favorites - User ID:', req.user?.id);
    
    const userId = Number(req.user.id);
    
    const result = await query(`
      SELECT 
        f.id as favorite_id,
        f.created_at as favorited_at,
        p.*,
        CASE WHEN f.user_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
      FROM dbo.favorites f
      INNER JOIN dbo.products p ON f.product_id = p.id
      WHERE f.user_id = @userId
      ORDER BY f.created_at DESC
    `, { userId });

    console.log('Found favorites:', result.recordset.length, 'items for user:', userId);
    
    res.json({
      success: true,
      favorites: result.recordset
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({ message: 'Get favorites failed', error: error.message });
  }
}

module.exports = {
  toggleFavorite,
  getFavorites
};
