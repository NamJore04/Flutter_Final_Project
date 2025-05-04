import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement actual password reset logic
        await Future.delayed(
            const Duration(seconds: 2)); // Simulate network request

        if (mounted) {
          setState(() {
            _resetSent = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đặt lại mật khẩu thất bại: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _backToLogin() {
    context.goNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _resetSent ? _buildResetSentView() : _buildResetForm(),
            if (_isLoading)
              const FullScreenLoading(message: 'Đang gửi yêu cầu...'),
          ],
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            const Icon(
              Icons.lock_reset,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Đặt lại mật khẩu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'Vui lòng nhập email của bạn. Chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Email field
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Nhập email của bạn',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: _validateEmail,
            ),
            const SizedBox(height: 32),

            // Reset password button
            CustomButton(
              text: 'Gửi liên kết đặt lại',
              onPressed: _resetPassword,
              isLoading: _isLoading,
              isFullWidth: true,
            ),
            const SizedBox(height: 16),

            // Back to login link
            TextButton(
              onPressed: _backToLogin,
              child: const Text('Quay lại đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetSentView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Đã gửi email đặt lại mật khẩu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Chúng tôi đã gửi liên kết đến ${_emailController.text}. Vui lòng kiểm tra hộp thư đến và làm theo hướng dẫn để đặt lại mật khẩu của bạn.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Quay lại đăng nhập',
              onPressed: _backToLogin,
              isFullWidth: true,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _resetSent = false;
                });
              },
              child: const Text('Sửa email'),
            ),
          ],
        ),
      ),
    );
  }
}
