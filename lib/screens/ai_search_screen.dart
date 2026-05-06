import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/providers/search_provider.dart';
import 'package:secondhand_app/screens/product/product_detail_screen.dart';

class AISearchScreen extends StatefulWidget {
  const AISearchScreen({Key? key}) : super(key: key);

  @override
  State<AISearchScreen> createState() => _AISearchScreenState();
}

class _AISearchScreenState extends State<AISearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSuggestionSelected(String suggestion, SearchProvider provider) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    provider.searchProducts(query: suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Search Products'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Search header
                Container(
                  color: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search input field
                      TextFormField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (value) {
                          provider.updateSearchQuery(value);
                          setState(() {
                            _showSuggestions = value.isNotEmpty;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products with AI...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.clearSearch();
                                    setState(() => _showSuggestions = false);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoadingResults
                              ? null
                              : () {
                                  if (_searchController.text.isNotEmpty) {
                                    provider
                                        .searchProducts(
                                            query: _searchController.text)
                                        .then((_) {
                                      _searchFocusNode.unfocus();
                                      setState(() => _showSuggestions = false);
                                    });
                                  }
                                },
                          icon: provider.isLoadingResults
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(provider.isLoadingResults
                              ? 'Searching...'
                              : 'Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Suggestions dropdown
                if (_showSuggestions && provider.suggestions.isNotEmpty)
                  Container(
                    color: Colors.grey[50],
                    child: Column(
                      children: provider.suggestions
                          .map((suggestion) => ListTile(
                                leading: const Icon(Icons.lightbulb_outline),
                                title: Text(suggestion),
                                onTap: () =>
                                    _onSuggestionSelected(suggestion, provider),
                              ))
                          .toList(),
                    ),
                  ),

                // Content area
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (provider.errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[800]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.errorMessage,
                                  style: TextStyle(color: Colors.red[800]),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Search explanation
                      if (provider.searchExplanation.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.searchExplanation,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Search results
                      if (provider.hasResults)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Found ${provider.searchResults.length} products',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.searchResults.length,
                              itemBuilder: (context, index) {
                                final product =
                                    provider.searchResults[index];
                                return _buildProductCard(context, product);
                              },
                            ),
                            const SizedBox(height: 16),
                            // Pagination buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (provider.currentPage > 1)
                                  ElevatedButton.icon(
                                    onPressed:
                                        provider.isLoadingResults
                                            ? null
                                            : provider.loadPreviousPage,
                                    icon: const Icon(Icons.navigate_before),
                                    label: const Text('Previous'),
                                  ),
                                const SizedBox(width: 8),
                                Text('Page ${provider.currentPage}'),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed:
                                      provider.isLoadingResults
                                          ? null
                                          : provider.loadNextPage,
                                  label: const Text('Next'),
                                  icon: const Icon(Icons.navigate_next),
                                ),
                              ],
                            ),
                          ],
                        )
                      else if (!provider.hasResults &&
                          provider.searchQuery.isEmpty &&
                          provider.recentSearches.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Searches',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: provider.recentSearches
                                  .map((search) => InputChip(
                                        label: Text(search),
                                        onPressed: () =>
                                            _onSuggestionSelected(
                                                search, provider),
                                        deleteIcon: const Icon(Icons.close),
                                        onDeleted: () {
                                          provider
                                              .removeRecentSearch(search);
                                        },
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  provider.clearRecentSearches();
                                },
                                child: const Text('Clear all recent searches'),
                              ),
                            ),
                          ],
                        )
                      else if (!provider.hasResults &&
                          provider.searchQuery.isNotEmpty &&
                          !provider.isLoadingResults)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (provider.searchQuery.isEmpty &&
                          provider.recentSearches.isEmpty &&
                          !provider.isLoadingResults)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Start searching',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Type above to search for products with AI suggestions',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Loading indicator
                      if (provider.isLoadingResults)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to product detail
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(productId: product['id']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Placeholder image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] ?? 'Unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['category_name'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product['price']} VNĐ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
