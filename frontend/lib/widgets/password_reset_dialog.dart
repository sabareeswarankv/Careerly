import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

const List<String> kSecurityQuestions = [
  'What was the name of your first school?',
  'What is your favorite programming language?',
  'In what city was your high school located?',
  'What was the model of your first computer or laptop?',
  'What was your dream career when you were a child?',
];

class PasswordResetDialog extends StatefulWidget {
  final String? initialEmail;
  final bool isSettingUp;

  const PasswordResetDialog({
    super.key,
    this.initialEmail,
    this.isSettingUp = false,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialEmail,
    bool isSettingUp = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PasswordResetDialog(
        initialEmail: initialEmail,
        isSettingUp: isSettingUp,
      ),
    );
  }

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.resetPassword(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (sent) {
          _isSuccess = true;
        } else {
          _errorMessage = authProvider.errorMessage ??
              'Failed to send password reset email. Please ensure your email is registered.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _isSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final email = _emailController.text.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.success.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: AppTheme.success, size: 36),
        ),
        const SizedBox(height: 20),
        const Text(
          'Password Reset Email Sent',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'A secure password reset link has been dispatched to $email. Please check your inbox and follow the link to choose a new password.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.slate600, height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Sign In'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.slate400),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter your registered email address and we will send you a secure link to reset your password.',
          style: TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.4),
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.error.withAlpha(60)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppTheme.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Registered Email',
            hintText: 'student@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.slate400),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendResetLink,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send Password Reset Link'),
          ),
        ),
      ],
    );
  }
}
