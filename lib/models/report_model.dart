class ReportModel {
  final int id;
  final int? productId;
  final int? reporterId;
  final String reason;
  final String status;
  final DateTime createdAt;
  final String? productTitle;
  final String? reporterName;
  final String? reporterEmail;

  ReportModel({
    required this.id,
    this.productId,
    this.reporterId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.productTitle,
    this.reporterName,
    this.reporterEmail,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      productId: json['product_id'],
      reporterId: json['reporter_id'],
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      productTitle: json['product_title'],
      reporterName: json['reporter_name'],
      reporterEmail: json['reporter_email'],
    );
  }
}
