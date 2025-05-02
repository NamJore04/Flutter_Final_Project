import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/features/auth/presentation/pages/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement actual login logic
        await Future.delayed(
            const Duration(seconds: 2)); // Simulate network request

        // Navigate to home on success
        if (mounted) {
          context.goNamed(AppRouter.home);
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thất bại: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    const Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'Đăng nhập',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng đăng nhập để tiếp tục',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 8),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login button
                    CustomButton(
                      text: 'Đăng nhập',
                      onPressed: _login,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 24),
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            context.goNamed(AppRouter.register);
                          },
                          child: const Text('Đăng ký ngay'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Loading indicator
            if (_isLoading)
              const FullScreenLoading(message: 'Đang đăng nhập...'),
          ],
        ),
      ),
    );
  }
}
