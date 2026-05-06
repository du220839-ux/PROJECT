import 'package:flutter/material.dart';
import 'package:secondhand_app/config/theme.dart';
import 'dart:io';

class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  String _severity = 'medium';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _submitBugReport() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _stepsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Gửi bug report tới backend
      final bugReport = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'steps': _stepsController.text,
        'severity': _severity,
        'timestamp': DateTime.now(),
        'device': '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      };

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Báo cáo lỗi đã được gửi. Cảm ơn bạn đã giúp chúng tôi!'),
          backgroundColor: Colors.green,
        ),
      );

      _titleController.clear();
      _descriptionController.clear();
      _stepsController.clear();
      _severity = 'medium';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Giúp chúng tôi cải thiện ứng dụng bằng cách báo cáo chi tiết các lỗi bạn gặp phải.',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Mô tả lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Tiêu đề lỗi',
              hintText: 'VD: Không thể nạp tiền vào ví',
              prefixIcon: Icon(Icons.bug_report),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Mô tả chi tiết',
              hintText: 'Mô tả lỗi xảy ra như thế nào...',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _stepsController,
            decoration: const InputDecoration(
              labelText: 'Các bước tái tạo lỗi',
              hintText: '1. Bước 1\n2. Bước 2\n3. Bước 3',
              prefixIcon: Icon(Icons.format_list_numbered),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          const Text('Mức độ nghiêm trọng', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SeverityChip(
                  label: 'Thấp',
                  value: 'low',
                  selected: _severity == 'low',
                  color: Colors.blue,
                  onTap: () => setState(() => _severity = 'low'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SeverityChip(
                  label: 'Trung bình',
                  value: 'medium',
                  selected: _severity == 'medium',
                  color: Colors.orange,
                  onTap: () => setState(() => _severity = 'medium'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SeverityChip(
                  label: 'Cao',
                  value: 'high',
                  selected: _severity == 'high',
                  color: Colors.red,
                  onTap: () => setState(() => _severity = 'high'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitBugReport,
              icon: _isLoading ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ) : const Icon(Icons.send),
              label: Text(_isLoading ? 'Đang gửi...' : 'Gửi báo cáo'),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 Lưu ý',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),
                const Text('• Cung cấp nhiều chi tiết càng tốt để giúp chúng tôi sửa lỗi nhanh hơn'),
                const Text('• Tránh báo cáo lỗi trùng lặp - tìm kiếm lỗi trước khi báo cáo'),
                const Text('• Bạn sẽ nhận được email thông báo khi lỗi được sửa'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SeverityChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: color.withOpacity(0.3),
      side: BorderSide(
        color: selected ? color : Colors.grey[300]!,
        width: selected ? 2 : 1,
      ),
    );
  }
}
