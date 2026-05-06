class WalletModel {
  final int userId;
  final String name;
  final String email;
  final double walletBalance;
  final double pendingBalance;
  final double totalBalance;
  final DateTime createdAt;

  WalletModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.walletBalance,
    required this.pendingBalance,
    required this.totalBalance,
    required this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      pendingBalance: (json['pending_balance'] ?? 0).toDouble(),
      totalBalance: (json['total_balance'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'wallet_balance': walletBalance,
      'pending_balance': pendingBalance,
      'total_balance': totalBalance,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TransactionModel {
  final int transactionId;
  final int? orderId;
  final int userId;
  final double amount;
  final String type; // TOPUP, WITHDRAW, TRANSFER_IN, TRANSFER_OUT, PAYMENT, REFUND, PAYOUT
  final String status; // PENDING, SUCCESS, FAILED
  final String? paymentMethod;
  final String? paymentReference;
  final String? productName;
  final String? fromUserName;
  final String? toUserName;
  final DateTime createdAt;

  TransactionModel({
    required this.transactionId,
    this.orderId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.paymentMethod,
    this.paymentReference,
    this.productName,
    this.fromUserName,
    this.toUserName,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] ?? 0,
      orderId: json['order_id'],
      userId: json['user_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      productName: json['product_name'],
      fromUserName: json['from_user_name'],
      toUserName: json['to_user_name'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'product_name': productName,
      'from_user_name': fromUserName,
      'to_user_name': toUserName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isTopUp => type == 'TOPUP';
  bool get isWithdraw => type == 'WITHDRAW';
  bool get isTransferIn => type == 'TRANSFER_IN';
  bool get isTransferOut => type == 'TRANSFER_OUT';
  bool get isPayment => type == 'PAYMENT';
  bool get isRefund => type == 'REFUND';
  bool get isPayout => type == 'PAYOUT';
  bool get isSuccess => status == 'SUCCESS';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';

  String get displayType {
    switch (type) {
      case 'TOPUP':
        return 'Nạp tiền';
      case 'WITHDRAW':
        return 'Rút tiền';
      case 'TRANSFER_IN':
        return 'Nhận chuyển tiền';
      case 'TRANSFER_OUT':
        return 'Chuyển tiền';
      case 'PAYMENT':
        return 'Thanh toán';
      case 'REFUND':
        return 'Hoàn tiền';
      case 'PAYOUT':
        return 'Nhận tiền bán hàng';
      default:
        return type;
    }
  }

  String get displayAmount {
    final sign = (isTopUp || isTransferIn || isRefund || isPayout) ? '+' : '-';
    return '$sign${amount.toStringAsFixed(0)}đ';
  }

  String get displayStatus {
    switch (status) {
      case 'SUCCESS':
        return 'Thành công';
      case 'PENDING':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      default:
        return status;
    }
  }
}
