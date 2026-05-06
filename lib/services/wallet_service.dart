import 'package:secondhand_app/models/wallet_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class WalletService {
  final ApiService _api = ApiService();

  // Lấy thông tin ví
  Future<WalletModel> getWallet() async {
    try {
      print('📡 Calling GET /wallet');
      final response = await _api.get('/wallet');
      print('✅ Wallet API response: ${response.data.keys}');
      return WalletModel.fromJson(response.data['wallet']);
    } catch (e) {
      print('❌ Get wallet error: $e');
      rethrow;
    }
  }

  // Nạp tiền vào ví
  Future<Map<String, dynamic>> topUp({
    required double amount,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    final response = await _api.post('/wallet/topup', data: {
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
    });
    return response.data;
  }

  // Rút tiền từ ví
  Future<Map<String, dynamic>> withdraw({
    required double amount,
    required int bankAccountId,
    String? withdrawReason,
  }) async {
    final response = await _api.post('/wallet/withdraw', data: {
      'amount': amount,
      'bank_account_id': bankAccountId,
      'withdraw_reason': withdrawReason,
    });
    return response.data;
  }

  // Chuyển tiền giữa các user
  Future<Map<String, dynamic>> transfer({
    required int toUserId,
    required double amount,
    String? message,
  }) async {
    final response = await _api.post('/wallet/transfer', data: {
      'to_user_id': toUserId,
      'amount': amount,
      'message': message,
    });
    return response.data;
  }

  // Lấy lịch sử giao dịch
  Future<List<TransactionModel>> getTransactions({
    required int userId,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get('/wallet/transactions/$userId', params: {
      'type': type,
      'page': page,
      'limit': limit,
    });
    
    final List<dynamic> transactionsJson = response.data['transactions'];
    return transactionsJson.map((json) => TransactionModel.fromJson(json)).toList();
  }

  // Lấy tất cả lịch sử giao dịch (kèm thông tin ví)
  Future<Map<String, dynamic>> getWalletWithTransactions() async {
    try {
      print('📡 Calling GET /wallet for wallet with transactions');
      final response = await _api.get('/wallet');
      print('✅ Wallet with transactions API response: ${response.data.keys}');
      
      final wallet = WalletModel.fromJson(response.data['wallet']);
      final List<dynamic> transactionsJson = response.data['transactions'] ?? [];
      final transactions = transactionsJson.map((json) => TransactionModel.fromJson(json)).toList();
      
      print('✅ Parsed wallet: balance=${wallet.walletBalance}');
      print('✅ Parsed transactions: ${transactions.length} items');
      
      return {
        'wallet': wallet,
        'transactions': transactions,
      };
    } catch (e) {
      print('❌ Get wallet with transactions error: $e');
      rethrow;
    }
  }

  // Liên kết ngân hàng
  Future<Map<String, dynamic>> linkBank({
    required int bankId,
    required String accountNumber,
    required String accountName,
  }) async {
    final response = await _api.post('/wallet/link-bank', data: {
      'bank_id': bankId,
      'account_number': accountNumber,
      'account_name': accountName,
    });
    return response.data;
  }

  // Lấy thông tin ngân hàng đã liên kết
  Future<Map<String, dynamic>> getLinkedBanks() async {
    final response = await _api.get('/wallet/linked-banks');
    return response.data;
  }

  // Rút tiền về ngân hàng đã liên kết
  Future<Map<String, dynamic>> withdrawToBank({
    required double amount,
    required int bankAccountId,
    String? note,
  }) async {
    final response = await _api.post('/wallet/withdraw-bank', data: {
      'amount': amount,
      'bank_account_id': bankAccountId,
      'note': note,
    });
    return response.data;
  }
}
