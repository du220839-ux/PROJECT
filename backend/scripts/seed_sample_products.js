const { query } = require('../src/config/db');

const titlePool = [
  'iPhone 12 128GB',
  'Samsung Galaxy S21',
  'Xiaomi 11T Pro',
  'MacBook Pro 2019',
  'Dell XPS 13',
  'HP Envy 14',
  'AirPods Pro 2',
  'Sony WH-1000XM4',
  'Mechanical Keyboard',
  'Gaming Mouse',
  'Road Bike Giant',
  'Honda Vision 2021',
  'Levis Denim Jacket',
  'Nike Air Force 1',
  'Wooden Study Desk',
  'Ergonomic Chair',
  'Clean Code Book Set',
  'Nintendo Switch Lite',
  'PS4 Slim 500GB',
  'Blender Philips',
  'Rice Cooker Sharp',
  'Coffee Maker Delonghi',
  'Canon EOS M50',
  'GoPro Hero 9',
  'iPad Air 4',
  'Kindle Paperwhite',
  'Monitor LG 24 inch',
  'Smart TV Samsung 43',
  'Office Backpack',
  'Table Lamp Minimal'
];

const descriptions = [
  'Used carefully, all functions work well, minor scratches only.',
  'Good condition, battery and screen are stable, includes charger.',
  'Selling because of upgrade, device has been factory reset.',
  'Works perfectly, no repair history, can test before buying.',
  'Price is negotiable for quick deal, serious buyers only.'
];

const imageGroups = [
  [
    'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1400',
    'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1400'
  ],
  [
    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=1400',
    'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1400'
  ],
  [
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1400',
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1400'
  ],
  [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1400',
    'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=1400'
  ],
  [
    'https://images.unsplash.com/photo-1518444065439-e933c06ce9cd?w=1400',
    'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1400'
  ],
  [
    'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=1400',
    'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=1400'
  ]
];

function randomPick(arr, index) {
  return arr[index % arr.length];
}

async function main() {
  const userResult = await query(`
    SELECT TOP 20 id
    FROM dbo.users
    ORDER BY id ASC
  `);

  const categoryResult = await query(`
    SELECT id
    FROM dbo.categories
    ORDER BY id ASC
  `);

  const userIds = userResult.recordset.map((r) => Number(r.id));
  const categoryIds = categoryResult.recordset.map((r) => Number(r.id));

  if (!userIds.length) {
    throw new Error('No users found. Cannot seed sample products.');
  }

  if (!categoryIds.length) {
    throw new Error('No categories found. Cannot seed sample products.');
  }

  let insertedProducts = 0;
  let insertedImages = 0;

  for (let i = 0; i < 24; i++) {
    const userId = randomPick(userIds, i);
    const categoryId = randomPick(categoryIds, i + 3);
    const title = `${randomPick(titlePool, i)} #${Date.now().toString().slice(-6)}-${i + 1}`;
    const description = randomPick(descriptions, i);
    const price = 150000 + (i * 85000);

    const inserted = await query(
      `INSERT INTO dbo.products (user_id, category_id, title, [description], price, [status])
       OUTPUT INSERTED.id
       VALUES (@user_id, @category_id, @title, @description, @price, 'approved')`,
      {
        user_id: userId,
        category_id: categoryId,
        title,
        description,
        price
      }
    );

    const productId = Number(inserted.recordset[0].id);
    insertedProducts += 1;

    const images = randomPick(imageGroups, i);
    for (const imageUrl of images) {
      await query(
        `INSERT INTO dbo.product_images (product_id, image_url)
         VALUES (@product_id, @image_url)`,
        {
          product_id: productId,
          image_url: imageUrl
        }
      );
      insertedImages += 1;
    }
  }

  const count = await query(`
    SELECT COUNT(*) AS approved_count
    FROM dbo.products
    WHERE [status] = 'approved'
  `);

  console.log(
    JSON.stringify({
      message: 'seed-sample-products-ok',
      inserted_products: insertedProducts,
      inserted_images: insertedImages,
      approved_total: Number(count.recordset[0].approved_count)
    })
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error.message);
    process.exit(1);
  });
