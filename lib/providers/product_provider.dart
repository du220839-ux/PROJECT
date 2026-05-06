import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/models/category_model.dart';
import 'package:secondhand_app/services/api_service.dart';
import 'package:secondhand_app/services/product_service.dart';
import 'package:secondhand_app/config/app_config.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _myProducts = [];
  List<ProductModel> _favorites = [];
  List<ProductModel> _pendingProducts = [];
  ProductModel? _currentProduct;

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  int? _selectedCategoryId;

  List<ProductModel> get products => _products;
  List<ProductModel> get myProducts => _myProducts;
  List<ProductModel> get favorites => _favorites;
  List<ProductModel> get pendingProducts => _pendingProducts;
  ProductModel? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  List<CategoryModel> get localCategories => AppConfig.categories
      .map((e) => CategoryModel(id: e['id'], name: e['name'], icon: e['icon']))
      .toList();

  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products = [];
    }
    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProducts = await _service.getProducts(
        page: _currentPage,
        categoryId: _selectedCategoryId,
      );
      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        _currentPage++;
      }
    } catch (e) {
      _error = 'Không thể tải sản phẩm';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query, {int? categoryId, double? minPrice, double? maxPrice, String? sortBy}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _service.getProducts(
        query: query,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
      );
      _hasMore = false;
    } catch (e) {
      _error = 'Tìm kiếm thất bại';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductDetail(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentProduct = await _service.getProduct(id);
    } catch (e) {
      _error = 'Không tải được sản phẩm';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required int categoryId,
    required String title,
    required String description,
    required double price,
    String? location,
    required List<dynamic> images,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createProduct(
        categoryId: categoryId,
        title: title,
        description: description,
        price: price,
        location: location,
        images: images,
      );
      await loadMyProducts();
      return true;
    } catch (e) {
      // Extract a more user-friendly message when possible.
      if (e is DioError) {
        final responseData = e.response?.data;
        String msg = e.message;
        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            msg = responseData['message'].toString();
          } else if (responseData['error'] != null) {
            msg = responseData['error'].toString();
          }
        }
        _error = 'Đăng bài thất bại: $msg';
      } else {
        _error = 'Đăng bài thất bại: ${e.toString()}';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required int id,
    int? categoryId,
    String? title,
    String? description,
    double? price,
    String? status,
  }) async {
    try {
      final updated = await _service.updateProduct(
        id: id, categoryId: categoryId, title: title,
        description: description, price: price, status: status,
      );
      final idx = _myProducts.indexWhere((p) => p.id == id);
      if (idx != -1) _myProducts[idx] = updated;
      if (_currentProduct?.id == id) _currentProduct = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Cập nhật thất bại';
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _service.deleteProduct(id);
      _myProducts.removeWhere((p) => p.id == id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Xoá bài thất bại';
      return false;
    }
  }

  Future<void> loadMyProducts() async {
    try {
      _myProducts = await _service.getMyProducts();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadPendingProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _pendingProducts = await _service.getPendingProducts();
    } catch (_) {
      _error = 'Không thể tải danh sách chờ duyệt';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateModerationStatus({
    required int id,
    required String status,
  }) async {
    try {
      await _service.updateProductModerationStatus(id: id, status: status);
      _pendingProducts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Không thể cập nhật trạng thái bài đăng';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadFavorites() async {
    try {
      _favorites = await _service.getFavorites();
      print('Loaded favorites: ${_favorites.length}');
      // Use Future.microtask to avoid notifyListeners during build
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('Error loading favorites: $e');
      // Don't re-throw to prevent Future already completed
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx].isFavorite = !_products[idx].isFavorite;
      notifyListeners();
    }
    try {
      await _service.toggleFavorite(productId);
      await loadFavorites();
    } catch (_) {
      if (idx != -1) {
        _products[idx].isFavorite = !_products[idx].isFavorite;
        notifyListeners();
      }
    }
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    loadProducts(refresh: true);
  }
}
