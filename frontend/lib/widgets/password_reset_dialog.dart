import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

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
  final _answerController = TextEditingController();
  String _selectedQuestion = kSecurityQuestions.first;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _fetchedQuestion;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
      if (!widget.isSettingUp) {
        _fetchQuestion(widget.initialEmail!);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestion(String email) async {
    final q = await _storageService.getSecurityQuestion(email);
    if (mounted) {
      setState(() {
        _fetchedQuestion = q;
        if (q == null) {
          _errorMessage = 'No registered security question found for $email. Please register first.';
        } else {
          _errorMessage = null;
        }
      });
    }
  }

  Future<void> _handleSaveSecurityQuestion() async {
    final email = _emailController.text.trim();
    final answer = _answerController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (answer.isEmpty) {
      setState(() => _errorMessage = 'Please provide an answer to your security question.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _storageService.saveSecurityQuestion(email, _selectedQuestion, answer);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  Future<void> _handleVerifyAndReset() async {
    final email = _emailController.text.trim();
    final answer = _answerController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (answer.isEmpty) {
      setState(() => _errorMessage = 'Please provide an answer to your security question.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final q = await _storageService.getSecurityQuestion(email);
    if (q == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'This email is not registered with Careerly. Please check your email or register an account.';
        });
      }
      return;
    }

    final isCorrect = await _storageService.verifySecurityAnswer(email, answer);
    if (!isCorrect) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Incorrect answer to your security question. Please try again.';
        });
      }
      return;
    }

    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final sent = await authProvider.resetPassword(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (sent) {
          _isSuccess = true;
        } else {
          _errorMessage = authProvider.errorMessage ?? 'Failed to send password reset email. Please ensure your Firebase Authentication is configured.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _isSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
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
        Text(
          widget.isSettingUp ? 'Security Question Saved' : 'Password Reset Email Sent',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          widget.isSettingUp
              ? 'Your security question has been securely configured for ${_emailController.text}.'
              : 'A secure password reset link has been dispatched to ${_emailController.text}. Please check your inbox and follow the link to create your new password.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppTheme.slate600, height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    final activeQuestion = widget.isSettingUp
        ? _selectedQuestion
        : (_fetchedQuestion ?? (_emailController.text.contains('@') ? 'No registered security question found for this email.' : 'Enter your registered email address above.'));

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
                    color: AppTheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security_rounded, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isSettingUp ? 'Set Security Question' : 'Reset Password',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
        Text(
          widget.isSettingUp
              ? 'Choose a secret security question to verify your identity whenever you need to reset your password.'
              : 'Answer your registered security question to receive a verified password reset link to your email.',
          style: const TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.4),
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
            labelText: 'Account Email',
            hintText: 'student@example.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.slate400),
          ),
          onChanged: (val) {
            if (!widget.isSettingUp && val.contains('@')) {
              _fetchQuestion(val);
            }
          },
        ),
        const SizedBox(height: 16),
        if (widget.isSettingUp) ...[
          const Text(
            'Select Security Question',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: DropdownButton<String>(
              value: _selectedQuestion,
              isExpanded: true,
              underline: const SizedBox(),
              items: kSecurityQuestions
                  .map((q) => DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedQuestion = val);
              },
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security Question:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.slate500),
                ),
                const SizedBox(height: 4),
                Text(
                  activeQuestion,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: (!widget.isSettingUp && _fetchedQuestion == null) ? AppTheme.slate500 : AppTheme.slate800,
                    fontStyle: (!widget.isSettingUp && _fetchedQuestion == null) ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _answerController,
          decoration: const InputDecoration(
            labelText: 'Your Secret Answer',
            hintText: 'Enter your answer here',
            prefixIcon: Icon(Icons.key_outlined, color: AppTheme.slate400),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : (widget.isSettingUp ? _handleSaveSecurityQuestion : _handleVerifyAndReset),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(widget.isSettingUp ? 'Save Security Question' : 'Verify & Send Reset Link'),
          ),
        ),
      ],
    );
  }
}
