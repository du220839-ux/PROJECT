import 'package:secondhand_app/services/api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> getBanks() async {
    final response = await _api.get('/payment/banks');
    final List data = response.data['data'] ?? [];
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getMyBankAccount() async {
    final response = await _api.get('/payment/bank-account');
    final account = response.data['account'];
    if (account == null) return null;
    return Map<String, dynamic>.from(account);
  }

  Future<Map<String, dynamic>> linkBankAccount({
    required int bankId,
    required String accountNumber,
    required String accountName,
  }) async {
    final response = await _api.post('/payment/bank-account', data: {
      'bank_id': bankId,
      'account_number': accountNumber,
      'account_name': accountName,
    });

    return Map<String, dynamic>.from(response.data['account']);
  }

  Future<Map<String, dynamic>> createPayment({
    required int productId,
    required String paymentMethod,
  }) async {
    final response = await _api.post('/payment/create', data: {
      'product_id': productId,
      'payment_method': paymentMethod,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> markPaymentSuccess({
    required int paymentId,
    required int productId,
    String? shippingAddress,
  }) async {
    final response = await _api.post('/payment/$paymentId/success', data: {
      'product_id': productId,
      if (shippingAddress != null && shippingAddress.isNotEmpty) 'shipping_address': shippingAddress,
    });
    return Map<String, dynamic>.from(response.data);
  }
}
