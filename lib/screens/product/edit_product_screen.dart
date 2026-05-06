import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/app_config.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/common/app_button.dart';
import 'package:secondhand_app/widgets/common/app_text_field.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int? _selectedCategoryId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
  }

  Future<void> _loadProduct() async {
    final provider = context.read<ProductProvider>();
    await provider.loadProductDetail(widget.productId);
    if (!mounted) return;
    final product = provider.currentProduct;
    if (product != null) {
      _titleCtrl.text = product.title;
      _descriptionCtrl.text = product.description;
      _priceCtrl.text = product.price.toStringAsFixed(0);
      setState(() {
        _selectedCategoryId = product.categoryId;
        _loaded = true;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProductProvider>();
    final success = await provider.updateProduct(
      id: widget.productId,
      categoryId: _selectedCategoryId,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', '')),
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return Scaffold(appBar: AppBar(title: const Text('Chỉnh sửa bài')), body: const LoadingWidget());

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa bài đăng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Tiêu đề',
                prefixIcon: Icons.title,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),
              const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConfig.categories.map((cat) {
                  final isSelected = _selectedCategoryId == cat['id'];
                  return FilterChip(
                    selected: isSelected,
                    label: Text('${cat['icon']} ${cat['name']}'),
                    onSelected: (v) => setState(() => _selectedCategoryId = v ? cat['id'] : null),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _priceCtrl,
                label: 'Giá (VNĐ)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập giá' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionCtrl,
                label: 'Mô tả',
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 28),
              Consumer<ProductProvider>(
                builder: (ctx, p, _) => AppButton(text: 'Lưu thay đổi', onPressed: _submit, isLoading: p.isLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
