import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/core/routes/app_router.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/features/user/presentation/pages/address_book_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  // Mock user data - Would be fetched from a provider or service in a real app
  final Map<String, dynamic> _userData = {
    'id': 'user123',
    'name': 'Nguyễn Văn A',
    'email': 'nguyenvana@example.com',
    'phone': '0987654321',
    'avatar': null, // URL would go here
    'orderCount': 5,
    'wishlistCount': 12,
    'memberSince': '01/01/2023',
  };

  void _navigateToEditProfile() {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang được phát triển'),
      ),
    );
  }

  void _navigateToAddressBook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressBookScreen(),
      ),
    );
  }

  void _navigateToOrderHistory() {
    context.goNamed(AppRouter.orderHistory);
  }

  void _navigateToWishlist() {
    // TODO: Navigate to wishlist screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang được phát triển'),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual logout logic
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network request

      // Navigate to login screen
      if (mounted) {
        context.goNamed(AppRouter.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Reload user data here
              await Future.delayed(const Duration(milliseconds: 500));
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.colorScheme.primary,
                          child: _userData['avatar'] != null
                              ? null
                              : Text(
                                  _userData['name'].substring(0, 1),
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // User name
                        Text(
                          _userData['name'],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // User email
                        Text(
                          _userData['email'],
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),

                        // User phone
                        Text(
                          _userData['phone'],
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),

                        // Edit profile button
                        CustomButton(
                          text: 'Chỉnh sửa hồ sơ',
                          onPressed: _navigateToEditProfile,
                          type: ButtonType.outline,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Đơn hàng',
                      value: _userData['orderCount'].toString(),
                      icon: Icons.shopping_bag_outlined,
                      onTap: _navigateToOrderHistory,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      title: 'Yêu thích',
                      value: _userData['wishlistCount'].toString(),
                      icon: Icons.favorite_border,
                      onTap: _navigateToWishlist,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Options list
                const Text(
                  'Tùy chọn tài khoản',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  title: 'Sổ địa chỉ',
                  icon: Icons.location_on_outlined,
                  onTap: _navigateToAddressBook,
                ),
                _buildOptionTile(
                  title: 'Phương thức thanh toán',
                  icon: Icons.credit_card_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang được phát triển'),
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  title: 'Đổi mật khẩu',
                  icon: Icons.lock_outline,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang được phát triển'),
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  title: 'Thông báo',
                  icon: Icons.notifications_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang được phát triển'),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildOptionTile(
                  title: 'Trung tâm trợ giúp',
                  icon: Icons.help_outline,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang được phát triển'),
                      ),
                    );
                  },
                ),
                _buildOptionTile(
                  title: 'Về chúng tôi',
                  icon: Icons.info_outline,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang được phát triển'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Đăng xuất',
                  onPressed: _logout,
                  isLoading: _isLoading,
                  type: ButtonType.secondary,
                  isFullWidth: true,
                ),
                const SizedBox(height: 24),
                // Version info
                Center(
                  child: Text(
                    'Phiên bản 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_isLoading) const FullScreenLoading(message: 'Đang xử lý...'),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
