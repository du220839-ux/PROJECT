import 'package:flutter/material.dart';
import 'package:secondhand_app/models/order_model.dart';
import 'package:secondhand_app/services/order_service.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      final order = await _orderService.getOrderDetail(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsDelivered() async {
    if (_order == null) return;

    try {
      await _orderService.markAsDelivered(orderId: _order!.orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái giao hàng')),
      );
      _loadOrderDetail(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _confirmReceipt() async {
    if (_order == null) return;

    try {
      await _orderService.completeOrder(orderId: _order!.orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xác nhận nhận hàng')),
      );
      _loadOrderDetail(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _requestRefund() async {
    if (_order == null) return;

    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khiếu nại'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng nêu lý do khiếu nại:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Lý do khiếu nại...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final auth = context.read<AuthProvider>();
                await _orderService.createDispute(
                  orderId: _order!.orderId,
                  complainantId: auth.user!.id,
                  reason: reasonController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi khiếu nại')),
                );
                _loadOrderDetail();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'Chờ thanh toán';
        break;
      case 'PAID_HOLDING':
        color = Colors.blue;
        label = 'Đã thanh toán (giữ tiền)';
        break;
      case 'SHIPPING':
        color = Colors.purple;
        label = 'Đang giao hàng';
        break;
      case 'DELIVERED':
        color = Colors.green;
        label = 'Đã giao hàng';
        break;
      case 'COMPLETED':
        color = Colors.teal;
        label = 'Hoàn thành';
        break;
      case 'REFUNDING':
        color = Colors.red;
        label = 'Đang hoàn tiền';
        break;
      case 'REFUNDED':
        color = Colors.grey;
        label = 'Đã hoàn tiền';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrderDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final auth = context.read<AuthProvider>();
    final isBuyer = auth.user?.id == _order!.buyerId;
    final isSeller = auth.user?.id == _order!.sellerId;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${_order!.orderId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(_order!.status),
              ],
            ),
            const SizedBox(height: 16),

            // Product info
            if (_order!.productImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_order!.productImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            
            Text(
              _order!.productName ?? 'Sản phẩm',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Order details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giá sản phẩm: ${_order!.totalPrice.toStringAsFixed(0)}đ'),
                    if (_order!.shippingFee > 0)
                      Text('Phí vận chuyển: ${_order!.shippingFee.toStringAsFixed(0)}đ'),
                    const Divider(),
                    Text(
                      'Tổng cộng: ${(_order!.totalPrice + _order!.shippingFee).toStringAsFixed(0)}đ',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            if (_order!.shippingAddress != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Địa chỉ giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_order!.shippingAddress!),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lịch sử:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildTimelineItem('Đặt hàng', _order!.createdAt),
                    if (_order!.deliveryAt != null)
                      _buildTimelineItem('Giao hàng', _order!.deliveryAt!),
                    if (_order!.autoCompletedAt != null)
                      _buildTimelineItem('Tự động hoàn tất', _order!.autoCompletedAt!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            if (_order!.canShip && isSeller)
              ElevatedButton(
                onPressed: _markAsDelivered,
                child: const Text('Xác nhận đã giao hàng'),
              ),
            
            if (_order!.canConfirmReceipt && isBuyer)
              ElevatedButton(
                onPressed: _confirmReceipt,
                child: const Text('Đã nhận được hàng'),
              ),
            
            if (_order!.canRequestRefund && isBuyer)
              OutlinedButton(
                onPressed: _requestRefund,
                child: const Text('Khiếu nại'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text('$title - ${date.day}/${date.month}/${date.year}'),
        ],
      ),
    );
  }
}
