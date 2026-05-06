import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secondhand_app/config/app_config.dart';

void main() {
  test('API smoke: login and get products', () async {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: 30000,
      receiveTimeout: 30000,
      headers: {'Accept': 'application/json'},
    ));

    final login = await dio.post('/auth/login', data: {
      'email': 'user1@secondhand.local',
      'password': '123456',
    });

    expect(login.statusCode, 200);
    final token = login.data['token']?.toString();
    expect(token, isNotNull);
    expect(token!.isNotEmpty, true);

    final products = await dio.get(
      '/products',
      queryParameters: {'page': 1, 'limit': 20},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    expect(products.statusCode, 200);
    expect(products.data['data'], isA<List>());
    final list = products.data['data'] as List;
    expect(list.isNotEmpty, true);
  });
}
