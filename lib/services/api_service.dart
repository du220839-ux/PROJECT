import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secondhand_app/config/app_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    init();
  }

  late final Dio _dio;
  bool _initialized = false;
  GoogleSignIn? _googleSignIn; // Cache GoogleSignIn instance

  void init() {
    if (_initialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ));

    // Initialize GoogleSignIn with clientId
    _googleSignIn = GoogleSignIn(
      clientId: '256558197701-1f6d9k3s4l5m7n8o0p2q4r6t8v0x2z4y.apps.googleusercontent.com',
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConfig.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));

    _initialized = true;
  }

  /// Đăng nhập bằng Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Use cached instance
      final GoogleSignIn googleSignIn = _googleSignIn ?? GoogleSignIn();
      
      // Try sign in silently first (recommended for web)
      GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
      
      // If silent sign in fails, try interactive sign in
      if (googleUser == null) {
        googleUser = await googleSignIn.signIn();
      }
      
      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return null;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In error: $e');
      // If popup_closed error, try again with renderButton approach
      if (e.toString().contains('popup_closed')) {
        print('Popup was closed, trying alternative method...');
        // For now, return null to avoid infinite loop
        return null;
      }
      return null;
    }
  }

  /// Đăng nhập bằng Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);
        final userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        return userCredential;
      } else {
        print('Facebook Sign-In failed: ${result.status}');
        return null;
      }
    } catch (e) {
      print('Facebook Sign-In error: $e');
      return null;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) init();
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    _ensureInitialized();
    return await _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    _ensureInitialized();
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    _ensureInitialized();
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    _ensureInitialized();
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    _ensureInitialized();
    return await _dio.delete(path);
  }

  Future<Response> postFormData(String path, FormData formData) async {
    _ensureInitialized();
    return await _dio.post(path, data: formData);
  }

  Future<Response> putFormData(String path, FormData formData) async {
    _ensureInitialized();
    return await _dio.put(path, data: formData);
  }
}

