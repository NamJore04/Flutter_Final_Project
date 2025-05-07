import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_nlq_tdtu/features/auth/presentation/pages/login_screen.dart';
import 'package:team_nlq_tdtu/features/auth/presentation/pages/register_screen.dart';
import 'package:team_nlq_tdtu/features/splash/presentation/pages/splash_screen.dart';
import 'package:team_nlq_tdtu/features/user/presentation/pages/profile_screen.dart';
import 'package:team_nlq_tdtu/features/product/presentation/pages/product_list_screen.dart';
import 'package:team_nlq_tdtu/features/product/presentation/pages/product_detail_screen.dart';
import 'package:team_nlq_tdtu/features/product/presentation/pages/review_screen.dart';
import 'package:team_nlq_tdtu/features/cart/presentation/screens/cart_screen.dart';
import 'package:team_nlq_tdtu/features/cart/presentation/screens/checkout_screen.dart';
import 'package:team_nlq_tdtu/features/cart/presentation/screens/order_confirmation_screen.dart';
import 'package:team_nlq_tdtu/features/order/presentation/screens/order_list_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Route names
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String productList = 'product-list';
  static const String productDetail = 'product-detail';
  static const String productReview = 'product-review';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String orderConfirmation = 'order-confirmation';
  static const String orderHistory = 'order-history';
  static const String orderDetail = 'order-detail';
  static const String profile = 'profile';
  static const String admin = 'admin';

  // Route paths
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String productListPath = '/products';
  static const String productDetailPath = '/products/:id';
  static const String productReviewPath = '/products/:id/reviews';
  static const String cartPath = '/cart';
  static const String checkoutPath = '/checkout';
  static const String orderConfirmationPath = '/order-confirmation';
  static const String orderHistoryPath = '/orders';
  static const String orderDetailPath = '/orders/:id';
  static const String profilePath = '/profile';
  static const String adminPath = '/admin';

  // Placeholder pages
  static Widget _placeholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title Page - To be implemented'),
      ),
    );
  }

  // Router configuration
  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splashPath,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      // Kiểm tra nếu đường dẫn hiện tại là rỗng và không phải là trang splash, 
      // chuyển hướng về trang home để tránh lỗi stack rỗng
      if (state.matchedLocation.isEmpty && state.uri.path != splashPath) {
        return homePath;
      }
      
      // Xử lý trường hợp route không tồn tại
      if (!state.matchedLocation.startsWith(splashPath) && 
          !state.matchedLocation.startsWith(loginPath) && 
          !state.matchedLocation.startsWith(registerPath) && 
          !state.matchedLocation.startsWith(homePath) && 
          !state.matchedLocation.startsWith(productListPath) && 
          !state.matchedLocation.startsWith(cartPath) && 
          !state.matchedLocation.startsWith(orderHistoryPath) && 
          !state.matchedLocation.startsWith(profilePath) && 
          !state.matchedLocation.startsWith(adminPath)) {
        return productListPath;  // Mặc định về trang danh sách sản phẩm
      }
      
      return null;
    },
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi điều hướng')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Không tìm thấy trang: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.goNamed(productList),
                child: const Text('Quay lại danh sách sản phẩm'),
              ),
            ],
          ),
        ),
      );
    },
    routes: [
      // Splash screen
      GoRoute(
        path: splashPath,
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication routes
      GoRoute(
        path: loginPath,
        name: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        name: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main shell route
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Material(
            child: Scaffold(
              body: child,
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _calculateSelectedIndex(state),
                onTap: (index) => _onItemTapped(index, context),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Trang chủ',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Sản phẩm',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Giỏ hàng',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long),
                    label: 'Đơn hàng',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Cá nhân',
                  ),
                ],
              ),
            ),
          );
        },
        routes: [
          // Home route
          GoRoute(
            path: homePath,
            name: home,
            builder: (context, state) => _placeholderPage('Home'),
            routes: [
              // Product detail from home
              GoRoute(
                path: 'products/:id',
                name: '$home-$productDetail',
                builder: (context, state) {
                  final productId = state.pathParameters['id'] ?? '';
                  if (productId.isEmpty) {
                    return _errorProductNotFound(context);
                  }
                  return ProductDetailScreen(productId: productId);
                },
                routes: [
                  // Review screen from product detail
                  GoRoute(
                    path: 'reviews',
                    name: '$home-$productDetail-$productReview',
                    builder: (context, state) {
                      final productId = state.pathParameters['id'] ?? '';
                      if (productId.isEmpty) {
                        return _errorProductNotFound(context);
                      }
                      return ReviewScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Products route
          GoRoute(
            path: productListPath,
            name: productList,
            builder: (context, state) => const ProductListScreen(),
            routes: [
              // Product detail
              GoRoute(
                path: ':id',
                name: productDetail,
                builder: (context, state) {
                  final productId = state.pathParameters['id'] ?? '';
                  if (productId.isEmpty) {
                    return _errorProductNotFound(context);
                  }
                  return ProductDetailScreen(productId: productId);
                },
                routes: [
                  // Review screen
                  GoRoute(
                    path: 'reviews',
                    name: productReview,
                    builder: (context, state) {
                      final productId = state.pathParameters['id'] ?? '';
                      if (productId.isEmpty) {
                        return _errorProductNotFound(context);
                      }
                      return ReviewScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Cart route
          GoRoute(
            path: cartPath,
            name: cart,
            builder: (context, state) => const CartScreen(),
            routes: [
              // Checkout
              GoRoute(
                path: 'checkout',
                name: checkout,
                builder: (context, state) => const CheckoutScreen(),
                routes: [
                  // Order confirmation
                  GoRoute(
                    path: 'confirmation',
                    name: orderConfirmation,
                    builder: (context, state) => const OrderConfirmationScreen(),
                  ),
                ],
              ),
            ],
          ),
          
          // Orders route
          GoRoute(
            path: orderHistoryPath,
            name: orderHistory,
            builder: (context, state) => const OrderListScreen(),
            routes: [
              // Order detail
              GoRoute(
                path: ':id',
                name: orderDetail,
                builder: (context, state) {
                  final orderId = state.pathParameters['id'] ?? '';
                  if (orderId.isEmpty) {
                    return _errorOrderNotFound(context);
                  }
                  return _placeholderPage('Chi tiết đơn hàng - $orderId');
                },
              ),
            ],
          ),
          
          // Profile route
          GoRoute(
            path: profilePath,
            name: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Admin route
      GoRoute(
        path: adminPath,
        name: admin,
        builder: (context, state) => _placeholderPage('Admin Dashboard'),
      ),
    ],
  );

  // Router getter
  static GoRouter get router => _router;
  
  // Helper method to calculate the selected tab index
  static int _calculateSelectedIndex(GoRouterState state) {
    final String matchedLocation = state.matchedLocation;
    if (matchedLocation.startsWith(homePath)) {
      return 0;
    }
    if (matchedLocation.startsWith(productListPath)) {
      return 1;
    }
    if (matchedLocation.startsWith(cartPath)) {
      return 2;
    }
    if (matchedLocation.startsWith(orderHistoryPath)) {
      return 3;
    }
    if (matchedLocation.startsWith(profilePath)) {
      return 4;
    }
    return 0;
  }
  
  // Handle tab tap
  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(home);
        break;
      case 1:
        context.goNamed(productList);
        break;
      case 2:
        context.goNamed(cart);
        break;
      case 3:
        context.goNamed(orderHistory);
        break;
      case 4:
        context.goNamed(profile);
        break;
    }
  }
  
  // Error pages
  static Widget _errorProductNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi sản phẩm'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy sản phẩm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(productList),
              child: const Text('Quay lại danh sách sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget _errorOrderNotFound(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi đơn hàng'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(orderHistory),
              child: const Text('Quay lại danh sách đơn hàng'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Phương thức pop an toàn để tránh lỗi stack rỗng
  static void safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      GoRouter.of(context).go(homePath);
    }
  }
}

/// Extension cho BuildContext để dễ dàng sử dụng safePop
extension SafeNavigationContext on BuildContext {
  /// Pop màn hình hiện tại một cách an toàn
  void safePop() {
    AppRouter.safePop(this);
  }
} 