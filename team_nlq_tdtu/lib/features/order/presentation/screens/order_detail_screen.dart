import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:team_nlq_tdtu/core/widgets/app_scaffold.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/error_state.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';
import 'package:team_nlq_tdtu/features/order/presentation/providers/order_provider.dart';
import 'package:team_nlq_tdtu/features/order/presentation/widgets/order_status_timeline.dart';
import 'package:team_nlq_tdtu/features/review/domain/repositories/review_repository.dart';
import 'package:team_nlq_tdtu/features/review/presentation/providers/review_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = '/order-details';
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch chi tiết đơn hàng khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().getOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chi tiết đơn hàng',
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (orderProvider.hasError) {
            return ErrorState(
              message: orderProvider.errorMessage ??
                  'Không thể tải thông tin đơn hàng',
              onRetry: () {
                orderProvider.getOrderDetails(widget.orderId);
              },
            );
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return const ErrorState(
              message: 'Không tìm thấy thông tin đơn hàng',
              onRetry: null,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 20),
                OrderStatusTimeline(order: order),
                const SizedBox(height: 20),
                _buildProductsList(context, order),
                const SizedBox(height: 20),
                _buildDeliveryInfo(order),
                const SizedBox(height: 20),
                _buildPaymentSummary(order),
                const SizedBox(height: 24),
                _buildActions(context, order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = formatter.format(order.createdAt);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.id.substring(0, 8).toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày đặt: $formattedDate',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (order.trackingNumber != null &&
                order.trackingNumber!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Mã vận đơn: ${order.trackingNumber}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, OrderModel order) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sản phẩm (${order.items.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...order.items
                .map((item) => _buildOrderItem(context, order, item))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
      BuildContext context, OrderModel order, OrderItemModel item) {
    final canReview = order.isCompleted || order.isDelivered;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.attributes != null && item.attributes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _formatAttributes(item.attributes!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.price)} x ${item.quantity}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (canReview)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildReviewButton(context, order, item),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(
      BuildContext context, OrderModel order, OrderItemModel item) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        return OutlinedButton(
          onPressed: () => _navigateToReviewScreen(context, order, item),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Đánh giá'),
        );
      },
    );
  }

  void _navigateToReviewScreen(
      BuildContext context, OrderModel order, OrderItemModel item) {
    // Chuyển đến màn hình đánh giá với thông tin đơn hàng và sản phẩm
    context.push('/review', extra: {'order': order, 'orderItem': item});
  }

  Widget _buildDeliveryInfo(OrderModel order) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin giao hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Người nhận', order.contactName),
            _buildInfoRow('Số điện thoại', order.contactPhone),
            _buildInfoRow('Địa chỉ', order.deliveryAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thanh toán',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Phương thức thanh toán', order.paymentMethod),
            _buildInfoRow('Trạng thái thanh toán',
                order.isPaid ? 'Đã thanh toán' : 'Chưa thanh toán'),
            const Divider(height: 24),
            _buildInfoRow('Tạm tính', currencyFormat.format(order.subtotal)),
            _buildInfoRow(
                'Phí vận chuyển', currencyFormat.format(order.shippingFee)),
            if (order.discount > 0)
              _buildInfoRow(
                  'Giảm giá', '- ${currencyFormat.format(order.discount)}'),
            const Divider(height: 24),
            _buildInfoRow(
              'Tổng cộng',
              currencyFormat.format(order.total),
              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, OrderModel order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Row(
      children: [
        if (order.canCancel)
          Expanded(
            child: CustomButton(
              onPressed: () => _showCancelDialog(context, order, orderProvider),
              text: 'Hủy đơn',
              isOutlined: true,
            ),
          ),
        if (order.canCancel && (order.isDelivered || order.isCompleted))
          const SizedBox(width: 16),
        if (order.isDelivered || order.isCompleted)
          Expanded(
            child: CustomButton(
              onPressed: () =>
                  _showReturnOrderDialog(context, order, orderProvider),
              text: 'Trả hàng',
            ),
          ),
      ],
    );
  }

  Future<void> _showCancelDialog(BuildContext context, OrderModel order,
      OrderProvider orderProvider) async {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn hủy đơn hàng này không?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do hủy (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();

              final loadingContext = context;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final result = await orderProvider.cancelOrder(
                orderId: order.id,
                cancelReason: reasonController.text.trim(),
              );

              // Đóng dialog loading
              Navigator.of(loadingContext).pop();

              // Hiển thị kết quả
              if (result) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã hủy đơn hàng thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      orderProvider.errorMessage ?? 'Không thể hủy đơn hàng',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showReturnOrderDialog(
      BuildContext context, OrderModel order, OrderProvider orderProvider) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu trả hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng cho biết lý do bạn muốn trả hàng:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do trả hàng',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập lý do trả hàng'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              final loadingContext = context;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final result = await orderProvider.returnOrder(
                orderId: order.id,
                returnReason: reasonController.text.trim(),
              );

              // Đóng dialog loading
              Navigator.of(loadingContext).pop();

              // Hiển thị kết quả
              if (result) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi yêu cầu trả hàng thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      orderProvider.errorMessage ??
                          'Không thể gửi yêu cầu trả hàng',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }

  String _formatAttributes(Map<String, dynamic> attributes) {
    final List<String> formattedAttributes = [];

    attributes.forEach((key, value) {
      formattedAttributes.add('$key: $value');
    });

    return formattedAttributes.join(', ');
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green[700]!;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.red[300]!;
      case OrderStatus.returned:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
