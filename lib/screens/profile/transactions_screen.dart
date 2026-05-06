import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/models/transaction_model.dart';
import 'package:secondhand_app/providers/transaction_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadBuying();
      context.read<TransactionProvider>().loadSelling();
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
        title: const Text('Giao dịch mua bán'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mua của tôi'),
            Tab(text: 'Bán của tôi'),
          ],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.buying.isEmpty && provider.selling.isEmpty) {
            return const LoadingWidget();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.buying, isSellerView: false),
              _buildList(provider.selling, isSellerView: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<TransactionModel> items, {required bool isSellerView}) {
    if (items.isEmpty) {
      return EmptyWidget(
        message: isSellerView ? 'Chưa có yêu cầu mua nào' : 'Bạn chưa có giao dịch mua nào',
        icon: Icons.receipt_long_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (isSellerView) {
          await context.read<TransactionProvider>().loadSelling();
        } else {
          await context.read<TransactionProvider>().loadBuying();
        }
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (ctx, i) => _TransactionItem(
          item: items[i],
          isSellerView: isSellerView,
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionModel item;
  final bool isSellerView;

  const _TransactionItem({
    required this.item,
    required this.isSellerView,
  });

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/product/${item.productId}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.productImage != null && item.productImage!.isNotEmpty
                    ? Image.network(
                        item.productImage!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      priceFmt.format(item.productPrice),
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSellerView
                          ? 'Người mua: ${item.buyerName ?? 'Không rõ'}'
                          : 'Người bán: ${item.sellerName ?? 'Không rõ'}',
                      style: const TextStyle(color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(item.status),
                        const SizedBox(width: 8),
                        if (item.status == TransactionStatus.pending)
                          Text(
                            'Chờ người bán xác nhận',
                            style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSellerView && item.status == TransactionStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final txProvider = context.read<TransactionProvider>();
                            final ok = await txProvider.confirmTransaction(item.id);
                            
                            if (!context.mounted) return;
                            
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('✅ Giao dịch xác nhận thành công! Số dư ví đã cập nhật.'),
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(txProvider.error ?? 'Xác nhận thất bại, vui lòng thử lại.'),
                                  duration: const Duration(seconds: 4),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _showRejectDialog(context, item.id);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _statusBadge(TransactionStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case TransactionStatus.completed:
        bg = Colors.green.withOpacity(0.15);
        fg = Colors.green;
        text = 'Hoàn tất';
        break;
      case TransactionStatus.cancelled:
        bg = Colors.grey.withOpacity(0.2);
        fg = Colors.grey[700]!;
        text = 'Đã huỷ';
        break;
      default:
        bg = Colors.orange.withOpacity(0.15);
        fg = Colors.orange[700]!;
        text = 'Chờ xác nhận';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _showRejectDialog(BuildContext context, int transactionId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối yêu cầu mua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc muốn từ chối yêu cầu mua này?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do (tùy chọn)',
                hintText: 'Nhập lý do từ chối...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              final txProvider = context.read<TransactionProvider>();
              final ok = await txProvider.rejectTransaction(
                transactionId,
                reason: reasonController.text.trim(),
              );
              
              if (!context.mounted) return;
              
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Đã từ chối yêu cầu mua. Người mua đã được thông báo.'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(txProvider.error ?? 'Từ chối thất bại, vui lòng thử lại.'),
                    duration: const Duration(seconds: 4),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}
