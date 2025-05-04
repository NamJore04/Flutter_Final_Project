import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Xóa tất cả',
                onPressed: () {
                  _showClearCartDialog(context);
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          // Hiển thị trạng thái tải
          if (cartProvider.status == CartStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Hiển thị lỗi
          if (cartProvider.status == CartStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(cartProvider.errorMessage ?? 'Không thể tải giỏ hàng'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      cartProvider.refreshCart();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Hiển thị giỏ hàng trống
          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }

          // Hiển thị danh sách sản phẩm
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cartProvider.refreshCart(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartProvider.cart!.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.cart!.items[index];
                      return CartItemCard(
                        item: item,
                        onTap: () {
                          // Chuyển đến trang chi tiết sản phẩm (nếu cần)
                          // Navigator.of(context).pushNamed(
                          //   ProductDetailScreen.routeName,
                          //   arguments: item.productId,
                          // );
                        },
                      );
                    },
                  ),
                ),
              ),
              CartSummary(
                onCheckout: () {
                  // Chuyển đến màn hình thanh toán
                  Navigator.of(context).pushNamed(CheckoutScreen.routeName);
                },
              ),
              // Hiển thị indicator khi đang xử lý
              if (cartProvider.isLoading) const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: theme.textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thêm sản phẩm vào giỏ hàng để tiếp tục',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Quay về trang danh sách sản phẩm
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('MUA SẮM NGAY'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tất cả sản phẩm'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cartProvider.clearCart();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('XÓA TẤT CẢ'),
          ),
        ],
      ),
    );
  }
}
