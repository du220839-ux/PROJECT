import 'package:flutter/material.dart';
import 'package:secondhand_app/models/wallet_model.dart';
import 'package:secondhand_app/services/wallet_service.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final auth = context.read<AuthProvider>();
      if (auth.user == null) {
        print('❌ No authenticated user');
        return;
      }

      print('✅ Loading wallet data for user: ${auth.user!.id}');
      final data = await _walletService.getWalletWithTransactions();
      print('✅ Wallet data loaded: ${data.keys}');
      
      setState(() {
        _wallet = data['wallet'];
        _transactions = data['transactions'];
        _isLoading = false;
      });
      print('✅ Wallet UI updated');
    } catch (e) {
      print('❌ Load wallet error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showTopUpDialog() {
    final amountController = TextEditingController();
    final paymentMethodController = TextEditingController(text: 'BANK_TRANSFER');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nạp tiền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                hintText: 'Nhập số tiền cần nạp',
                prefixText: 'đ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paymentMethodController,
              decoration: const InputDecoration(
                labelText: 'Phương thức',
                hintText: 'BANK_TRANSFER, CREDIT_CARD, EWALLET',
              ),
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
                final result = await _walletService.topUp(
                  amount: double.parse(amountController.text),
                  paymentMethod: paymentMethodController.text,
                  paymentReference: 'Wallet Topup',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nạp tiền thành công')),
                );
                _loadWalletData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Nạp tiền'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    final toUserIdController = TextEditingController();
    final amountController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chuyển tiền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: toUserIdController,
              decoration: const InputDecoration(
                labelText: 'ID người nhận',
                hintText: 'Nhập ID người nhận',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                hintText: 'Nhập số tiền cần chuyển',
                prefixText: 'đ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Lời nhắn',
                hintText: 'Nhập lời nhắn (tùy chọn)',
              ),
              maxLines: 2,
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
                await _walletService.transfer(
                  toUserId: int.parse(toUserIdController.text),
                  amount: double.parse(amountController.text),
                  message: messageController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chuyển tiền thành công')),
                );
                _loadWalletData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: $e')),
                );
              }
            },
            child: const Text('Chuyển tiền'),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(TransactionModel transaction) {
    if (transaction.isSuccess) {
      return (transaction.isTopUp || transaction.isTransferIn || transaction.isRefund || transaction.isPayout) 
          ? Colors.green 
          : Colors.red;
    } else if (transaction.isPending) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
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
        appBar: AppBar(title: const Text('Ví của tôi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWalletData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWalletData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Wallet Balance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số dư ví',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_wallet!.walletBalance.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đang giữ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_wallet!.pendingBalance.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tổng cộng',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${_wallet!.totalBalance.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showTopUpDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Nạp tiền'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showTransferDialog,
                      icon: const Icon(Icons.send),
                      label: const Text('Chuyển tiền'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transactions List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử giao dịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _transactions.isEmpty
                    ? const Center(
                        child: Text('Chưa có giao dịch nào'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getTransactionColor(transaction).withOpacity(0.2),
                                child: Icon(
                                  _getTransactionIcon(transaction),
                                  color: _getTransactionColor(transaction),
                                ),
                              ),
                              title: Text(transaction.displayType),
                              subtitle: Text(
                                '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    transaction.displayAmount,
                                    style: TextStyle(
                                      color: _getTransactionColor(transaction),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    transaction.displayStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionModel transaction) {
    switch (transaction.type) {
      case 'TOPUP':
        return Icons.add_circle;
      case 'WITHDRAW':
        return Icons.remove_circle;
      case 'TRANSFER_IN':
        return Icons.call_received;
      case 'TRANSFER_OUT':
        return Icons.call_made;
      case 'PAYMENT':
        return Icons.shopping_cart;
      case 'REFUND':
        return Icons.refresh;
      case 'PAYOUT':
        return Icons.account_balance_wallet;
      default:
        return Icons.receipt;
    }
  }
}
