import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secondhand_app/services/ai_search_service.dart';

class SearchProvider extends ChangeNotifier {
  final AISearchService _aiSearchService = AISearchService();
  
  // Search state
  String _searchQuery = '';
  List<String> _suggestions = [];
  List<dynamic> _searchResults = [];
  String _searchExplanation = '';
  List<String> _recentSearches = [];
  
  // Loading and error states
  bool _isLoadingSuggestions = false;
  bool _isLoadingResults = false;
  String _errorMessage = '';
  
  // Filters
  int? _selectedCategoryId;
  Map<String, dynamic>? _priceRange;
  int _currentPage = 1;
  int _resultsLimit = 10;

  // Getters
  String get searchQuery => _searchQuery;
  List<String> get suggestions => _suggestions;
  List<dynamic> get searchResults => _searchResults;
  String get searchExplanation => _searchExplanation;
  List<String> get recentSearches => _recentSearches;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  bool get isLoadingResults => _isLoadingResults;
  String get errorMessage => _errorMessage;
  int? get selectedCategoryId => _selectedCategoryId;
  Map<String, dynamic>? get priceRange => _priceRange;
  bool get hasResults => _searchResults.isNotEmpty;

  SearchProvider() {
    _loadRecentSearches();
  }

  /// Update search query and fetch suggestions
  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query;
    _errorMessage = '';
    
    if (query.isEmpty) {
      _suggestions = [];
      _searchResults = [];
      notifyListeners();
      return;
    }

    await fetchSuggestions();
  }

  /// Fetch AI suggestions based on current search query
  Future<void> fetchSuggestions() async {
    if (_searchQuery.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      final suggestions = await _aiSearchService.getSearchSuggestions(
        _searchQuery,
        limit: 5,
        priceRange: _priceRange,
        categoryId: _selectedCategoryId,
      );
      
      _suggestions = suggestions;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch suggestions: $e';
      _suggestions = [];
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  /// Search for products using the current search query
  Future<void> searchProducts({String? query, int page = 1}) async {
    final searchTerm = query ?? _searchQuery;
    
    if (searchTerm.isEmpty) {
      _errorMessage = 'Please enter a search query';
      notifyListeners();
      return;
    }

    _isLoadingResults = true;
    _errorMessage = '';
    _currentPage = page;
    notifyListeners();

    try {
      final result = await _aiSearchService.getSmartProductSearch(
        searchTerm,
        limit: _resultsLimit,
        page: page,
      );

      _searchResults = result['products'] ?? [];
      _searchExplanation = result['explanation'] ?? '';
      _searchQuery = searchTerm;

      // Add to recent searches
      await _addRecentSearch(searchTerm);

      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      _searchResults = [];
      _searchExplanation = '';
    } finally {
      _isLoadingResults = false;
      notifyListeners();
    }
  }

  /// Clear search results and suggestions
  void clearSearch() {
    _searchQuery = '';
    _suggestions = [];
    _searchResults = [];
    _searchExplanation = '';
    _errorMessage = '';
    _currentPage = 1;
    notifyListeners();
  }

  /// Set category filter
  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    _currentPage = 1;
    notifyListeners();
  }

  /// Set price range filter
  void setPriceRangeFilter(Map<String, dynamic>? range) {
    _priceRange = range;
    _currentPage = 1;
    notifyListeners();
  }

  /// Load recent searches from SharedPreferences
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
      notifyListeners();
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  /// Add search term to recent searches
  Future<void> _addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove if already exists
      _recentSearches.removeWhere((s) => s.toLowerCase() == query.toLowerCase());
      
      // Add to front
      _recentSearches.insert(0, query);
      
      // Keep only last 10 searches
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
      
      await prefs.setStringList('recent_searches', _recentSearches);
      notifyListeners();
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  /// Remove specific recent search
  Future<void> removeRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(query);
      await prefs.setStringList('recent_searches', _recentSearches);
      notifyListeners();
    } catch (e) {
      print('Error removing recent search: $e');
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.clear();
      await prefs.remove('recent_searches');
      notifyListeners();
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  /// Load next page of results
  Future<void> loadNextPage() async {
    if (!_isLoadingResults && _searchQuery.isNotEmpty) {
      await searchProducts(query: _searchQuery, page: _currentPage + 1);
    }
  }

  /// Load previous page of results
  Future<void> loadPreviousPage() async {
    if (_currentPage > 1 && !_isLoadingResults && _searchQuery.isNotEmpty) {
      await searchProducts(query: _searchQuery, page: _currentPage - 1);
    }
  }

  int get currentPage => _currentPage;
}
