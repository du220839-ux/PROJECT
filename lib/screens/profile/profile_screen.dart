import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/product/product_card.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<ProductProvider>().loadMyProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trang cá nhân')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Đăng nhập để xem trang cá nhân',
                  style: TextStyle(fontSize: 16, color: AppTheme.textMedium)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    final user = auth.user!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            title: const Text('Trang cá nhân'),
            actions: [
              IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                        child: user.avatar == null
                            ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 32, color: AppTheme.primaryColor))
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(user.name,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        Text('📱 ${user.phone}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      if (user.address != null)
                        Text('📍 ${user.address}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 4),
                _buildStats(),
                const Divider(height: 1),
                _buildMenuItems(context),
                const Divider(height: 1),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Consumer<ProductProvider>(
      builder: (ctx, provider, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(value: provider.myProducts.length.toString(), label: 'Bài đăng'),
            const _Divider(),
            _StatItem(
              value: provider.myProducts.where((p) => p.status.name == 'sold').length.toString(),
              label: 'Đã bán',
            ),
            const _Divider(),
            _StatItem(value: provider.favorites.length.toString(), label: 'Yêu thích'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Column(
      children: [
        _MenuItem(icon: Icons.edit_outlined, title: 'Chỉnh sửa thông tin',
            onTap: () => context.push('/profile/edit')),
        _MenuItem(icon: Icons.list_alt_outlined, title: 'Bài đăng của tôi',
            onTap: () => context.push('/my-products')),
        _MenuItem(icon: Icons.receipt_long_outlined, title: 'Giao dịch mua bán',
          onTap: () => context.push('/transactions')),
        _MenuItem(icon: Icons.account_balance_outlined, title: 'Liên kết ngân hàng',
          onTap: () => context.push('/bank-account')),
        _MenuItem(icon: Icons.account_balance_wallet_outlined, title: 'Ví của tôi',
          onTap: () => context.push('/wallet')),
        _MenuItem(icon: Icons.favorite_outline, title: 'Sản phẩm yêu thích',
          onTap: () => context.go('/favorites')),
        if (auth.isAdmin)
          _MenuItem(
            icon: Icons.inventory_2_outlined,
            title: 'Duyệt bài đăng chờ duyệt',
            onTap: () => context.push('/admin/products/pending'),
          ),
        if (auth.isAdmin)
          _MenuItem(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Quản lý báo cáo',
            onTap: () => context.push('/admin/reports'),
          ),
        if (auth.isAdmin)
          _MenuItem(
            icon: Icons.dashboard_outlined,
            title: 'Admin Dashboard',
            onTap: () => context.push('/admin/dashboard'),
          ),
        _MenuItem(icon: Icons.help_outline, title: 'Trợ giúp & Hỗ trợ',
          onTap: () => context.push('/help')),
        _MenuItem(
          icon: Icons.logout,
          title: 'Đăng xuất',
          color: Colors.red,
          onTap: () => _confirmLogout(context),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go('/login');
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
      Text(label, style: const TextStyle(color: AppTheme.textMedium, fontSize: 12)),
    ],
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(height: 32, width: 1, color: Colors.grey[300]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppTheme.primaryColor),
    title: Text(title, style: TextStyle(color: color)),
    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    onTap: onTap,
  );
}


