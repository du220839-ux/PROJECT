const { query } = require('../config/db');

async function getSellerReviews(req, res) {
  try {
    const sellerId = Number(req.params.sellerId);
    if (!sellerId) {
      return res.status(400).json({ message: 'Invalid seller id' });
    }

    const result = await query(
      `SELECT
          r.id,
          r.product_id,
          r.reviewer_id,
          r.seller_id,
          r.rating,
          r.comment,
          r.created_at,
          u.name AS reviewer_name,
          u.avatar AS reviewer_avatar,
          p.title AS product_title
       FROM dbo.reviews r
       INNER JOIN dbo.users u ON u.id = r.reviewer_id
       INNER JOIN dbo.products p ON p.id = r.product_id
       WHERE r.seller_id = @seller_id
       ORDER BY r.created_at DESC`,
      { seller_id: sellerId }
    );

    const summary = await query(
      `SELECT
          COUNT(*) AS total_reviews,
          CAST(ISNULL(AVG(CAST(rating AS FLOAT)), 0) AS DECIMAL(10,2)) AS average_rating
       FROM dbo.reviews
       WHERE seller_id = @seller_id`,
      { seller_id: sellerId }
    );

    return res.json({
      summary: summary.recordset[0],
      data: result.recordset
    });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load reviews', error: error.message });
  }
}

async function createReview(req, res) {
  try {
    const reviewerId = Number(req.user.id);
    const productId = Number(req.body.product_id);
    const sellerId = Number(req.body.seller_id);
    const rating = Number(req.body.rating);
    const comment = (req.body.comment || '').trim();

    if (!productId || !sellerId || !Number.isInteger(rating) || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Invalid review payload' });
    }

    if (reviewerId === sellerId) {
      return res.status(400).json({ message: 'You cannot review yourself' });
    }

    const exists = await query(
      `SELECT TOP 1 id
       FROM dbo.reviews
       WHERE product_id = @product_id AND reviewer_id = @reviewer_id`,
      { product_id: productId, reviewer_id: reviewerId }
    );

    if (exists.recordset.length) {
      return res.status(409).json({ message: 'You already reviewed this product' });
    }

    const inserted = await query(
      `INSERT INTO dbo.reviews (product_id, reviewer_id, seller_id, rating, comment)
       OUTPUT INSERTED.id, INSERTED.product_id, INSERTED.reviewer_id, INSERTED.seller_id, INSERTED.rating, INSERTED.comment, INSERTED.created_at
       VALUES (@product_id, @reviewer_id, @seller_id, @rating, @comment)`,
      {
        product_id: productId,
        reviewer_id: reviewerId,
        seller_id: sellerId,
        rating,
        comment: comment || null
      }
    );

    await query(
      `INSERT INTO dbo.notifications (user_id, title, content, is_read)
       VALUES (@user_id, @title, @content, 0)`,
      {
        user_id: sellerId,
        title: 'Danh gia moi',
        content: `Ban vua nhan duoc danh gia ${rating}/5 cho san pham #${productId}.`
      }
    );

    return res.status(201).json({ message: 'Review created', review: inserted.recordset[0] });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot create review', error: error.message });
  }
}

module.exports = {
  getSellerReviews,
  createReview
};
