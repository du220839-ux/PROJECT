class ReviewModel {
  final int id;
  final int productId;
  final int reviewerId;
  final int sellerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerAvatar;
  final String? productTitle;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.reviewerId,
    required this.sellerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatar,
    this.productTitle,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productId: json['product_id'],
      reviewerId: json['reviewer_id'],
      sellerId: json['seller_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      reviewerName: json['reviewer_name'],
      reviewerAvatar: json['reviewer_avatar'],
      productTitle: json['product_title'],
    );
  }
}

class ReviewSummary {
  final int totalReviews;
  final double averageRating;

  ReviewSummary({required this.totalReviews, required this.averageRating});

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      totalReviews: json['total_reviews'] ?? 0,
      averageRating: double.tryParse(json['average_rating'].toString()) ?? 0,
    );
  }
}
