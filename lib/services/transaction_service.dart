import 'package:secondhand_app/models/transaction_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class TransactionService {
  final ApiService _api = ApiService();

  Future<void> createTransaction({
    required int productId,
    String paymentMethod = 'WALLET',
    String? shippingAddress,
  }) async {
    final data = {
      'product_id': productId,
      'payment_method': paymentMethod,
      if (shippingAddress != null && shippingAddress.isNotEmpty)
        'shipping_address': shippingAddress,
    };
    await _api.post('/transactions', data: data);
  }

  Future<List<TransactionModel>> getBuyingTransactions() async {
    final response = await _api.get('/transactions/buying');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<List<TransactionModel>> getSellingTransactions() async {
    final response = await _api.get('/transactions/selling');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<void> confirmTransaction(int transactionId) async {
    await _api.patch('/transactions/$transactionId/confirm');
  }

  Future<void> rejectTransaction(int transactionId, {String? reason}) async {
    await _api.patch('/transactions/$transactionId/reject', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }
}
