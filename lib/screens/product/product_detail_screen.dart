import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/community_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/models/review_model.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPageData();
    });
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _imageIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPageData();
      });
    }
  }

  Future<void> _loadPageData() async {
    await context.read<ProductProvider>().loadProductDetail(widget.productId);
    if (!mounted) return;

    final product = context.read<ProductProvider>().currentProduct;
    if (product?.seller != null) {
      await context.read<CommunityProvider>().loadSellerReviews(product!.userId);
    }
  }

  Future<void> _showReviewDialog(ProductModel product) async {
    final commentController = TextEditingController();
    final community = context.read<CommunityProvider>();
    int rating = 5;
    bool isSubmitting = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogNavigator = Navigator.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Đánh giá người bán'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text('Chọn số sao'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        return IconButton(
                          onPressed: isSubmitting
                              ? null
                              : () => setDialogState(() => rating = value),
                          icon: Icon(
                            value <= rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      enabled: !isSubmitting,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Nhận xét',
                        hintText: 'Mô tả trải nghiệm mua bán của bạn',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => dialogNavigator.pop(false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                            final success = await community.createReview(
                                productId: product.id,
                                sellerId: product.userId,
                                rating: rating,
                                comment: commentController.text.trim().isEmpty
                                    ? null
                                    : commentController.text.trim(),
                              );
                                if (!mounted) return;
                                dialogNavigator.pop(success);
                        },
                  child: Text(isSubmitting ? 'Đang gửi...' : 'Gửi đánh giá'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();

    if (!mounted || created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created
              ? 'Đã gửi đánh giá cho người bán.'
              : 'Không thể gửi đánh giá. Có thể bạn đã đánh giá sản phẩm này rồi.',
        ),
      ),
    );
  }

  Future<void> _showReportDialog(ProductModel product) async {
    final reasonController = TextEditingController();
    final community = context.read<CommunityProvider>();
    bool isSubmitting = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogNavigator = Navigator.of(dialogContext);
        final dialogMessenger = ScaffoldMessenger.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submitReport() async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                dialogMessenger.showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do báo cáo.')),
                );
                return;
              }

              setDialogState(() => isSubmitting = true);
              final success = await community.createReport(
                    productId: product.id,
                    reason: reason,
                  );
              if (!mounted) return;
              dialogNavigator.pop(success);
            }

            return AlertDialog(
              title: const Text('Báo cáo sản phẩm'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Nội dung không đúng',
                        'Giá gây hiểu nhầm',
                        'Nghi ngờ lừa đảo',
                        'Sản phẩm cấm',
                      ].map((reason) {
                        return ActionChip(
                          label: Text(reason),
                          onPressed: isSubmitting
                              ? null
                              : () => reasonController.text = reason,
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      enabled: !isSubmitting,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Lý do báo cáo',
                        hintText: 'Mô tả vấn đề bạn phát hiện ở bài đăng này',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => dialogNavigator.pop(false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submitReport,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text(isSubmitting ? 'Đang gửi...' : 'Gửi báo cáo'),
                ),
              ],
            );
          },
        );
      },
    );

    reasonController.dispose();

    if (!mounted || created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created
              ? 'Đã gửi báo cáo. Quản trị viên sẽ xem xét bài đăng này.'
              : 'Không thể gửi báo cáo lúc này. Vui lòng thử lại sau.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final product = provider.currentProduct;

        if (provider.isLoading && product == null) {
          return Scaffold(appBar: AppBar(), body: const LoadingWidget());
        }
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyWidget(message: 'Không tìm thấy sản phẩm'),
          );
        }

        final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
        final auth = context.read<AuthProvider>();
        final isOwner = auth.user?.id == product.userId;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildImageSliver(product),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (product.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${product.category!.icon} ${product.category!.name}',
                                style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            timeago.format(product.createdAt, locale: 'vi'),
                            style: const TextStyle(color: AppTheme.textMedium, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatter.format(product.price),
                        style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (product.location != null && product.location!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              product.location!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(product.description, style: const TextStyle(fontSize: 14, height: 1.6)),
                      const Divider(height: 24),
                      if (product.seller != null) ...[
                        _buildSellerInfo(product.seller!, isOwner),
                        const Divider(height: 24),
                        _buildReviewSection(product, auth, isOwner),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isOwner
              ? _buildOwnerActions(product.id)
              : auth.isAuthenticated
                  ? _buildBuyerActions(product, auth)
                  : _buildGuestAction(),
        );
      },
    );
  }

  Widget _buildImageSliver(product) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        Consumer<ProductProvider>(
          builder: (ctx, p, _) => IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite ? AppTheme.primaryColor : null,
            ),
            onPressed: context.read<AuthProvider>().isAuthenticated
                ? () => p.toggleFavorite(product.id)
                : () => context.push('/login'),
          ),
        ),
        IconButton(icon: const Icon(Icons.share), onPressed: () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: (product.images.isNotEmpty)
            ? Stack(
                children: [
                  PageView.builder(
                    itemCount: product.images.length,
                    onPageChanged: (i) => setState(() => _imageIndex = i),
                    itemBuilder: (ctx, i) => kIsWeb
                        ? Image.network(
                            product.images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, st) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 64, color: Colors.grey),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: product.images[i],
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Container(color: Colors.grey[200]),
                            errorWidget: (ctx, url, err) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 64, color: Colors.grey),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_imageIndex + 1}/${product.images.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildSellerInfo(seller, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Người bán', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage: seller.avatar != null ? NetworkImage(seller.avatar!) : null,
              child: seller.avatar == null
                  ? Text(seller.name.isNotEmpty ? seller.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seller.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (seller.address != null)
                    Text('📍 ${seller.address}',
                        style: const TextStyle(color: AppTheme.textMedium, fontSize: 13)),
                ],
              ),
            ),
            if (!isOwner)
              TextButton.icon(
                icon: const Icon(Icons.store),
                label: const Text('Xem gian hàng'),
                onPressed: () {},
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewSection(ProductModel product, AuthProvider auth, bool isOwner) {
    return Consumer<CommunityProvider>(
      builder: (context, community, _) {
        final summary = community.reviewSummary;
        final reviews = community.sellerReviews;
        final currentUserId = auth.user?.id;
        final hasReviewed = currentUserId != null &&
            reviews.any((review) => review.productId == product.id && review.reviewerId == currentUserId);
        final canReview = auth.isAuthenticated && !isOwner;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Đánh giá người bán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (canReview)
                  OutlinedButton.icon(
                    onPressed: community.isLoading || hasReviewed
                        ? null
                        : () => _showReviewDialog(product),
                    icon: Icon(hasReviewed ? Icons.check_circle : Icons.rate_review),
                    label: Text(hasReviewed ? 'Đã đánh giá' : 'Viết đánh giá'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade100),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildRatingStars(summary.averageRating),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      summary.totalReviews == 0
                          ? 'Người bán này chưa có đánh giá nào.'
                          : '${summary.totalReviews} đánh giá từ người mua trước đó.',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (community.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (reviews.isEmpty)
              const Text(
                'Chưa có nhận xét chi tiết cho người bán này.',
                style: TextStyle(color: AppTheme.textMedium),
              )
            else
              Column(
                children: reviews
                    .take(3)
                    .map((review) => _buildReviewCard(review))
                    .toList(growable: false),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final reviewerName = review.reviewerName ?? 'Người dùng';
    final reviewerAvatar = review.reviewerAvatar;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: reviewerAvatar != null ? NetworkImage(reviewerAvatar) : null,
                child: reviewerAvatar == null
                    ? Text(
                        reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      timeago.format(review.createdAt, locale: 'vi'),
                      style: const TextStyle(color: AppTheme.textMedium, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _buildRatingStars(review.rating.toDouble(), size: 16),
            ],
          ),
          if ((review.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        IconData icon = Icons.star_border;
        if (rating >= starNumber) {
          icon = Icons.star;
        } else if (rating >= starNumber - 0.5) {
          icon = Icons.star_half;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(icon, size: size, color: Colors.amber),
        );
      }),
    );
  }

  Widget _buildBuyerActions(ProductModel product, AuthProvider auth) {
    final isSold = product.status == ProductStatus.sold;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Nhắn tin'),
                  onPressed: () => context.push('/chat/${product.userId}/${product.id}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(isSold ? Icons.lock_clock : Icons.shopping_bag_outlined),
                  label: Text(isSold ? 'Đã bán' : 'Mua ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSold ? Colors.grey : AppTheme.primaryColor,
                  ),
                  onPressed: isSold
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận mua sản phẩm'),
                              content: const Text(
                                'Bạn muốn gửi yêu cầu mua sản phẩm này tới người bán?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Huỷ'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Gửi yêu cầu mua'),
                                ),
                              ],
                            ),
                          );

                          if (confirm != true || !mounted) return;

                          if (!mounted) return;
                          context.push('/payment/${product.id}');
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showReportDialog(product),
              icon: const Icon(Icons.flag_outlined, color: Colors.redAccent),
              label: const Text(
                'Báo cáo bài đăng này',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions(int productId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Chỉnh sửa'),
              onPressed: () => context.push('/product/edit/$productId'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Đánh dấu đã bán'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                context.read<ProductProvider>().updateProduct(id: productId, status: 'sold');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestAction() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () => context.push('/login'),
        child: const Text('Đăng nhập để liên hệ người bán'),
      ),
    );
  }
}
