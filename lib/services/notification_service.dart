import 'package:secondhand_app/models/notification_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _api.get('/notifications');
    final List data = response.data['data'] ?? const [];
    return {
      'data': data.map((e) => NotificationModel.fromJson(e)).toList(),
      'unread_count': response.data['unread_count'] ?? 0,
    };
  }

  Future<NotificationModel> markRead(int id) async {
    final response = await _api.patch('/notifications/$id/read');
    return NotificationModel.fromJson(response.data['notification']);
  }

  Future<void> markAllRead() async {
    await _api.patch('/notifications/read-all');
  }
}
