import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:secondhand_app/config/theme.dart';
import 'package:secondhand_app/providers/auth_provider.dart';
import 'package:secondhand_app/widgets/common/app_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? email;

  const VerifyEmailScreen({super.key, this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown(seconds: 30);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = widget.email ?? auth.pendingVerificationEmail ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Xác minh email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 36, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kiểm tra hộp thư của bạn',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                email.isEmpty
                    ? 'Chúng tôi đã gửi email xác minh. Sau khi xác minh xong, hãy quay lại đăng nhập.'
                    : 'Chúng tôi đã gửi email xác minh tới $email. Hãy mở Gmail và bấm vào liên kết xác minh.',
                style: const TextStyle(color: AppTheme.textMedium, height: 1.6),
              ),
              const SizedBox(height: 28),
              AppButton(
                text: _isChecking ? 'Đang kiểm tra...' : 'Tôi đã xác minh',
                onPressed: _isChecking ? null : _checkVerification,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: (_isResending || _resendCooldown > 0) ? null : _resendEmail,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: Text(
                  _isResending
                      ? 'Đang gửi lại...'
                      : _resendCooldown > 0
                          ? 'Gửi lại sau ${_resendCooldown}s'
                          : 'Gửi lại email xác minh',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Firebase xác minh qua liên kết trong Gmail, không nhập mã OTP trực tiếp trên app.',
                style: TextStyle(color: AppTheme.textMedium, height: 1.5),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/login${email.isNotEmpty ? '?email=$email' : ''}'),
                child: const Text('Quay lại đăng nhập'),
              ),
              if (!auth.isEmailVerificationEnabled) ...[
                const SizedBox(height: 16),
                const Text(
                  'Firebase chưa được cấu hình trong môi trường chạy hiện tại, nên xác minh email đang bị tắt.',
                  style: TextStyle(color: Colors.orange, height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    final verified = await context.read<AuthProvider>().checkEmailVerified();
    if (!mounted) return;
    setState(() => _isChecking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified
              ? 'Email đã được xác minh. Bạn có thể đăng nhập.'
              : 'Email vẫn chưa được xác minh. Hãy kiểm tra lại Gmail của bạn.',
        ),
      ),
    );
    if (verified) {
      final email = widget.email ?? '';
      context.go('/login${email.isNotEmpty ? '?email=$email' : ''}');
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    final success = await context.read<AuthProvider>().resendVerificationEmail();
    if (!mounted) return;
    setState(() => _isResending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã gửi lại email xác minh.'
              : 'Không thể gửi lại email xác minh.',
        ),
      ),
    );
    if (success) {
      _startCooldown(seconds: 30);
    }
  }

  void _startCooldown({required int seconds}) {
    if (!mounted) return;
    setState(() => _resendCooldown = seconds);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendCooldown <= 0) return false;
      setState(() => _resendCooldown -= 1);
      return _resendCooldown > 0;
    });
  }
}