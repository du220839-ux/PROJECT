/// API Configuration Helper
/// Sử dụng file này để dễ dàng thay đổi API URL khi deploy
/// 
/// Các lựa chọn:
/// 1. Emulator Android: http://10.0.2.2:8000
/// 2. Physical Android Device: http://<MACHINE_IP>:8000  (thay MACHINE_IP bằng IP của máy chạy backend)
/// 3. iOS Simulator: http://127.0.0.1:8000
/// 4. iOS Physical Device: http://<MACHINE_IP>:8000
/// 5. Web: http://127.0.0.1:8000 hoặc http://localhost:8000

class ApiConfig {
  // ====== THAY ĐỔI ĐÂY ======
  // Đặt URL của backend server ở đây
  // Ví dụ: 'http://192.168.1.100:8000' cho physical device
  static const String BACKEND_URL = 'http://10.0.2.2:8000';
  // ====== HẾT ======
  
  static final String API_BASE_URL = '$BACKEND_URL/api';
  static final String WS_BASE_URL = 'ws://${BACKEND_URL.replaceFirst('http://', '')}';
  
  // Timeouts
  static const int CONNECT_TIMEOUT = 30000; // ms
  static const int RECEIVE_TIMEOUT = 30000; // ms
  
  // Cache durations
  static const int CACHE_DURATION_MINUTES = 5;
}
