import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/notification_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/home/category_list.dart';
import 'package:secondhand_app/widgets/product/product_card.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  SliverGridDelegate _productGridDelegate(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1280
        ? 5
        : width >= 1000
            ? 4
            : width >= 700
                ? 3
                : 2;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.72,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(refresh: true);
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<NotificationProvider>().loadNotifications();
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SecondHand 🛒'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) => IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          notificationProvider.unreadCount > 9
                              ? '9+'
                              : notificationProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                if (!auth.isAuthenticated) {
                  context.push('/login');
                  return;
                }
                context.push('/notifications');
              },
            ),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: auth.isAuthenticated
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () => context.push('/product/add'),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody() {
    return _buildHomeTab();
  }

  Widget _buildHomeTab() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () => provider.loadProducts(refresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Danh mục',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const CategoryList(),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Sản phẩm mới nhất',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.products.isEmpty && provider.isLoading)
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => const ShimmerCard(),
                    childCount: 6,
                  ),
                  gridDelegate: _productGridDelegate(context),
                )
              else if (provider.products.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyWidget(
                    message: 'Không có sản phẩm nào',
                    icon: Icons.inventory_2_outlined,
                    onAction: () => provider.loadProducts(refresh: true),
                    actionLabel: 'Tải lại',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => ProductCard(
                        product: provider.products[i],
                        onFavorite: context.read<AuthProvider>().isAuthenticated
                            ? () => provider.toggleFavorite(provider.products[i].id)
                            : null,
                      ),
                      childCount: provider.products.length,
                    ),
                    gridDelegate: _productGridDelegate(context),
                  ),
                ),
              if (provider.isLoading && provider.products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Mua bán đồ cũ',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tiết kiệm tiền - Bảo vệ môi trường',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
