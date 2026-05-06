const { query } = require('../config/db');

async function createProduct(req, res) {
  try {
    const userId = Number(req.user.id);
    const categoryId = Number(req.body.category_id);
    const title = (req.body.title || '').trim();
    const description = (req.body.description || '').trim();
    const price = Number(req.body.price);

    if (!categoryId || !title || !description || !Number.isFinite(price) || price < 0) {
      return res.status(400).json({ message: 'Invalid product payload' });
    }

    const insertProduct = await query(
      `INSERT INTO dbo.products (user_id, category_id, title, [description], price, [status])
       OUTPUT INSERTED.id
       VALUES (@user_id, @category_id, @title, @description, @price, 'pending')`,
      {
        user_id: userId,
        category_id: categoryId,
        title,
        description,
        price
      }
    );

    const productId = insertProduct.recordset[0].id;
    const host = `${req.protocol}://${req.get('host')}`;
    const files = req.files || [];

    for (const file of files) {
      const imageUrl = `${host}/uploads/products/${file.filename}`;
      await query(
        `INSERT INTO dbo.product_images (product_id, image_url)
         VALUES (@product_id, @image_url)`,
        {
          product_id: productId,
          image_url: imageUrl
        }
      );
    }

    const productResult = await query(
      `SELECT TOP 1 id, user_id, category_id, title, [description], price, [status], created_at
       FROM dbo.products
       WHERE id = @id`,
      { id: productId }
    );

    const imagesResult = await query(
      `SELECT image_url
       FROM dbo.product_images
       WHERE product_id = @id
       ORDER BY id ASC`,
      { id: productId }
    );

    const product = productResult.recordset[0];

    return res.status(201).json({
      message: 'Product created successfully. Waiting for admin approval.',
      product: {
        ...product,
        price: Number(product.price),
        images: imagesResult.recordset
      }
    });
  } catch (error) {
    return res.status(500).json({ message: 'Create product failed', error: error.message });
  }
}

async function getMyProducts(req, res) {
  try {
    const userId = Number(req.user.id);

    const productsResult = await query(
      `SELECT
          p.id,
          p.user_id,
          p.category_id,
          p.title,
          p.[description],
          p.price,
          p.[status],
          p.created_at,
          c.id AS category_id_ref,
          c.name AS category_name,
          c.icon AS category_icon
       FROM dbo.products p
       INNER JOIN dbo.categories c ON c.id = p.category_id
       WHERE p.user_id = @user_id
       ORDER BY p.created_at DESC`,
      { user_id: userId }
    );

    const products = productsResult.recordset;
    if (!products.length) return res.json({ data: [] });

    const productIdsCsv = products.map((p) => p.id).join(',');
    const imagesResult = await query(
      `SELECT product_id, image_url
       FROM dbo.product_images
       WHERE product_id IN (${productIdsCsv})
       ORDER BY id ASC`
    );

    const imagesByProduct = imagesResult.recordset.reduce((acc, item) => {
      if (!acc[item.product_id]) acc[item.product_id] = [];
      acc[item.product_id].push({ image_url: item.image_url });
      return acc;
    }, {});

    return res.json({
      data: products.map((p) => ({
        id: p.id,
        user_id: p.user_id,
        category_id: p.category_id,
        title: p.title,
        description: p.description,
        price: Number(p.price),
        status: p.status,
        created_at: p.created_at,
        category: {
          id: p.category_id_ref,
          name: p.category_name,
          icon: p.category_icon
        },
        images: imagesByProduct[p.id] || []
      }))
    });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load my products', error: error.message });
  }
}

async function getProducts(req, res) {
  try {
    const page = Number(req.query.page || 1);
    const limit = Number(req.query.limit || 20);
    const offset = (page - 1) * limit;
    const categoryId = req.query.category_id ? Number(req.query.category_id) : null;
    const searchQuery = req.query.q ? req.query.q.trim() : null;
    const minPrice = req.query.min_price ? Number(req.query.min_price) : null;
    const maxPrice = req.query.max_price ? Number(req.query.max_price) : null;
    const sortBy = (req.query.sort_by || 'newest').toString();

    // Build WHERE conditions
    let whereConditions = ['p.[status] = \'approved\''];
    let params = { offset, limit, currentUserId: Number(req.user?.id || 0) };

    if (categoryId) {
      whereConditions.push('p.category_id = @category_id');
      params.category_id = categoryId;
    }

    if (searchQuery) {
      whereConditions.push('(p.title LIKE @searchQuery OR p.[description] LIKE @searchQuery)');
      params.searchQuery = `%${searchQuery}%`;
    }

    if (minPrice !== null) {
      whereConditions.push('p.price >= @minPrice');
      params.minPrice = minPrice;
    }

    if (maxPrice !== null) {
      whereConditions.push('p.price <= @maxPrice');
      params.maxPrice = maxPrice;
    }

    const whereClause = whereConditions.join(' AND ');

    let orderBy = 'p.created_at DESC';
    if (sortBy === 'oldest') orderBy = 'p.created_at ASC';
    else if (sortBy === 'price_low') orderBy = 'p.price ASC';
    else if (sortBy === 'price_high') orderBy = 'p.price DESC';

    const productsResult = await query(
      `SELECT
          p.id,
          p.user_id,
          p.category_id,
          p.title,
          p.[description],
          p.price,
          p.[status],
          p.created_at,
          u.id AS seller_id,
          u.name AS seller_name,
          u.email AS seller_email,
          u.phone AS seller_phone,
          u.[address] AS seller_address,
          u.avatar AS seller_avatar,
          c.id AS category_id_ref,
          c.name AS category_name,
          c.icon AS category_icon,
          CASE
            WHEN EXISTS (
              SELECT 1
              FROM dbo.favorites f
              WHERE f.product_id = p.id
              AND f.user_id = @currentUserId
            ) THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
          END AS is_favorite
       FROM dbo.products p
       INNER JOIN dbo.users u ON u.id = p.user_id
       INNER JOIN dbo.categories c ON c.id = p.category_id
       WHERE ${whereClause}
       ORDER BY ${orderBy}
       OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY`,
      params
    );

    const products = productsResult.recordset;

    if (!products.length) {
      return res.json({ data: [], page, limit });
    }

    const productIdsCsv = products.map((p) => p.id).join(',');
    const imagesResult = await query(
      `SELECT id, product_id, image_url
       FROM dbo.product_images
       WHERE product_id IN (${productIdsCsv})
       ORDER BY id ASC`
    );

    const imagesByProduct = imagesResult.recordset.reduce((acc, item) => {
      if (!acc[item.product_id]) acc[item.product_id] = [];
      acc[item.product_id].push({ image_url: item.image_url });
      return acc;
    }, {});

    const data = products.map((p) => ({
      id: p.id,
      user_id: p.user_id,
      category_id: p.category_id,
      title: p.title,
      description: p.description,
      price: Number(p.price),
      status: p.status,
      created_at: p.created_at,
      user: {
        id: p.seller_id,
        name: p.seller_name,
        email: p.seller_email,
        phone: p.seller_phone,
        address: p.seller_address,
        avatar: p.seller_avatar
      },
      category: {
        id: p.category_id_ref,
        name: p.category_name,
        icon: p.category_icon
      },
      images: imagesByProduct[p.id] || [],
      is_favorite: Boolean(p.is_favorite)
    }));

    return res.json({ data, page, limit });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load products', error: error.message });
  }
}

async function getProduct(req, res) {
  try {
    const productId = Number(req.params.id);
    if (!productId) {
      return res.status(400).json({ message: 'Invalid product id' });
    }

    const currentUserId = Number(req.user?.id || 0);
    const isAdmin = req.user?.role === 'admin' ? 1 : 0;

    const productResult = await query(
      `SELECT TOP 1
          p.id,
          p.user_id,
          p.category_id,
          p.title,
          p.[description],
          p.price,
          p.[status],
          p.created_at,
          u.id AS seller_id,
          u.name AS seller_name,
          u.email AS seller_email,
          u.phone AS seller_phone,
          u.[address] AS seller_address,
          u.avatar AS seller_avatar,
          c.id AS category_id_ref,
          c.name AS category_name,
          c.icon AS category_icon,
          CASE
            WHEN EXISTS (
              SELECT 1
              FROM dbo.favorites f
              WHERE f.product_id = p.id
              AND f.user_id = @currentUserId
            ) THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
          END AS is_favorite
       FROM dbo.products p
       INNER JOIN dbo.users u ON u.id = p.user_id
       INNER JOIN dbo.categories c ON c.id = p.category_id
       WHERE p.id = @id
         AND (
           p.[status] IN ('approved', 'sold')
           OR p.user_id = @currentUserId
           OR @isAdmin = 1
         )`,
      {
        id: productId,
        currentUserId,
        isAdmin
      }
    );

    if (!productResult.recordset.length) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const imagesResult = await query(
      `SELECT image_url
       FROM dbo.product_images
       WHERE product_id = @id
       ORDER BY id ASC`,
      { id: productId }
    );

    const p = productResult.recordset[0];

    return res.json({
      product: {
        id: p.id,
        user_id: p.user_id,
        category_id: p.category_id,
        title: p.title,
        description: p.description,
        price: Number(p.price),
        status: p.status,
        created_at: p.created_at,
        user: {
          id: p.seller_id,
          name: p.seller_name,
          email: p.seller_email,
          phone: p.seller_phone,
          address: p.seller_address,
          avatar: p.seller_avatar
        },
        category: {
          id: p.category_id_ref,
          name: p.category_name,
          icon: p.category_icon
        },
        images: imagesResult.recordset,
        is_favorite: Boolean(p.is_favorite)
      }
    });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load product detail', error: error.message });
  }
}

async function getPendingProducts(req, res) {
  try {
    const productsResult = await query(
      `SELECT
          p.id,
          p.user_id,
          p.category_id,
          p.title,
          p.[description],
          p.price,
          p.[status],
          p.created_at,
          u.id AS seller_id,
          u.name AS seller_name,
          u.email AS seller_email,
          u.phone AS seller_phone,
          u.[address] AS seller_address,
          c.id AS category_id_ref,
          c.name AS category_name,
          c.icon AS category_icon
       FROM dbo.products p
       INNER JOIN dbo.users u ON u.id = p.user_id
       INNER JOIN dbo.categories c ON c.id = p.category_id
       WHERE p.[status] = 'pending'
       ORDER BY p.created_at DESC`
    );

    const products = productsResult.recordset;
    if (!products.length) {
      return res.json({ data: [] });
    }

    const productIdsCsv = products.map((p) => p.id).join(',');
    const imagesResult = await query(
      `SELECT product_id, image_url
       FROM dbo.product_images
       WHERE product_id IN (${productIdsCsv})
       ORDER BY id ASC`
    );

    const imagesByProduct = imagesResult.recordset.reduce((acc, item) => {
      if (!acc[item.product_id]) acc[item.product_id] = [];
      acc[item.product_id].push({ image_url: item.image_url });
      return acc;
    }, {});

    return res.json({
      data: products.map((p) => ({
        id: p.id,
        user_id: p.user_id,
        category_id: p.category_id,
        title: p.title,
        description: p.description,
        price: Number(p.price),
        status: p.status,
        created_at: p.created_at,
        user: {
          id: p.seller_id,
          name: p.seller_name,
          email: p.seller_email,
          phone: p.seller_phone,
          address: p.seller_address
        },
        category: {
          id: p.category_id_ref,
          name: p.category_name,
          icon: p.category_icon
        },
        images: imagesByProduct[p.id] || []
      }))
    });
  } catch (error) {
    return res.status(500).json({ message: 'Cannot load pending products', error: error.message });
  }
}

async function updateProductStatus(req, res) {
  try {
    const productId = Number(req.params.id);
    const status = String(req.body.status || '').toLowerCase().trim();

    if (!productId) {
      return res.status(400).json({ message: 'Invalid product id' });
    }

    if (!['approved', 'rejected', 'sold', 'pending'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status value' });
    }

    const updated = await query(
      `UPDATE dbo.products
       SET [status] = @status,
           updated_at = SYSUTCDATETIME()
       OUTPUT INSERTED.id, INSERTED.user_id, INSERTED.category_id, INSERTED.title,
              INSERTED.[description], INSERTED.price, INSERTED.[status], INSERTED.created_at
       WHERE id = @id`,
      { id: productId, status }
    );

    if (!updated.recordset.length) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const product = updated.recordset[0];

    if (status === 'approved' || status === 'rejected' || status === 'sold') {
      const title = status === 'approved'
        ? 'Bai dang da duoc duyet'
        : status === 'rejected'
          ? 'Bai dang bi tu choi'
          : 'Bai dang da duoc cap nhat';

      const content = status === 'approved'
        ? `San pham "${product.title}" cua ban da duoc duyet va hien thi tren he thong.`
        : status === 'rejected'
          ? `San pham "${product.title}" cua ban da bi tu choi. Vui long kiem tra lai noi dung.`
          : `Trang thai san pham "${product.title}" cua ban da duoc cap nhat thanh ${status}.`;

      await query(
        `INSERT INTO dbo.notifications (user_id, title, content, is_read)
         VALUES (@user_id, @title, @content, 0)`,
        {
          user_id: product.user_id,
          title,
          content
        }
      );
    }

    return res.json({
      message: 'Product status updated',
      product: {
        ...product,
        price: Number(product.price)
      }
    });
  } catch (error) {
    return res.status(500).json({ message: 'Update status failed', error: error.message });
  }
}

module.exports = {
  getProducts,
  getProduct,
  createProduct,
  getMyProducts,
  getPendingProducts,
  updateProductStatus
};
