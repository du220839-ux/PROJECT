const cron = require('node-cron');
const { autoCompleteOrders } = require('../controllers/orderController');

// Chạy mỗi giờ để kiểm tra các đơn hàng cần tự động hoàn tất
cron.schedule('0 * * * *', async () => {
  console.log('Running auto-complete orders job...');
  await autoCompleteOrders();
  console.log('Auto-complete orders job completed');
});

console.log('Auto-complete orders cron job scheduled to run every hour');
