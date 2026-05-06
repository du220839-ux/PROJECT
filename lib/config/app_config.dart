import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class AppConfig {
  static const String appName = 'SecondHand';
  static final String baseUrl = _resolveBaseUrl();

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static String _resolveBaseUrl() {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Điện thoại', 'icon': '📱'},
    {'id': 2, 'name': 'Laptop', 'icon': '💻'},
    {'id': 3, 'name': 'Phụ kiện công nghệ', 'icon': '🎧'},
    {'id': 4, 'name': 'Xe cộ', 'icon': '🚲'},
    {'id': 5, 'name': 'Quần áo', 'icon': '👕'},
    {'id': 6, 'name': 'Nội thất', 'icon': '🪑'},
    {'id': 7, 'name': 'Sách', 'icon': '📚'},
    {'id': 8, 'name': 'Game / Đồ giải trí', 'icon': '🎮'},
    {'id': 9, 'name': 'Đồ gia dụng', 'icon': '🏠'},
    {'id': 10, 'name': 'Khác', 'icon': '📦'},
  ];
}
