import 'package:secondhand_app/models/user_model.dart';
import 'package:secondhand_app/models/category_model.dart';

enum ProductStatus { pending, approved, rejected, sold }

class ProductModel {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final double price;
  final ProductStatus status;
  final DateTime createdAt;
  final UserModel? seller;
  final CategoryModel? category;
  final List<String> images;
  final String? location; // Địa chỉ sản phẩm
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    this.status = ProductStatus.pending,
    required this.createdAt,
    this.seller,
    this.category,
    this.images = const [],
    this.location,
    this.isFavorite = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      seller: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      images: _parseImages(json['images']),
      location: json['location'],
      isFavorite: (json['is_favorite'] is bool ? json['is_favorite'] : (json['is_favorite'] == 1 || json['is_favorite'] == '1')) ?? false,
    );
  }

  static ProductStatus _parseStatus(dynamic status) {
    switch (status) {
      case 'approved': return ProductStatus.approved;
      case 'rejected': return ProductStatus.rejected;
      case 'sold': return ProductStatus.sold;
      default: return ProductStatus.pending;
    }
  }

  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];
    if (images is List) return images.map((e) => e['image_url']?.toString() ?? '').toList();
    return [];
  }

  String get statusLabel {
    switch (status) {
      case ProductStatus.approved: return 'Đang bán';
      case ProductStatus.rejected: return 'Từ chối';
      case ProductStatus.sold: return 'Đã bán';
      default: return 'Chờ duyệt';
    }
  }

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'category_id': categoryId,
    'title': title,
    'description': description,
    'price': price,
    'status': status.name,
    'location': location,
    'created_at': createdAt.toIso8601String(),
  };
}
