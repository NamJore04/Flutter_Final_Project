import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/cart_item_model.dart';
import '../providers/cart_provider.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback? onTap;

  const CartItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),

              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),

                    // Hiển thị tùy chọn đã chọn
                    if (item.selectedOptions.isNotEmpty) ...[
                      Wrap(
                        spacing: 4.0,
                        children: item.selectedOptions.entries.map((option) {
                          return Chip(
                            label: Text(
                              '${option.key}: ${option.value}',
                              style: theme.textTheme.bodySmall,
                            ),
                            backgroundColor:
                                theme.colorScheme.primary.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4.0),
                    ],

                    // Giá và số lượng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Giá
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatCurrency(item.price),
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.originalPrice > item.price)
                              Text(
                                formatCurrency(item.originalPrice),
                                style: theme.textTheme.bodySmall!.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),

                        // Bộ điều khiển số lượng
                        QuantityControl(
                          itemId: item.id,
                          quantity: item.quantity,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)}đ';
  }
}

class QuantityControl extends StatelessWidget {
  final String itemId;
  final int quantity;

  const QuantityControl({
    super.key,
    required this.itemId,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Row(
      children: [
        // Nút giảm
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: IconButton(
            icon: const Icon(Icons.remove, size: 16.0),
            onPressed: () {
              cartProvider.updateItemQuantity(itemId, quantity - 1);
            },
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(),
          ),
        ),

        // Hiển thị số lượng
        Container(
          width: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: theme.textTheme.titleMedium,
          ),
        ),

        // Nút tăng
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, size: 16.0),
            onPressed: () {
              cartProvider.updateItemQuantity(itemId, quantity + 1);
            },
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(),
          ),
        ),

        const SizedBox(width: 8.0),

        // Nút xóa
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: IconButton(
            icon: Icon(Icons.delete_outline,
                size: 16.0, color: theme.colorScheme.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa sản phẩm'),
                  content: const Text(
                      'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('HỦY'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        cartProvider.removeItem(itemId);
                      },
                      child: const Text('XÓA'),
                    ),
                  ],
                ),
              );
            },
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
