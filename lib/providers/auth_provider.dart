import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:secondhand_app/config/google_signin_config.dart';
import 'package:secondhand_app/models/user_model.dart';
import 'package:secondhand_app/services/api_service.dart';
import 'package:secondhand_app/services/auth_service.dart';
import 'package:secondhand_app/services/firebase_auth_service.dart';
import 'package:secondhand_app/services/location_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final LocationService _locationService = LocationService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  String? _pendingVerificationEmail;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Disable Google One Tap prompt on web to avoid FedCM errors
      GoogleSignInConfig.disableAutoPrompt();
      
      await FirebaseAuthService.initialize();
      await checkAuth();
    } catch (e) {
      print('Auth initialization error: $e');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  String? get pendingVerificationEmail => _pendingVerificationEmail;
  bool get isEmailVerificationEnabled => FirebaseAuthService.isConfigured;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      // First check local storage
      final user = await _authService.getStoredUser();
      final token = await _authService.getToken();
      
      if (user != null && token != null) {
        // If Firebase is configured, check verification
        if (FirebaseAuthService.isConfigured) {
          final isVerified = await _firebaseAuthService.reloadAndCheckVerification();
          if (!isVerified) {
            _status = AuthStatus.unauthenticated;
            notifyListeners();
            return;
          }
        }
        
        _user = user;
        await _normalizeLegacyGpsAddress();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    _pendingVerificationEmail = null;
    notifyListeners();
    try {
      // Try to login with backend directly
      final data = await _authService.login(email, password);
      _user = UserModel.fromJson(data['user']);
      await _syncLocationAfterLogin();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    _pendingVerificationEmail = null;
    notifyListeners();
    try {
      // Clear any existing authenticated session before starting a new registration
      await _firebaseAuthService.signOut();
      await _authService.logout();
      _user = null;

      // Always go through Firebase for registration if it's configured.
      if (isEmailVerificationEnabled) {
        await _firebaseAuthService.registerAndSendVerification(
          email: email,
          password: password,
        );
        try {
          await _authService.registerAccount(
            name: name,
            email: email,
            password: password,
            phone: phone,
          );
        } catch (e) {
          // If backend registration fails, clean up the created Firebase user.
          await _firebaseAuthService.deleteCurrentUser();
          await _firebaseAuthService.signOut();
          rethrow;
        }

        // Set pending email and force logout to require verification.
        _pendingVerificationEmail = email;
        await logout();
        _status = AuthStatus.unauthenticated;
      } else {
        // Fallback to legacy registration if Firebase is not configured.
        final data = await _authService.register(
          name: name,
          email: email,
          password: password,
          phone: phone,
        );
        _user = UserModel.fromJson(data['user']);
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    await _authService.logout();
    _user = null;
    _pendingVerificationEmail = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resendVerificationEmail() async {
    try {
      await _firebaseAuthService.resendVerificationEmail();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      final verified = await _firebaseAuthService.reloadAndCheckVerification();
      if (verified) {
        await _firebaseAuthService.signOut();
        _pendingVerificationEmail = null;
      }
      notifyListeners();
      return verified;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      // Sign in with Firebase + Google
      final credential = await _firebaseAuthService.signInWithGoogle();
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _status = AuthStatus.error;
        _error = 'Failed to sign in';
        notifyListeners();
        return false;
      }

      // Get ID token
      final idToken = await firebaseUser.getIdToken();
      
      // Send to backend for user creation/sync
      final data = await _authService.signInWithGoogle(
        idToken: idToken ?? '',
        displayName: firebaseUser.displayName,
      );

      // Update app state
      _user = UserModel.fromJson(data['user']);
      await _syncLocationAfterLogin();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      // Step 1: Sign in with Firebase to get credentials
      final credential = await _apiService.signInWithFacebook();
      if (credential == null) {
        _status = AuthStatus.error;
        _error = 'Facebook sign-in cancelled';
        notifyListeners();
        return false;
      }

      // Step 2: Get Firebase ID token
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        _status = AuthStatus.error;
        _error = 'No user from Firebase';
        notifyListeners();
        return false;
      }

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        _status = AuthStatus.error;
        _error = 'Failed to get Firebase ID token';
        notifyListeners();
        return false;
      }

      final displayName = firebaseUser.displayName;

      // Step 3: Send token to backend
      final data = await _authService.signInWithFacebook(
        idToken: idToken,
        displayName: displayName,
      );

      // Step 4: Update app state
      _user = UserModel.fromJson(data['user']);
      await _syncLocationAfterLogin();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  void updateUser(UserModel user) {
    _user = user;
    _authService.saveStoredUser(user);
    notifyListeners();
  }

  Future<void> _syncLocationAfterLogin() async {
    final currentUser = _user;
    if (currentUser == null) return;

    final locationLabel = await _locationService.getCurrentLocationLabel();
    if (locationLabel == null || locationLabel.isEmpty) return;

    try {
      final updatedUser = await _authService.updateProfile(
        name: currentUser.name,
        phone: currentUser.phone,
        address: locationLabel,
      );
      _user = updatedUser;
    } catch (_) {
      // Do not block login flow if location sync fails.
    }
  }

  Future<void> _normalizeLegacyGpsAddress() async {
    final currentUser = _user;
    if (currentUser == null) return;

    final readable =
        await _locationService.normalizeGpsAddress(currentUser.address);
    if (readable == null || readable.isEmpty) return;

    try {
      final updatedUser = await _authService.updateProfile(
        name: currentUser.name,
        phone: currentUser.phone,
        address: readable,
      );
      _user = updatedUser;
    } catch (_) {
      // Keep app usable even when profile sync fails.
    }
  }

  String _parseError(dynamic e) {
    // Log error for debugging
    print('Login Error: ${e.toString()}');
    
    // FedCM & Web-specific errors
    if (e.toString().contains('FedCM')) {
      return 'Lỗi khi đăng nhập bằng Google. Vui lòng kiểm tra kết nối mạng và thử lại.';
    }
    if (e.toString().contains('NetworkError') || e.toString().contains('Error retrieving a token')) {
      return 'Không thể kết nối đến Google. Vui lòng kiểm tra kết nối mạng.';
    }
    if (e.toString().contains('timeout')) {
      return 'Yêu cầu đăng nhập hết thời gian. Vui lòng thử lại.';
    }
    if (e.toString().contains('unknown_reason')) {
      return 'Lỗi từ Google Sign-In. Vui lòng thử lại hoặc sử dụng email/mật khẩu.';
    }
    
    // Firebase Auth errors
    if (e.toString().contains('operation-not-allowed')) {
      return 'Email/Password chưa được bật trong Firebase Authentication';
    }
    if (e.toString().contains('invalid-api-key')) {
      return 'Firebase API key không hợp lệ';
    }
    if (e.toString().contains('app-not-authorized')) {
      return 'Domain localhost chưa được cấp quyền trong Firebase';
    }
    if (e.toString().contains('network-request-failed')) {
      return 'Lỗi mạng khi kết nối Firebase';
    }
    if (e.toString().contains('email-already-in-use')) return 'Email này đã được đăng ký trên Firebase';
    if (e.toString().contains('weak-password')) return 'Mật khẩu quá yếu';
    if (e.toString().contains('invalid-email')) return 'Email không hợp lệ';
    if (e.toString().contains('user-not-found')) return 'Tài khoản không tồn tại';
    if (e.toString().contains('401')) return 'Email hoặc mật khẩu không đúng';
    if (e.toString().contains('409')) return 'Email đã tồn tại';
    if (e.toString().contains('422')) return 'Dữ liệu không hợp lệ';
    if (e.toString().contains('SocketException')) return 'Không có kết nối mạng';
    if (e.toString().contains('Invalid credentials')) return 'Email hoặc mật khẩu không đúng';
    if (e.toString().contains('Connection refused')) return 'Không thể kết nối đến server';
    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }
}
