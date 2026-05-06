import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:secondhand_app/config/theme.dart';

import 'package:secondhand_app/models/category_model.dart';

import 'package:secondhand_app/providers/auth_provider.dart';

import 'package:secondhand_app/providers/product_provider.dart';

import 'package:secondhand_app/widgets/common/loading_widget.dart';

import 'package:secondhand_app/widgets/common/app_text_field.dart';

import 'package:secondhand_app/widgets/product/product_card.dart';



class SearchScreen extends StatefulWidget {

  final String? query;

  const SearchScreen({super.key, this.query});



  @override

  State<SearchScreen> createState() => _SearchScreenState();

}



class _SearchScreenState extends State<SearchScreen> {

  final _ctrl = TextEditingController();

  final _minPriceCtrl = TextEditingController();

  final _maxPriceCtrl = TextEditingController();

  bool _searched = false;

  bool _showFilters = false;

  int? _selectedCategoryId;

  String _sortBy = 'newest';



  static const List<String> _suggestions = [

    'iPhone', 'Laptop', 'Xe máy', 'Tủ lạnh', 'Máy giặt',

    'Bàn ghế', 'Sách', 'Quần áo', 'Điện thoại Samsung',

  ];



  static const List<Map<String, dynamic>> _sortOptions = [

    {'value': 'newest', 'label': 'Mới nhất'},

    {'value': 'oldest', 'label': 'Cũ nhất'},

    {'value': 'price_low', 'label': 'Giá thấp đến cao'},

    {'value': 'price_high', 'label': 'Giá cao đến thấp'},

  ];



  @override

  void initState() {

    super.initState();

    if (widget.query != null && widget.query!.isNotEmpty) {

      _ctrl.text = widget.query!;

      WidgetsBinding.instance.addPostFrameCallback((_) => _search());

    }

  }



  void _search() {

    if (_ctrl.text.trim().isEmpty) return;

    setState(() => _searched = true);

    context.read<ProductProvider>().searchProducts(

      _ctrl.text.trim(),

      categoryId: _selectedCategoryId,

      minPrice: _minPriceCtrl.text.trim().isNotEmpty ? double.tryParse(_minPriceCtrl.text.trim()) : null,

      maxPrice: _maxPriceCtrl.text.trim().isNotEmpty ? double.tryParse(_maxPriceCtrl.text.trim()) : null,

    );

  }



  void _clearFilters() {

    setState(() {

      _selectedCategoryId = null;

      _minPriceCtrl.clear();

      _maxPriceCtrl.clear();

      _sortBy = 'newest';

    });

    if (_searched) _search();

  }



  @override

  void dispose() {

    _ctrl.dispose();

    _minPriceCtrl.dispose();

    _maxPriceCtrl.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: TextField(

          controller: _ctrl,

          autofocus: true,

          style: const TextStyle(color: Colors.white),

          cursorColor: Colors.white,

          decoration: const InputDecoration(

            hintText: 'Tìm kiếm sản phẩm...',

            hintStyle: TextStyle(color: Colors.white60),

            border: InputBorder.none,

            filled: false,

          ),

          onSubmitted: (_) => _search(),

          textInputAction: TextInputAction.search,

        ),

        actions: [

          IconButton(

            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),

            onPressed: () => setState(() => _showFilters = !_showFilters),

          ),

          IconButton(icon: const Icon(Icons.search), onPressed: _search),

        ],

      ),

      body: Column(

        children: [

          if (_showFilters) _buildFilterPanel(),

          Expanded(child: _searched ? _buildResults() : _buildSuggestions()),

        ],

      ),

    );

  }



  Widget _buildFilterPanel() {

    final provider = context.read<ProductProvider>();

    final categories = provider.localCategories;



    return Container(

      padding: const EdgeInsets.all(16),

      color: Colors.grey[50],

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              const Text('Bộ lọc tìm kiếm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

              TextButton(

                onPressed: _clearFilters,

                child: const Text('Xóa bộ lọc', style: TextStyle(color: AppTheme.primaryColor)),

              ),

            ],

          ),

          const SizedBox(height: 12),

          

          // Category filter

          const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 8),

          Wrap(

            spacing: 8,

            runSpacing: 4,

            children: [

              FilterChip(

                label: const Text('Tất cả'),

                selected: _selectedCategoryId == null,

                onSelected: (selected) {

                  setState(() => _selectedCategoryId = null);

                  if (_searched) _search();

                },

              ),

              ...categories.map((cat) => FilterChip(
                label: Text(cat.name),
                selected: _selectedCategoryId == cat.id,
                onSelected: (selected) {
                  setState(() => _selectedCategoryId = selected ? cat.id : null);
                  if (_searched) _search();
                },
              )),

            ],

          ),

          

          const SizedBox(height: 16),

          

          // Price range filter

          const Text('Khoảng giá', style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 8),

          Row(

            children: [

              Expanded(

                child: AppTextField(

                  controller: _minPriceCtrl,

                  label: 'Giá tối thiểu',

                  keyboardType: TextInputType.number,

                  onChanged: (_) {
                    if (_searched) _search();
                  },

                ),

              ),

              const SizedBox(width: 16),

              Expanded(

                child: AppTextField(

                  controller: _maxPriceCtrl,

                  label: 'Giá tối đa',

                  keyboardType: TextInputType.number,

                  onChanged: (_) {
                    if (_searched) _search();
                  },

                ),

              ),

            ],

          ),

          

          const SizedBox(height: 16),

          

          // Sort options

          const Text('Sắp xếp', style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 8),

          Wrap(

            spacing: 8,

            runSpacing: 4,

            children: _sortOptions.map((option) => ChoiceChip(

              label: Text(option['label']),

              selected: _sortBy == option['value'],

              onSelected: (selected) {

                setState(() => _sortBy = option['value']);

                if (_searched) _search();

              },

            )).toList(),

          ),

        ],

      ),

    );

  }



  Widget _buildSuggestions() {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Padding(

          padding: EdgeInsets.all(16),

          child: Text('Gợi ý tìm kiếm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

        ),

        Wrap(

          spacing: 8,

          runSpacing: 0,

          children: _suggestions.map((s) =>

            Padding(

              padding: const EdgeInsets.only(left: 8),

              child: ActionChip(

                label: Text(s),

                onPressed: () {

                  _ctrl.text = s;

                  _search();

                },

              ),

            ),

          ).toList(),

        ),

      ],

    );

  }



  Widget _buildResults() {

    return Consumer<ProductProvider>(

      builder: (context, provider, _) {

        if (provider.isLoading) return const LoadingWidget();

        if (provider.products.isEmpty) {

          return EmptyWidget(

            message: 'Không tìm thấy kết quả cho\n"${_ctrl.text}"',

            icon: Icons.search_off,

          );

        }

        return Padding(

          padding: const EdgeInsets.all(8),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                child: Text(

                  'Tìm thấy ${provider.products.length} sản phẩm',

                  style: const TextStyle(color: AppTheme.textMedium, fontSize: 13),

                ),

              ),

              Expanded(

                child: GridView.builder(

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 2, childAspectRatio: 0.72,

                  ),

                  itemCount: provider.products.length,

                  itemBuilder: (ctx, i) => ProductCard(

                    product: provider.products[i],

                    onFavorite: context.read<AuthProvider>().isAuthenticated

                        ? () => provider.toggleFavorite(provider.products[i].id)

                        : null,

                  ),

                ),

              ),

            ],

          ),

        );

      },

    );

  }

}

