import 'package:flutter/material.dart';
import 'package:secondhand_app/models/report_model.dart';
import 'package:secondhand_app/models/review_model.dart';
import 'package:secondhand_app/services/report_service.dart';
import 'package:secondhand_app/services/review_service.dart';

class CommunityProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  final ReportService _reportService = ReportService();

  List<ReviewModel> _sellerReviews = [];
  ReviewSummary _reviewSummary = ReviewSummary(totalReviews: 0, averageRating: 0);
  List<ReportModel> _reports = [];
  bool _isLoading = false;

  List<ReviewModel> get sellerReviews => _sellerReviews;
  ReviewSummary get reviewSummary => _reviewSummary;
  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> loadSellerReviews(int sellerId) async {
    _isLoading = true;
    _sellerReviews = [];
    _reviewSummary = ReviewSummary(totalReviews: 0, averageRating: 0);
    notifyListeners();
    try {
      final result = await _reviewService.getSellerReviews(sellerId);
      _reviewSummary = result['summary'] as ReviewSummary;
      _sellerReviews = List<ReviewModel>.from(result['data']);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createReview({
    required int productId,
    required int sellerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final review = await _reviewService.createReview(
        productId: productId,
        sellerId: sellerId,
        rating: rating,
        comment: comment,
      );
      _sellerReviews.insert(0, review);
      _reviewSummary = ReviewSummary(
        totalReviews: _reviewSummary.totalReviews + 1,
        averageRating: _reviewSummary.totalReviews == 0
            ? rating.toDouble()
            : ((_reviewSummary.averageRating * _reviewSummary.totalReviews) + rating) /
                (_reviewSummary.totalReviews + 1),
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createReport({
    required int productId,
    required String reason,
  }) async {
    try {
      final report = await _reportService.createReport(productId: productId, reason: reason);
      _reports.insert(0, report);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reports = await _reportService.getReports();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateReportStatus({required int id, required String status}) async {
    try {
      final updated = await _reportService.updateReportStatus(id: id, status: status);
      final index = _reports.indexWhere((r) => r.id == id);
      if (index != -1) _reports[index] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
