import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/providers/payment_provider.dart';
import 'package:secondhand_app/widgets/common/loading_widget.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  int? _bankId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PaymentProvider>();
      await provider.loadBanks();
      if (!mounted) return;
      await provider.loadLinkedBankAccount();
      if (!mounted) return;
      final linked = provider.linkedAccount;
      if (linked != null) {
        setState(() {
          _bankId = int.tryParse(linked['bank_id'].toString());
          _accountNumberCtrl.text = linked['account_number']?.toString() ?? '';
          _accountNameCtrl.text = linked['account_name']?.toString() ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final banks = provider.banks;

        return Scaffold(
          appBar: AppBar(title: const Text('Liên kết ngân hàng')),
          body: provider.isLoading && banks.isEmpty
              ? const LoadingWidget()
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _bankId,
                          decoration: const InputDecoration(labelText: 'Ngân hàng'),
                          items: banks
                              .map(
                                (b) => DropdownMenuItem<int>(
                                  value: int.tryParse(b['id'].toString()),
                                  child: Text('${b['bank_name']} (${b['bank_code']})'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _bankId = v),
                          validator: (v) => v == null ? 'Vui lòng chọn ngân hàng' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _accountNumberCtrl,
                          decoration: const InputDecoration(labelText: 'Số tài khoản'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập số tài khoản' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _accountNameCtrl,
                          decoration: const InputDecoration(labelText: 'Tên chủ tài khoản'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên chủ tài khoản' : null,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _save,
                            child: const Text('Lưu liên kết'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _bankId == null) return;

    final ok = await context.read<PaymentProvider>().linkBankAccount(
      bankId: _bankId!,
      accountNumber: _accountNumberCtrl.text.trim(),
      accountName: _accountNameCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Liên kết ngân hàng thành công' : 'Liên kết ngân hàng thất bại'),
      ),
    );
  }
}
