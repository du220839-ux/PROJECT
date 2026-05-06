import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/services/api_service.dart';
import 'package:secondhand_app/widgets/common/app_button.dart';
import 'package:secondhand_app/widgets/common/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _specificAddressCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  File? _avatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone ?? '';
      _addressCtrl.text = user.address ?? '';
      
      // Parse existing address if it contains structured data
      if (user.address != null && user.address!.contains('|')) {
        final parts = user.address!.split('|');
        if (parts.length >= 4) {
          _specificAddressCtrl.text = parts[0].trim();
          _wardCtrl.text = parts[1].trim();
          _districtCtrl.text = parts[2].trim();
          _cityCtrl.text = parts[3].trim();
        }
      } else {
        _cityCtrl.text = user.address ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _specificAddressCtrl.dispose();
    _wardCtrl.dispose();
    _districtCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _avatarFile = File(img.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    try {
      // Combine all address fields into a structured format
      String fullAddress = '';
      if (_specificAddressCtrl.text.trim().isNotEmpty) {
        fullAddress += _specificAddressCtrl.text.trim();
      }
      if (_wardCtrl.text.trim().isNotEmpty) {
        fullAddress += (fullAddress.isNotEmpty ? ', ' : '') + _wardCtrl.text.trim();
      }
      if (_districtCtrl.text.trim().isNotEmpty) {
        fullAddress += (fullAddress.isNotEmpty ? ', ' : '') + _districtCtrl.text.trim();
      }
      if (_cityCtrl.text.trim().isNotEmpty) {
        fullAddress += (fullAddress.isNotEmpty ? ', ' : '') + _cityCtrl.text.trim();
      }
      
      await ApiService().put('/auth/profile', data: {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': fullAddress.trim(),
      });
      final user = authProvider.user!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: fullAddress.trim(),
      );
      if (!mounted) return;
      authProvider.updateUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
      );
      context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!) as ImageProvider
                          : (user?.avatar != null ? NetworkImage(user!.avatar!) : null),
                      backgroundColor: Colors.grey[200],
                      child: (_avatarFile == null && user?.avatar == null)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 28),
              AppTextField(
                controller: _nameCtrl,
                label: 'Họ và tên',
                prefixIcon: Icons.person_outline,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Số điện thoại',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text(
                'Địa chỉ cụ thể',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _specificAddressCtrl,
                label: 'Số nhà, tên đường',
                prefixIcon: Icons.home_outlined,
                hint: 'Ví dụ: 123 Nguyễn Văn Linh',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _wardCtrl,
                label: 'Phường/Xã',
                prefixIcon: Icons.location_city_outlined,
                hint: 'Ví dụ: An Cư',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _districtCtrl,
                label: 'Quận/Huyện',
                prefixIcon: Icons.apartment_outlined,
                hint: 'Ví dụ: Ninh Kiều',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _cityCtrl,
                label: 'Tỉnh/Thành phố',
                prefixIcon: Icons.location_on_outlined,
                hint: 'Ví dụ: Cần Thơ',
              ),
              const SizedBox(height: 28),
              AppButton(text: 'Lưu thay đổi', onPressed: _save, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
