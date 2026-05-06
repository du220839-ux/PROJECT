import 'package:secondhand_app/config/firebase_env_options.dart';
import 'package:secondhand_app/services/firebase_auth_service.dart';

void main() {
  print('=== Firebase Configuration Check ===');
  print('API Key: ${FirebaseEnvOptions.apiKey}');
  print('App ID: ${FirebaseEnvOptions.appId}');
  print('Project ID: ${FirebaseEnvOptions.projectId}');
  print('Messaging Sender ID: ${FirebaseEnvOptions.messagingSenderId}');
  print('Is Configured: ${FirebaseEnvOptions.isConfigured}');
  print('Auth Service Configured: ${FirebaseAuthService.isConfigured}');
}
