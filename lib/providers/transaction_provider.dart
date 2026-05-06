import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:secondhand_app/models/transaction_model.dart';
import 'package:secondhand_app/services/transaction_service.dart';
import 'package:secondhand_app/services/wallet_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();
  final WalletService _walletService = WalletService();

  List<TransactionModel> _buying = [];
  List<TransactionModel> _selling = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get buying => _buying;
  List<TransactionModel> get selling => _selling;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBuying() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _buying = await _service.getBuyingTransactions();
    } catch (e) {
      _error = 'Không thể tải giao dịch mua';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSelling() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selling = await _service.getSellingTransactions();
    } catch (e) {
      _error = 'Không thể tải giao dịch bán';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction(
    int productId, {
    String paymentMethod = 'WALLET',
    String? shippingAddress,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createTransaction(
        productId: productId,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
      );
      _isLoading = false;
      await loadBuying();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e is DioError) {
        final data = e.response?.data;
        final status = e.response?.statusCode;
        final serverMessage = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : null;
        final serverError = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : null;

        var errorText =
            'Tạo giao dịch thất bại${status != null ? ' ($status)' : ''}: ${serverMessage ?? e.message}';
        
        // Show wallet balance details if available
        if (data is Map && data['shortfall'] != null) {
          final shortfall = data['shortfall'];
          errorText += '\n\nThiếu: ${shortfall.toStringAsFixed(0)} ₫';
        }
        
        if (serverError != null) {
          errorText += '\nChi tiết: $serverError';
        }
        if (data is Map && data['stack'] != null) {
          final stack = data['stack'].toString();
          errorText += '\nStack: $stack';
        }
        _error = errorText;
      } else {
        _error = 'Tạo giao dịch thất bại: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmTransaction(int transactionId) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _service.confirmTransaction(transactionId);
      
      // Reload transactions
      await Future.wait([loadSelling(), loadBuying()]);
      
      // Refresh wallet balance after transaction
      try {
        await _walletService.getWallet();
      } catch (walletError) {
        // Wallet refresh error is not critical, continue
        print('Wallet refresh warning: $walletError');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e is DioError) {
        final data = e.response?.data;
        final status = e.response?.statusCode;
        final serverMessage = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : null;
        final serverError = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : null;

        var errorText =
            'Xác nhận giao dịch thất bại${status != null ? ' ($status)' : ''}: ${serverMessage ?? e.message}';
        if (serverError != null) {
          errorText += '\nChi tiết: $serverError';
        }
        _error = errorText;
      } else {
        _error = 'Xác nhận giao dịch thất bại: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectTransaction(int transactionId, {String? reason}) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _service.rejectTransaction(transactionId, reason: reason);
      
      // Reload transactions
      await Future.wait([loadSelling(), loadBuying()]);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      if (e is DioError) {
        final data = e.response?.data;
        final status = e.response?.statusCode;
        final serverMessage = (data is Map && data['message'] != null)
            ? data['message'].toString()
            : null;
        final serverError = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : null;

        var errorText =
            'Từ chối giao dịch thất bại${status != null ? ' ($status)' : ''}: ${serverMessage ?? e.message}';
        if (serverError != null) {
          errorText += '\nChi tiết: $serverError';
        }
        _error = errorText;
      } else {
        _error = 'Từ chối giao dịch thất bại: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }
}
