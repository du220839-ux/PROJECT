class OrderModel {
  final int orderId;
  final int buyerId;
  final int sellerId;
  final int productId;
  final double totalPrice;
  final String? shippingAddress;
  final double shippingFee;
  final String status; // PENDING, PAID_HOLDING, SHIPPING, DELIVERED, COMPLETED, REFUNDING, REFUNDED
  final bool isDisputed;
  final DateTime? deliveryAt;
  final DateTime? autoCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? productName;
  final String? productImage;
  final String? buyerName;
  final String? sellerName;

  OrderModel({
    required this.orderId,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.totalPrice,
    this.shippingAddress,
    required this.shippingFee,
    required this.status,
    required this.isDisputed,
    this.deliveryAt,
    this.autoCompletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.productName,
    this.productImage,
    this.buyerName,
    this.sellerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      shippingAddress: json['shipping_address'],
      shippingFee: (json['shipping_fee'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      isDisputed: json['is_disputed'] ?? false,
      deliveryAt: json['delivery_at'] != null ? DateTime.parse(json['delivery_at']) : null,
      autoCompletedAt: json['auto_completed_at'] != null ? DateTime.parse(json['auto_completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      productName: json['product_name'],
      productImage: json['product_image'],
      buyerName: json['buyer_name'],
      sellerName: json['seller_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'product_id': productId,
      'total_price': totalPrice,
      'shipping_address': shippingAddress,
      'shipping_fee': shippingFee,
      'status': status,
      'is_disputed': isDisputed,
      'delivery_at': deliveryAt?.toIso8601String(),
      'auto_completed_at': autoCompletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product_name': productName,
      'product_image': productImage,
      'buyer_name': buyerName,
      'seller_name': sellerName,
    };
  }

  // Helper methods
  bool get isPaid => status == 'PAID_HOLDING';
  bool get isShipping => status == 'SHIPPING';
  bool get isDelivered => status == 'DELIVERED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isRefunded => status == 'REFUNDED';
  bool get isRefunding => status == 'REFUNDING';
  bool get isPending => status == 'PENDING';

  // Get remaining days for auto-completion
  int? get remainingDaysForCompletion {
    if (autoCompletedAt == null) return null;
    final now = DateTime.now();
    final difference = autoCompletedAt!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  // Check if buyer can confirm receipt early
  bool get canConfirmReceipt => isDelivered && !isCompleted && !isRefunding;

  // Check if seller can ship
  bool get canShip => isPaid && !isShipping && !isDelivered;

  // Check if buyer can request refund
  bool get canRequestRefund => isDelivered && !isCompleted && !isRefunding && !isRefunded;

  @override
  String toString() {
    return 'OrderModel(orderId: $orderId, status: $status, totalPrice: $totalPrice)';
  }
}
