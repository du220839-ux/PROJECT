import 'package:secondhand_app/models/review_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class ReviewService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getSellerReviews(int sellerId) async {
    final response = await _api.get('/reviews/seller/$sellerId');
    final List data = response.data['data'] ?? const [];
    return {
      'summary': ReviewSummary.fromJson(response.data['summary'] ?? {}),
      'data': data.map((e) => ReviewModel.fromJson(e)).toList(),
    };
  }

  Future<ReviewModel> createReview({
    required int productId,
    required int sellerId,
    required int rating,
    String? comment,
  }) async {
    final response = await _api.post('/reviews', data: {
      'product_id': productId,
      'seller_id': sellerId,
      'rating': rating,
      'comment': comment,
    });
    return ReviewModel.fromJson(response.data['review']);
  }
}
