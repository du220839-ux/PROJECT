import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/models/report_model.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/community_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedStatus = 'all';
  int? _updatingReportId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAdmin) {
        context.read<CommunityProvider>().loadReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý báo cáo')),
        body: const EmptyWidget(
          message: 'Đăng nhập bằng tài khoản admin để xem báo cáo.',
          icon: Icons.lock_outline,
        ),
      );
    }

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý báo cáo')),
        body: const EmptyWidget(
          message: 'Chỉ quản trị viên mới có quyền truy cập màn hình này.',
          icon: Icons.admin_panel_settings_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý báo cáo'),
        actions: [
          IconButton(
            onPressed: () => context.read<CommunityProvider>().loadReports(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, community, _) {
          final reports = _filterReports(community.reports);

          if (community.isLoading && community.reports.isEmpty) {
            return const LoadingWidget();
          }

          return Column(
            children: [
              _buildFilterBar(community.reports),
              Expanded(
                child: reports.isEmpty
                    ? const EmptyWidget(
                        message: 'Không có báo cáo nào khớp với bộ lọc hiện tại.',
                        icon: Icons.fact_check_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<CommunityProvider>().loadReports(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: reports.length,
                          itemBuilder: (context, index) => _buildReportCard(reports[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ReportModel> _filterReports(List<ReportModel> reports) {
    if (_selectedStatus == 'all') {
      return reports;
    }
    return reports.where((report) => report.status == _selectedStatus).toList();
  }

  Widget _buildFilterBar(List<ReportModel> allReports) {
    final statuses = ['all', 'pending', 'reviewing', 'resolved', 'rejected'];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số báo cáo: ${allReports.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_statusLabel(status)),
                    selected: _selectedStatus == status,
                    onSelected: (_) => setState(() => _selectedStatus = status),
                  ),
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final badgeColor = _statusColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.productTitle ?? 'Sản phẩm #${report.productId ?? 0}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bởi ${report.reporterName ?? 'Người dùng ẩn danh'}',
                        style: const TextStyle(color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(report.status),
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(report.reason, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if ((report.reporterEmail ?? '').isNotEmpty)
                  _MetaText(label: 'Email', value: report.reporterEmail!),
                _MetaText(label: 'Mã báo cáo', value: '#${report.id}'),
                _MetaText(
                  label: 'Thời gian',
                  value: timeago.format(report.createdAt, locale: 'vi'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (status) => _updateStatus(report, status),
                enabled: _updatingReportId != report.id,
                itemBuilder: (context) => ['pending', 'reviewing', 'resolved', 'rejected']
                    .map(
                      (status) => PopupMenuItem<String>(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(growable: false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _updatingReportId == report.id ? 'Đang cập nhật...' : 'Đổi trạng thái',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(ReportModel report, String status) async {
    setState(() => _updatingReportId = report.id);
    final success = await context.read<CommunityProvider>().updateReportStatus(
          id: report.id,
          status: status,
        );
    if (!mounted) return;
    setState(() => _updatingReportId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã cập nhật báo cáo #${report.id} sang ${_statusLabel(status)}.'
              : 'Không thể cập nhật trạng thái báo cáo.',
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'reviewing':
        return 'Đang xem xét';
      case 'resolved':
        return 'Đã xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Tất cả';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'reviewing':
        return Colors.blueAccent;
      case 'resolved':
        return AppTheme.successColor;
      case 'rejected':
        return Colors.redAccent;
      default:
        return AppTheme.textMedium;
    }
  }
}

class _MetaText extends StatelessWidget {
  final String label;
  final String value;

  const _MetaText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppTheme.textMedium, fontSize: 12),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}