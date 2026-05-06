import 'package:flutter/material.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    // TODO: Implement API call to get dashboard data
    setState(() {
      _isLoading = false;
      _dashboardData = {
        'total_users': 150,
        'total_orders': 89,
        'total_revenue': 45600000,
        'total_wallet_balance': 12300000,
        'total_pending_balance': 5600000,
        'active_disputes': 3,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _dashboardData!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Users',
                  '${stats['total_users']}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Total Orders',
                  '${stats['total_orders']}',
                  Icons.shopping_cart,
                  Colors.green,
                ),
                _buildStatCard(
                  'Total Revenue',
                  '${(stats['total_revenue'] / 1000000).toStringAsFixed(1)}Mđ',
                  Icons.attach_money,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Active Disputes',
                  '${stats['active_disputes']}',
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Wallet Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Overview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWalletItem(
                            'Total Balance',
                            '${(stats['total_wallet_balance'] / 1000000).toStringAsFixed(1)}Mđ',
                            Icons.account_balance_wallet,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildWalletItem(
                            'Pending Balance',
                            '${(stats['total_pending_balance'] / 1000000).toStringAsFixed(1)}Mđ',
                            Icons.hourglass_empty,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              children: [
                _buildActionCard(
                  'Freeze User',
                  'Block user transactions',
                  Icons.block,
                  Colors.red,
                  () => _showFreezeUserDialog(),
                ),
                _buildActionCard(
                  'Resolve Dispute',
                  'Handle user disputes',
                  Icons.gavel,
                  Colors.orange,
                  () => _showResolveDisputeDialog(),
                ),
                _buildActionCard(
                  'Approve Withdrawal',
                  'Process withdrawal requests',
                  Icons.check_circle,
                  Colors.green,
                  () => _showWithdrawalDialog(),
                ),
                _buildActionCard(
                  'Adjust Balance',
                  'Manual balance adjustment',
                  Icons.tune,
                  Colors.blue,
                  () => _showAdjustBalanceDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFreezeUserDialog() {
    final userIdController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Freeze User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter user ID to freeze',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter freeze reason',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement freeze user API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User frozen successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Freeze User'),
          ),
        ],
      ),
    );
  }

  void _showResolveDisputeDialog() {
    final disputeIdController = TextEditingController();
    final winnerController = TextEditingController();
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: disputeIdController,
              decoration: const InputDecoration(
                labelText: 'Dispute ID',
                hintText: 'Enter dispute ID',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Winner',
                hintText: 'Select winner',
              ),
              items: const [
                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                DropdownMenuItem(value: 'seller', child: Text('Seller')),
              ],
              value: winnerController.text.isEmpty ? null : winnerController.text,
              onChanged: (value) {
                winnerController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution',
                hintText: 'Enter resolution details',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement resolve dispute API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dispute resolved successfully')),
              );
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog() {
    final transactionIdController = TextEditingController();
    final statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve/Reject Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: transactionIdController,
              decoration: const InputDecoration(
                labelText: 'Transaction ID',
                hintText: 'Enter withdrawal transaction ID',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Action',
                hintText: 'Select action',
              ),
              items: const [
                DropdownMenuItem(value: 'APPROVED', child: Text('Approve')),
                DropdownMenuItem(value: 'REJECTED', child: Text('Reject')),
              ],
              value: statusController.text.isEmpty ? null : statusController.text,
              onChanged: (value) {
                statusController.text = value ?? '';
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement approve withdrawal API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Withdrawal processed successfully')),
              );
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _showAdjustBalanceDialog() {
    final userIdController = TextEditingController();
    final amountController = TextEditingController();
    final typeController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter user ID',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter amount',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type',
                hintText: 'Select adjustment type',
              ),
              items: const [
                DropdownMenuItem(value: 'ADD', child: Text('Add Balance')),
                DropdownMenuItem(value: 'SUBTRACT', child: Text('Subtract Balance')),
              ],
              value: typeController.text.isEmpty ? null : typeController.text,
              onChanged: (value) {
                typeController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter adjustment reason',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement adjust balance API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Balance adjusted successfully')),
              );
            },
            child: const Text('Adjust'),
          ),
        ],
      ),
    );
  }
}
