import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/models/product_model.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/providers/payment_provider.dart';
import 'package:secondhand_app/providers/product_provider.dart';
import 'package:secondhand_app/providers/transaction_provider.dart';
import 'package:secondhand_app/services/order_service.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class PaymentScreen extends StatefulWidget {
  final int productId;

  const PaymentScreen({super.key, required this.productId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'WALLET'; // Default to wallet payment
  final TextEditingController _shippingAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProductProvider>().loadProductDetail(widget.productId);
      if (!mounted) return;
      await context.read<PaymentProvider>().loadLinkedBankAccount();

      final authProvider = context.read<AuthProvider>();
      _shippingAddressController.text = authProvider.user?.address ?? '';
    });
  }

  @override
  void dispose() {
    _shippingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, PaymentProvider>(
      builder: (context, productProvider, paymentProvider, _) {
        final ProductModel? product = productProvider.currentProduct;

        if (productProvider.isLoading && product == null) {
          return Scaffold(
              appBar: AppBar(title: const Text('Thanh toán')),
              body: const LoadingWidget());
        }

        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thanh toán')),
            body: const Center(child: Text('Không tìm thấy sản phẩm')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Thanh toán')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin sản phẩm',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Sản phẩm: ${product.title}'),
                      const SizedBox(height: 4),
                      Text('Giá: ${product.price.toStringAsFixed(0)} ₫'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Phương thức thanh toán',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      RadioListTile<String>(
                        value: 'WALLET',
                        groupValue: _method,
                        onChanged: (v) =>
                            setState(() => _method = v ?? 'WALLET'),
                        title: Row(
                          children: [
                            Icon(Icons.account_balance_wallet,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            const Text('Ví của tôi'),
                          ],
                        ),
                        subtitle: const Text('Thanh toán ngay bằng số dư ví'),
                      ),
                      RadioListTile<String>(
                        value: 'VNPAY',
                        groupValue: _method,
                        onChanged: (v) =>
                            setState(() => _method = v ?? 'VNPAY'),
                        title: const Text('VNPay'),
                      ),
                      RadioListTile<String>(
                        value: 'MOMO',
                        groupValue: _method,
                        onChanged: (v) => setState(() => _method = v ?? 'MOMO'),
                        title: const Text('MoMo'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Địa chỉ nhận hàng',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _shippingAddressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Nhập địa chỉ giao hàng',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: paymentProvider.isLoading
                    ? null
                    : () => _payNow(product.id),
                child: const Text('Thanh toán'),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _payNow(int productId) async {
    final paymentProvider = context.read<PaymentProvider>();
    final txProvider = context.read<TransactionProvider>();

    // Nếu chọn thanh toán bằng ví (tạo yêu cầu mua, chờ người bán xác nhận)
    if (_method == 'WALLET') {
      final productProvider = context.read<ProductProvider>();
      final product = productProvider.currentProduct;

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin sản phẩm')),
        );
        return;
      }

      // Xác nhận gửi yêu cầu mua
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xác nhận yêu cầu mua'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sản phẩm: ${product.title}'),
              Text('Số tiền: ${product.price.toStringAsFixed(0)} ₫'),
              const SizedBox(height: 8),
              const Text(
                  'Yêu cầu mua sẽ được gửi tới người bán. Sau khi người bán chấp nhận, tiền sẽ được trừ từ ví của bạn.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Gửi yêu cầu'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Kiểm tra địa chỉ nhận hàng
      final shippingAddress = _shippingAddressController.text.trim();
      if (shippingAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng')),
        );
        return;
      }

      // Gọi API tạo yêu cầu mua (wallet)
      final ok = await txProvider.createTransaction(
        productId,
        paymentMethod: 'WALLET',
        shippingAddress: shippingAddress,
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Yêu cầu mua đã gửi. Vui lòng đợi người bán xác nhận.')),
        );
        context.push('/transactions');
      } else {
        final errorText = txProvider.error ?? 'Tạo yêu cầu mua thất bại';
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Lỗi tạo giao dịch'),
            content: SingleChildScrollView(
              child: Text(errorText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: errorText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã sao chép lỗi')),
                  );
                },
                child: const Text('Sao chép'),
              ),
            ],
          ),
        );
      }

      return;
    }

    // Xử lý các phương thức thanh toán khác (VNPAY, MOMO, BANK_TRANSFER)
    final created = await paymentProvider.createPayment(
      productId: productId,
      paymentMethod: _method,
    );

    if (!mounted) return;
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo phiên thanh toán')),
      );
      return;
    }

    final payment = created['payment'] as Map<String, dynamic>;
    final paymentId = int.tryParse(payment['id'].toString()) ?? 0;
    final paymentUrl = created['payment_url']?.toString() ?? '';
    final bankTransfer = created['bank_transfer'] as Map<String, dynamic>?;
    final qrUrl = bankTransfer?['qr_url']?.toString() ?? '';

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_method == 'BANK_TRANSFER'
            ? 'Xác nhận đã chuyển khoản'
            : 'Đi tới cổng thanh toán'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_method == 'BANK_TRANSFER' && qrUrl.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin chuyển khoản:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (bankTransfer?['bank_name'] != null)
                        Text('Ngân hàng: ${bankTransfer!['bank_name']}'),
                      if (bankTransfer?['account_name'] != null)
                        Text('Chủ tài khoản: ${bankTransfer!['account_name']}'),
                      if (bankTransfer?['account_number'] != null)
                        Text('Số tài khoản: ${bankTransfer!['account_number']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mã QR của người bán:',
                  style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    qrUrl,
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 250,
                        height: 250,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Text('Không thể tải mã QR'),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 250,
                        height: 250,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hướng dẫn:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Mở ứng dụng ngân hàng của bạn\n2. Chọn quét mã QR\n3. Quét mã QR trên để chuyển khoản\n4. Bấm "Đã thanh toán" sau khi hoàn tất',
                  style: TextStyle(fontSize: 13),
                ),
              ] else if (_method == 'BANK_TRANSFER') ...[
                const Text('Không thể tải mã QR của người bán.'),
                const SizedBox(height: 12),
                const Text('Vui lòng liên hệ người bán hoặc thử lại.'),
              ] else
                Text(
                  paymentUrl.isEmpty
                      ? 'Phiên thanh toán đã tạo. Bạn muốn giả lập thanh toán thành công không?'
                      : 'Link sandbox: $paymentUrl\n\nBấm "Đã thanh toán" để giả lập callback thành công.',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Đã thanh toán')),
        ],
      ),
    );

    if (proceed != true || paymentId <= 0) return;

    final shippingAddress = _shippingAddressController.text.trim();
    if (shippingAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng')),
      );
      return;
    }

    final done = await paymentProvider.markPaymentSuccess(
      paymentId: paymentId,
      productId: productId,
      shippingAddress: shippingAddress,
    );

    if (!mounted) return;
    if (done == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xử lý thanh toán thất bại')),
      );
      return;
    }

    await txProvider.loadBuying();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Thanh toán thành công. Đơn mua đang chờ người bán xác nhận.')),
    );
    context.push('/transactions');
  }
}
