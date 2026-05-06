import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:secondhand_app/config/firebase_env_options.dart';

class EmailVerificationRequiredException implements Exception {
  final String email;

  EmailVerificationRequiredException(this.email);
}

class FirebaseAuthService {
  FirebaseAuthService();

  static final FirebaseAuth instance = FirebaseAuth.instance;

  static bool get isConfigured => FirebaseEnvOptions.isConfigured;

  static Future<void> initialize() async {
    try {
      if (!isConfigured) {
        print('Firebase not configured, skipping initialization');
        return;
      }
      
      print('Initializing Firebase with project: ${FirebaseEnvOptions.projectId}');
      await Firebase.initializeApp(options: FirebaseEnvOptions.currentPlatform);
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      // Don't rethrow, just print error to avoid app crash
    }
  }

  Future<void> registerAndSendVerification({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return;

    final credential = await instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
  }

  Future<void> loginAndEnsureVerified({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return;

    final credential = await instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.reload();
    final user = instance.currentUser;
    if (user == null || !user.emailVerified) {
      await user?.sendEmailVerification();
      throw EmailVerificationRequiredException(email);
    }
  }

  Future<void> resendVerificationEmail() async {
    if (!isConfigured) return;
    await instance.currentUser?.sendEmailVerification();
  }

  Future<bool> reloadAndCheckVerification() async {
    if (!isConfigured) return true;
    final user = instance.currentUser;
    await user?.reload();
    return instance.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    await instance.signOut();
  }

  Future<void> deleteCurrentUser() async {
    if (!isConfigured) return;
    final user = instance.currentUser;
    await user?.delete();
  }

  /// Sign in with Google using Firebase
  Future<UserCredential> signInWithGoogle() async {
    if (!isConfigured) {
      throw Exception('Firebase not configured');
    }

    try {
      // Get Google user
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      // Get Google auth
      final googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      return await instance.signInWithCredential(credential);
    } catch (e) {
      print('Firebase Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOutFromGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    if (isConfigured) {
      await instance.signOut();
    }
  }
}