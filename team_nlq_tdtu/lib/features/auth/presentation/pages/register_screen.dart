import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_text_field.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/core/widgets/password_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản dịch vụ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement actual registration logic
        await Future.delayed(
            const Duration(seconds: 2)); // Simulate network request

        // Navigate to login on success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: Colors.green,
            ),
          );
          context.goNamed(AppRouter.login);
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng ký thất bại: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
      ),
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
                    // Heading
                    Text(
                      'Tạo tài khoản mới',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng điền đầy đủ thông tin để tạo tài khoản',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),

                    // Full Name field
                    CustomTextField(
                      controller: _fullNameController,
                      labelText: 'Họ và tên',
                      hintText: 'Nhập họ và tên của bạn',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: _validateFullName,
                    ),
                    const SizedBox(height: 16),

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

                    // Phone field
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại của bạn',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    PasswordField(
                      controller: _passwordController,
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    PasswordField(
                      controller: _confirmPasswordController,
                      labelText: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu của bạn',
                      validator: _validateConfirmPassword,
                    ),
                    const SizedBox(height: 24),

                    // Terms and conditions
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(
                                  text: 'Tôi đồng ý với ',
                                ),
                                TextSpan(
                                  text: 'Điều khoản dịch vụ',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' và ',
                                ),
                                TextSpan(
                                  text: 'Chính sách riêng tư',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Register button
                    CustomButton(
                      text: 'Đăng ký',
                      onPressed: _register,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            context.goNamed(AppRouter.login);
                          },
                          child: const Text('Đăng nhập'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (_isLoading) const FullScreenLoading(message: 'Đang đăng ký...'),
          ],
        ),
      ),
    );
  }
}
