import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/models/category_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<ProductModel>> getProducts({
    int page = 1,
    int? categoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      if (categoryId != null) 'category_id': categoryId,
      if (query != null && query.isNotEmpty) 'q': query,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
    };
    final response = await _api.get('/products', params: params);
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final response = await _api.get('/products/$id');
    return ProductModel.fromJson(response.data['product'] ?? response.data);
  }

  Future<ProductModel> createProduct({
    required int categoryId,
    required String title,
    required String description,
    required double price,
    String? location,
    required List<dynamic> images,
  }) async {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('category_id', categoryId.toString()),
      MapEntry('title', title),
      MapEntry('description', description),
      MapEntry('price', price.toString()),
      if (location != null && location.isNotEmpty)
        MapEntry('location', location),
    ]);
    for (var i = 0; i < images.length; i++) {
      final img = images[i] as XFile;
      final filename = img.name.isNotEmpty ? img.name : 'image_$i.jpg';

      // Ensure the mime type is correctly set so the backend accepts the file.
      // Multer uses this to validate allowed file types.
      final mimeType =
          lookupMimeType(img.path, headerBytes: await img.readAsBytes()) ??
              'image/jpeg';
      final parts = mimeType.split('/');
      final contentType = parts.length == 2
          ? MediaType(parts[0], parts[1])
          : MediaType('image', 'jpeg');

      if (kIsWeb) {
        final bytes = await img.readAsBytes();
        formData.files.add(MapEntry(
          'images[]',
          MultipartFile.fromBytes(bytes,
              filename: filename, contentType: contentType),
        ));
      } else {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(
            img.path,
            filename: filename,
            contentType: contentType,
          ),
        ));
      }
    }
    final response = await _api.postFormData('/products', formData);
    return ProductModel.fromJson(response.data['product'] ?? response.data);
  }

  Future<ProductModel> updateProduct({
    required int id,
    int? categoryId,
    String? title,
    String? description,
    double? price,
    String? status,
  }) async {
    final data = <String, dynamic>{
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (status != null) 'status': status,
    };
    final response = await _api.put('/products/$id', data: data);
    return ProductModel.fromJson(response.data['product'] ?? response.data);
  }

  Future<void> deleteProduct(int id) async {
    await _api.delete('/products/$id');
  }

  Future<List<ProductModel>> getMyProducts() async {
    final response = await _api.get('/products/my-products');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getPendingProducts() async {
    final response = await _api.get('/products/admin/pending');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> updateProductModerationStatus({
    required int id,
    required String status,
  }) async {
    await _api.patch('/products/admin/$id/status', data: {
      'status': status,
    });
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get('/categories');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<void> toggleFavorite(int productId) async {
    await _api.post('/favorites/toggle', data: {'product_id': productId});
  }

  Future<List<ProductModel>> getFavorites() async {
    final response = await _api.get('/favorites');
    final List data = response.data['favorites'] ?? response.data['data'] ?? [];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> getUserProducts(int userId) async {
    final response = await _api.get('/users/$userId/products');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}
