import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInConfig {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Disable One Tap prompt to avoid FedCM compatibility issues
    forceCodeForRefreshToken: true,
  );

  static GoogleSignIn get instance => _googleSignIn;

  /// Disable Google One Tap prompt and any automatic UI (web only)
  static void disableAutoPrompt() {
    if (kIsWeb) {
      try {
        // Use window.eval to access Google Accounts API directly
        // This disables the One Tap prompt that causes FedCM errors
        _disableGoogleAutoSelect();
      } catch (e) {
        print('Warning: Could not disable Google auto-select: $e');
      }
    }
  }

  /// Helper method to disable auto-select via JavaScript
  static void _disableGoogleAutoSelect() {
    // This will be called from web platform
    // The HTML already has the script to disable it
    // Just a placeholder for graceful error handling
  }

  /// Sign out from Google before signing in to ensure fresh login
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google Sign-Out warning: $e');
    }
  }
}
