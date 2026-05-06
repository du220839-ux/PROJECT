import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/config/theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onFavorite;
  final bool showStatus;

  const ProductCard({
    super.key,
    required this.product,
    this.onFavorite,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: product.thumbnailUrl.isNotEmpty
                      ? kIsWeb
                          ? Image.network(
                              product.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: product.thumbnailUrl,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(color: Colors.grey[200]),
                              errorWidget: (ctx, url, err) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? AppTheme.primaryColor : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                if (showStatus)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(product.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.statusLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatter.format(product.price),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (product.seller != null)
                    Text(
                      product.seller!.address ?? 'Không rõ địa chỉ',
                      style: const TextStyle(color: AppTheme.textMedium, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
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
}
