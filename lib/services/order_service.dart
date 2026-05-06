import 'package:secondhand_app/models/order_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class OrderService {
  final ApiService _api = ApiService();

  // Tạo đơn hàng mới
  Future<Map<String, dynamic>> createOrder({
    required int buyerId,
    required int sellerId,
    required int productId,
    required double totalPrice,
    String? shippingAddress,
    double shippingFee = 0.0,
  }) async {
    final response = await _api.post('/orders', data: {
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'total_price': totalPrice,
      'shipping_address': shippingAddress,
      'shipping_fee': shippingFee,
    });
    return response.data;
  }

  // Thanh toán đơn hàng bằng ví
  Future<Map<String, dynamic>> payWithWallet({
    required int orderId,
    required double amount,
  }) async {
    final response = await _api.post('/orders/pay-wallet', data: {
      'order_id': orderId,
      'amount': amount,
    });
    return response.data;
  }

  // Tạo đơn hàng và thanh toán bằng ví trong 1 bước
  Future<Map<String, dynamic>> createOrderAndPayWithWallet({
    required int productId,
    required double totalPrice,
    String? shippingAddress,
    double shippingFee = 0.0,
  }) async {
    final response = await _api.post('/orders/create-pay-wallet', data: {
      'product_id': productId,
      'total_price': totalPrice,
      'shipping_address': shippingAddress,
      'shipping_fee': shippingFee,
    });
    return response.data;
  }

  // Đánh dấu đơn hàng đã giao
  Future<Map<String, dynamic>> markAsDelivered({
    required int orderId,
  }) async {
    final response = await _api.post('/orders/delivered', data: {
      'order_id': orderId,
    });
    return response.data;
  }

  // Tạo khiếu nại
  Future<Map<String, dynamic>> createDispute({
    required int orderId,
    required int complainantId,
    required String reason,
    List<String>? evidenceImages,
  }) async {
    final response = await _api.post('/orders/dispute', data: {
      'order_id': orderId,
      'complainant_id': complainantId,
      'reason': reason,
      'evidence_images': evidenceImages,
    });
    return response.data;
  }

  // Xử lý hoàn tiền
  Future<Map<String, dynamic>> processRefund({
    required int orderId,
    required int adminId,
    required String resolution,
  }) async {
    final response = await _api.post('/orders/refund', data: {
      'order_id': orderId,
      'admin_id': adminId,
      'resolution': resolution,
    });
    return response.data;
  }

  // Hoàn tất đơn hàng
  Future<Map<String, dynamic>> completeOrder({
    required int orderId,
  }) async {
    final response = await _api.post('/orders/complete', data: {
      'order_id': orderId,
    });
    return response.data;
  }

  // Lấy danh sách đơn hàng của user
  Future<List<OrderModel>> getUserOrders({int page = 1, int limit = 20}) async {
    final response = await _api.get('/orders/user/current_user');
    final List<dynamic> ordersJson = response.data['orders'];
    return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
  }

  // Lấy chi tiết đơn hàng
  Future<OrderModel> getOrderDetail(int orderId) async {
    final response = await _api.get('/orders/$orderId');
    final orderJson = response.data['order'];
    return OrderModel.fromJson(orderJson);
  }
}
