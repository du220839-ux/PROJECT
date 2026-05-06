import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:secondhand_app/config/app_config.dart';

Future<void> main() async {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: 30000,
    receiveTimeout: 30000,
    headers: {'Accept': 'application/json'},
  ));

  try {
    final login = await dio.post('/auth/login', data: {
      'email': 'user1@secondhand.local',
      'password': '123456',
    });

    final token = login.data['token']?.toString();
    final userEmail = login.data['user']?['email']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception('Login ok but token missing');
    }

    final products = await dio.get(
      '/products',
      queryParameters: {'page': 1, 'limit': 20},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List list = (products.data['data'] as List?) ?? const [];

    developer.log('SMOKE_OK', name: 'smoke_api');
    developer.log('baseUrl: ${AppConfig.baseUrl}', name: 'smoke_api');
    developer.log('login_user: $userEmail', name: 'smoke_api');
    developer.log('products_count: ${list.length}', name: 'smoke_api');
    if (list.isNotEmpty) {
      developer.log('first_product: ${list.first['title']}', name: 'smoke_api');
    }
  } on DioError catch (e) {
    developer.log('SMOKE_FAIL_DIO', name: 'smoke_api');
    developer.log('status: ${e.response?.statusCode}', name: 'smoke_api');
    developer.log('data: ${e.response?.data}', name: 'smoke_api');
    rethrow;
  } catch (e) {
    developer.log('SMOKE_FAIL', name: 'smoke_api');
    developer.log(e.toString(), name: 'smoke_api');
    rethrow;
  }
}
