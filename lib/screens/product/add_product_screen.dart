import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/app_config.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/common/app_button.dart';
import 'package:secondhand_app/widgets/common/app_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  int? _selectedCategoryId;
  List<XFile> _images = [];
  final Map<String, Uint8List> _imageBytes = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _provinceCtrl.dispose();
    _districtCtrl.dispose();
    _wardCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      final merged = [..._images, ...picked].take(5).toList();
      for (final img in merged) {
        _imageBytes[img.path] ??= await img.readAsBytes();
      }
      setState(() {
        _images = merged;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null && _images.length < 5) {
      _imageBytes[picked.path] = await picked.readAsBytes();
      setState(() => _images.add(picked));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 ảnh')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<ProductProvider>();
    
    // Ghép địa chỉ đầy đủ
    String? fullAddress;
    final province = _provinceCtrl.text.trim();
    final district = _districtCtrl.text.trim();
    final ward = _wardCtrl.text.trim();
    
    if (province.isNotEmpty || district.isNotEmpty || ward.isNotEmpty) {
      final parts = <String>[];
      if (ward.isNotEmpty) parts.add(ward);
      if (district.isNotEmpty) parts.add(district);
      if (province.isNotEmpty) parts.add(province);
      fullAddress = parts.join(', ');
    }
    
    final success = await provider.createProduct(
      categoryId: _selectedCategoryId!,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', '')),
      location: fullAddress,
      images: _images,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng bài thành công! Chờ admin duyệt.'), backgroundColor: Colors.green),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Đăng bài thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng bán đồ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hình ảnh sản phẩm *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildImagePicker(),
              const SizedBox(height: 20),
              const Text('Thông tin sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              AppTextField(
                controller: _titleCtrl,
                label: 'Tiêu đề *',
                hint: 'VD: iPhone 13 Pro Max 256GB',
                prefixIcon: Icons.title,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập tiêu đề';
                  if (v.length < 5) return 'Tiêu đề ít nhất 5 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Danh mục *', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildCategoryPicker(),
              const SizedBox(height: 16),
              AppTextField(
                controller: _priceCtrl,
                label: 'Giá (VNĐ) *',
                hint: 'VD: 5000000',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập giá';
                  final price = double.tryParse(v.replaceAll(',', '').replaceAll('.', ''));
                  if (price == null || price <= 0) return 'Giá không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Địa chỉ sản phẩm', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _provinceCtrl,
                      label: 'Tỉnh/Thành phố',
                      hint: 'VD: TP.HCM',
                      prefixIcon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _districtCtrl,
                      label: 'Quận/Huyện',
                      hint: 'VD: Quận 1',
                      prefixIcon: Icons.map,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _wardCtrl,
                label: 'Phường/Xã',
                hint: 'VD: Phường Bến Thành',
                prefixIcon: Icons.place,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionCtrl,
                label: 'Mô tả sản phẩm *',
                hint: 'Mô tả chi tiết tình trạng, thông số...',
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mô tả';
                  if (v.length < 20) return 'Mô tả ít nhất 20 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              AppButton(text: 'Đăng bài', onPressed: _submit, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._images.map((img) => _ImagePreview(
                    bytes: _imageBytes[img.path],
                    onRemove: () {
                      setState(() {
                        _images.remove(img);
                        _imageBytes.remove(img.path);
                      });
                    },
                  )),
              if (_images.length < 5)
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: Colors.grey[500], size: 32),
                        Text('Thêm ảnh\n(${_images.length}/5)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () { Navigator.pop(ctx); _pickImages(); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh'),
              onTap: () { Navigator.pop(ctx); _pickFromCamera(); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Wrap(
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
          side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!),
        );
      }).toList(),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback onRemove;

  const _ImagePreview({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          clipBehavior: Clip.antiAlias,
          child: bytes == null
              ? const Icon(Icons.image_outlined, color: Colors.grey)
              : Image.memory(bytes!, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
