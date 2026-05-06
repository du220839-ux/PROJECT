import 'package:secondhand_app/models/report_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class ReportService {
  final ApiService _api = ApiService();

  Future<ReportModel> createReport({
    required int productId,
    required String reason,
  }) async {
    final response = await _api.post('/reports', data: {
      'product_id': productId,
      'reason': reason,
    });
    return ReportModel.fromJson(response.data['report']);
  }

  Future<List<ReportModel>> getReports() async {
    final response = await _api.get('/reports');
    final List data = response.data['data'] ?? const [];
    return data.map((e) => ReportModel.fromJson(e)).toList();
  }

  Future<ReportModel> updateReportStatus({
    required int id,
    required String status,
  }) async {
    final response = await _api.patch('/reports/$id/status', data: {
      'status': status,
    });
    return ReportModel.fromJson(response.data['report']);
  }
}
