import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:secondhand_app/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  List<Map<String, dynamic>> _banks = [];
  Map<String, dynamic>? _linkedAccount;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get banks => _banks;
  Map<String, dynamic>? get linkedAccount => _linkedAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _banks = await _service.getBanks();
    } catch (e) {
      _error = 'Không tải được danh sách ngân hàng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLinkedBankAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _linkedAccount = await _service.getMyBankAccount();
    } catch (e) {
      _error = 'Không tải được tài khoản ngân hàng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> linkBankAccount({
    required int bankId,
    required String accountNumber,
    required String accountName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _linkedAccount = await _service.linkBankAccount(
        bankId: bankId,
        accountNumber: accountNumber,
        accountName: accountName,
      );
      return true;
    } catch (e) {
      _error = 'Liên kết ngân hàng thất bại';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createPayment({
    required int productId,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await _service.createPayment(
        productId: productId,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      if (e is DioError) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          _error = 'Tạo thanh toán thất bại: ${data['message']}';
        } else {
          _error = 'Tạo thanh toán thất bại: ${e.message}';
        }
      } else {
        _error = 'Tạo thanh toán thất bại: ${e.toString()}';
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> markPaymentSuccess({
    required int paymentId,
    required int productId,
    String? shippingAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await _service.markPaymentSuccess(
        paymentId: paymentId,
        productId: productId,
        shippingAddress: shippingAddress,
      );
    } catch (e) {
      if (e is DioError) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          _error = 'Xử lý thanh toán thất bại: ${data['message']}';
        } else {
          _error = 'Xử lý thanh toán thất bại: ${e.message}';
        }
      } else {
        _error = 'Xử lý thanh toán thất bại: ${e.toString()}';
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
