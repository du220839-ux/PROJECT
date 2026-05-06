import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class AdminPendingProductsScreen extends StatefulWidget {
  const AdminPendingProductsScreen({super.key});

  @override
  State<AdminPendingProductsScreen> createState() => _AdminPendingProductsScreenState();
}

class _AdminPendingProductsScreenState extends State<AdminPendingProductsScreen> {
  int? _processingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAdmin) {
        context.read<ProductProvider>().loadPendingProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Duyệt bài đăng')),
        body: const EmptyWidget(
          message: 'Đăng nhập bằng tài khoản admin để duyệt bài đăng.',
          icon: Icons.lock_outline,
        ),
      );
    }

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Duyệt bài đăng')),
        body: const EmptyWidget(
          message: 'Chỉ quản trị viên mới có quyền duyệt bài đăng.',
          icon: Icons.admin_panel_settings_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài đăng chờ duyệt'),
        actions: [
          IconButton(
            onPressed: () => context.read<ProductProvider>().loadPendingProducts(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.pendingProducts.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.pendingProducts.isEmpty) {
            return const EmptyWidget(
              message: 'Hiện không có bài đăng nào đang chờ duyệt.',
              icon: Icons.inventory_2_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ProductProvider>().loadPendingProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingProducts.length,
              itemBuilder: (context, index) {
                final product = provider.pendingProducts[index];
                return _buildProductCard(product);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final seller = product.seller;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.thumbnailUrl.isNotEmpty
                  ? Image.network(
                      product.thumbnailUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Chờ duyệt',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (product.category != null)
              Text(
                '${product.category!.icon} ${product.category!.name}',
                style: const TextStyle(color: AppTheme.textMedium),
              ),
            if (seller != null) ...[
              const SizedBox(height: 6),
              Text(
                'Người bán: ${seller.name}${seller.phone != null ? ' • ${seller.phone}' : ''}',
                style: const TextStyle(color: AppTheme.textMedium),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              product.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push('/product/${product.id}'),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Xem chi tiết'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _processingId == product.id
                      ? null
                      : () => _moderateProduct(product, 'rejected'),
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  label: const Text('Từ chối', style: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _processingId == product.id
                      ? null
                      : () => _moderateProduct(product, 'approved'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                  icon: _processingId == product.id
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(_processingId == product.id ? 'Đang xử lý' : 'Duyệt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moderateProduct(ProductModel product, String status) async {
    setState(() => _processingId = product.id);
    final success = await context.read<ProductProvider>().updateModerationStatus(
          id: product.id,
          status: status,
        );
    if (!mounted) return;
    setState(() => _processingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? status == 'approved'
                  ? 'Đã duyệt bài đăng "${product.title}".'
                  : 'Đã từ chối bài đăng "${product.title}".'
              : 'Không thể cập nhật trạng thái bài đăng.',
        ),
      ),
    );
  }
}