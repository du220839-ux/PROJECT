import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadMyProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài đăng của tôi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đang bán'),
            Tab(text: 'Đã bán'),
          ],
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myProducts.isEmpty) return const LoadingWidget();
          if (provider.myProducts.isEmpty) {
            return EmptyWidget(
              message: 'Bạn chưa có bài đăng nào',
              icon: Icons.post_add,
              onAction: () => context.push('/product/add'),
              actionLabel: 'Đăng bán ngay',
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.myProducts),
              _buildList(provider.myProducts.where((p) => p.status == ProductStatus.pending).toList()),
              _buildList(provider.myProducts.where((p) => p.status == ProductStatus.approved).toList()),
              _buildList(provider.myProducts.where((p) => p.status == ProductStatus.sold).toList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/product/add'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Đăng mới', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildList(List<ProductModel> products) {
    if (products.isEmpty) {
      return const EmptyWidget(message: 'Không có bài đăng nào', icon: Icons.inbox_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (ctx, i) => _ProductListItem(product: products[i]),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final ProductModel product;
  const _ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.thumbnailUrl.isNotEmpty
              ? Image.network(product.thumbnailUrl, width: 70, height: 70, fit: BoxFit.cover)
              : Container(
                  width: 70, height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
        ),
        title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatter.format(product.price),
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(product.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(product.statusLabel,
                  style: TextStyle(color: _statusColor(product.status), fontSize: 11)),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
            if (product.status == ProductStatus.approved)
              const PopupMenuItem(value: 'sold', child: Text('Đánh dấu đã bán')),
            const PopupMenuItem(value: 'delete', child: Text('Xoá', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (v) => _handleAction(context, v.toString()),
        ),
        onTap: () => context.push('/product/${product.id}'),
      ),
    );
  }

  Color _statusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.approved: return Colors.green;
      case ProductStatus.rejected: return Colors.red;
      case ProductStatus.sold: return Colors.grey;
      default: return Colors.orange;
    }
  }

  void _handleAction(BuildContext context, String action) async {
    final provider = context.read<ProductProvider>();
    if (action == 'edit') {
      context.push('/product/edit/${product.id}');
    } else if (action == 'sold') {
      await provider.updateProduct(id: product.id, status: 'sold');
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận xoá'),
          content: const Text('Bạn có chắc muốn xoá bài đăng này?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xoá'),
            ),
          ],
        ),
      );
      if (confirm == true) await provider.deleteProduct(product.id);
    }
  }
}
