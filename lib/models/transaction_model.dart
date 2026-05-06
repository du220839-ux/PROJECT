enum TransactionStatus { pending, completed, cancelled }

class TransactionModel {
  final int id;
  final int productId;
  final int buyerId;
  final int sellerId;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final String productTitle;
  final double productPrice;
  final String productStatus;
  final String? productImage;
  final String? buyerName;
  final String? sellerName;

  const TransactionModel({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    required this.productTitle,
    required this.productPrice,
    required this.productStatus,
    this.productImage,
    this.buyerName,
    this.sellerName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      productId: json['product_id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'])
          : null,
      productTitle: json['product_title'] ?? '',
      productPrice: double.tryParse((json['product_price'] ?? 0).toString()) ?? 0,
      productStatus: (json['product_status'] ?? '').toString(),
      productImage: json['product_image']?.toString(),
      buyerName: json['buyer_name']?.toString(),
      sellerName: json['seller_name']?.toString(),
    );
  }

  static TransactionStatus _parseStatus(dynamic raw) {
    switch ((raw ?? '').toString().toLowerCase()) {
      case 'completed':
        return TransactionStatus.completed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.completed:
        return 'Hoàn tất';
      case TransactionStatus.cancelled:
        return 'Đã hủy';
      default:
        return 'Chờ xác nhận';
    }
  }
}
