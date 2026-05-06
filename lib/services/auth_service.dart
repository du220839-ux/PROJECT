import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secondhand_app/config/app_config.dart';
import 'package:secondhand_app/models/user_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> registerAccount({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (phone != null) 'phone': phone,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data;
    if (data['token'] != null) {
      await _saveToken(data['token']);
      await _saveUser(UserModel.fromJson(data['user']));
    }
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (phone != null) 'phone': phone,
    });
    final data = response.data;
    if (data['token'] != null) {
      await _saveToken(data['token']);
      await _saveUser(UserModel.fromJson(data['user']));
    }
    return data;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConfig.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<UserModel?> checkUserExists(String email) async {
    try {
      final response = await _api.post('/auth/check-user', data: {
        'email': email,
      });
      
      if (response.data['user'] != null) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      // If endpoint doesn't exist, assume user doesn't exist
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<UserModel> getProfile() async {
    final response = await _api.get('/auth/profile');
    return UserModel.fromJson(response.data['user']);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final response = await _api.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    });

    final user = UserModel.fromJson(response.data['user']);
    await _saveUser(user);
    return user;
  }

  Future<void> saveStoredUser(UserModel user) async {
    await _saveUser(user);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
  }

  /// Sign in with Google using Firebase ID token
  Future<Map<String, dynamic>> signInWithGoogle({
    required String idToken,
    String? displayName,
  }) async {
    final response = await _api.post('/oauth/google', data: {
      'idToken': idToken,
      if (displayName != null) 'displayName': displayName,
    });
    
    final data = response.data;
    if (data['token'] != null) {
      await _saveToken(data['token']);
      await _saveUser(UserModel.fromJson(data['user']));
    }
    return data;
  }

  /// Sign in with Facebook using Firebase ID token
  Future<Map<String, dynamic>> signInWithFacebook({
    required String idToken,
    String? displayName,
  }) async {
    final response = await _api.post('/oauth/facebook', data: {
      'idToken': idToken,
      if (displayName != null) 'displayName': displayName,
    });
    
    final data = response.data;
    if (data['token'] != null) {
      await _saveToken(data['token']);
      await _saveUser(UserModel.fromJson(data['user']));
    }
    return data;
  }
}
