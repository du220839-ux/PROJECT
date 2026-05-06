import 'package:dio/dio.dart';
import 'package:secondhand_app/services/api_service.dart';

class AISearchService {
  static final AISearchService _instance = AISearchService._internal();
  factory AISearchService() => _instance;
  AISearchService._internal();

  /// Get AI-powered search suggestions
  /// Example: "iphone" -> ["iphone 13", "iphone 14 pro max", ...]
  Future<List<String>> getSearchSuggestions(
    String query, {
    int limit = 5,
    Map<String, dynamic>? priceRange,
    int? categoryId,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final apiService = ApiService();
      print('Making AI suggestion request to: /ai/search-suggestions');
      final Response response = await apiService.post(
        '/ai/search-suggestions',
        data: {
          'query': query,
          'limit': limit,
          if (priceRange != null) 'price_range': priceRange,
          if (categoryId != null) 'category_id': categoryId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final suggestions = List<String>.from(
          response.data['suggestions'] ?? [],
        );
        return suggestions;
      }
      return [];
    } on DioError catch (e) {
      print('AI Search Suggestions Error: ${e.message}');
      print('Error Type: ${e.type}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Request URL: ${e.requestOptions.path}');
      return [];
    } catch (e) {
      print('Unexpected error in getSearchSuggestions: $e');
      return [];
    }
  }

  /// Get smart product search with AI explanation
  /// Returns products matching the search with AI-generated explanation
  Future<Map<String, dynamic>> getSmartProductSearch(
    String query, {
    int limit = 10,
    int page = 1,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return {
          'products': <dynamic>[],
          'explanation': 'Vui lòng nhập từ khóa tìm kiếm.',
        };
      }

      final apiService = ApiService();
      print('Making AI search request to: /ai/smart-search');
      final Response response = await apiService.post(
        '/ai/smart-search',
        data: {
          'query': query,
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'products': response.data['products'] ?? [],
          'explanation': response.data['explanation'] ?? '',
          'total': response.data['total'],
        };
      }
      return {
        'products': <dynamic>[],
        'explanation': 'Không thể tìm kiếm sản phẩm. Vui lòng thử lại.',
      };
    } on DioError catch (e) {
      print('AI Smart Search Error: ${e.message}');
      print('Error Type: ${e.type}');
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Request URL: ${e.requestOptions.path}');
      
      String errorMsg = 'Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.';
      if (e.type == DioErrorType.connectTimeout || e.type == DioErrorType.receiveTimeout) {
        errorMsg = 'Kết nối timeout. Vui lòng kiểm tra IP server và thử lại.';
      }
      
      return {
        'products': <dynamic>[],
        'explanation': errorMsg,
      };
    } catch (e) {
      print('Unexpected error in getSmartProductSearch: $e');
      return {
        'products': <dynamic>[],
        'explanation': 'Có lỗi xảy ra. Vui lòng thử lại.',
      };
    }
  }
}
