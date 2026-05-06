import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';
import 'package:secondhand_app/widgets/product/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<ProductProvider>().loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm yêu thích')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.favorites.isEmpty) return const LoadingWidget();
          if (provider.favorites.isEmpty) {
            return const EmptyWidget(
              message: 'Chưa có sản phẩm yêu thích\nNhấn ❤️ để lưu sản phẩm bạn thích',
              icon: Icons.favorite_outline,
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadFavorites(),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
              ),
              itemCount: provider.favorites.length,
              itemBuilder: (ctx, i) => ProductCard(
                product: provider.favorites[i],
                onFavorite: () => provider.toggleFavorite(provider.favorites[i].id),
              ),
            ),
          );
        },
      ),
    );
  }
}
