import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  static const String _clientId = '798316641403-q3d6mau7ql3rn9e5sd03j3gqn1fh7bro.apps.googleusercontent.com';
  static bool _initialized = false;

  /// Initialize Google Identity Services
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Create script tag for Google Identity Services
      if (html.document.querySelector('#g_id_onload') == null) {
        final script = html.ScriptElement()
          ..src = 'https://accounts.google.com/gsi/client'
          ..async = true
          ..defer = true;
        html.document.head!.append(script);
        
        // Wait for script to load
        await Future.delayed(const Duration(seconds: 2));
      }
      _initialized = true;
    } catch (e) {
      print('Failed to initialize Google Auth Service: $e');
    }
  }

  /// Sign in with Google using token client
  static Future<String?> signInWithGoogle() async {
    try {
      final Completer<String?> completer = Completer<String?>();
      
      try {
        // Access the global Google object
        final gsi = js.context['google'];
        if (gsi == null) {
          throw Exception('Google Identity Services not loaded');
        }
        
        final accounts = gsi['accounts'];
        if (accounts == null) {
          throw Exception('Google accounts library not available');
        }

        final id = accounts['id'];
        if (id == null) {
          throw Exception('Google ID library not available');
        }

        // Create a one-time token client
        final tokenClient = id.callMethod('oauth2.initTokenClient', [
          js.JsObject.jsify({
            'client_id': _clientId,
            'callback': (response) {
              try {
                if (response != null && response['access_token'] != null) {
                  completer.complete(response['access_token'] as String?);
                } else {
                  completer.complete(null);
                }
              } catch (e) {
                print('Token callback error: $e');
                completer.complete(null);
              }
            },
          })
        ]);

        // Request access token
        if (tokenClient != null && tokenClient.callMethod != null) {
          try {
            tokenClient.callMethod('requestAccessToken', [js.JsObject.jsify({
              'prompt': 'consent' 
            })]);
          } catch (e) {
            print('Request token error: $e');
            completer.complete(null);
          }
        } else {
          completer.complete(null);
        }
      } catch (e) {
        print('Google JS interop error: $e');
        // Don't complete here, let timeout handle it
      }

      // Wait for token with timeout
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Google Sign-In timeout');
          return null;
        },
      );
    } catch (e) {
      print('signInWithGoogle error: $e');
      return null;
    }
  }

  /// Exchange Google access token for Firebase credential
  static OAuthCredential getCredentialFromToken(String accessToken) {
    // This is a bit of a hack - we'll get the ID token from Google's tokeninfo endpoint
    // For now, we'll use the accessToken with GoogleAuthProvider
    return GoogleAuthProvider.credential(accessToken: accessToken);
  }
}
