import 'package:flutter/material.dart';
import 'package:secondhand_app/app.dart';
import 'package:secondhand_app/config/google_signin_config.dart';
import 'package:secondhand_app/services/firebase_auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable Google One Tap prompt early to avoid FedCM errors
  GoogleSignInConfig.disableAutoPrompt();
  
  await FirebaseAuthService.initialize();
  timeago.setLocaleMessages('vi', timeago.ViMessages());
  runApp(const SecondHandApp());
}
