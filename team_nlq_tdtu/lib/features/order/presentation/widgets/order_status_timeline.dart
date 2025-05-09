import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_status_log.dart';
import 'package:team_nlq_tdtu/core/themes/app_colors.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trạng thái đơn hàng',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            _buildTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    // Xác định tất cả các trạng thái có thể có
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
      OrderStatus.completed,
    ];

    // Nếu đơn hàng đã bị hủy hoặc trả lại, thay thế trạng thái completed
    if (order.isCancelled) {
      allStatuses.removeLast(); // Xóa completed
      allStatuses.add(OrderStatus.cancelled);
    } else if (order.isReturned) {
      allStatuses.removeLast(); // Xóa completed
      allStatuses.add(OrderStatus.returned);
    } else if (order.isRefunded) {
      allStatuses.removeLast(); // Xóa completed
      allStatuses.add(OrderStatus.refunded);
    }

    // Tìm vị trí trạng thái hiện tại
    final currentStatusIndex = allStatuses.indexOf(order.status);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: List.generate(
            allStatuses.length,
            (index) {
              final status = allStatuses[index];
              final isActive = index <= currentStatusIndex;
              final isLast = index == allStatuses.length - 1;

              // Tìm log liên quan đến trạng thái này
              final statusLog = order.statusLogs
                  .where((log) => log.status == status)
                  .toList();

              final hasLog = statusLog.isNotEmpty;
              final logTime = hasLog
                  ? DateFormat('dd/MM/yyyy HH:mm')
                      .format(statusLog[0].timestamp)
                  : '';

              // Lấy màu phù hợp với theme
              final inactiveColor =
                  isDark ? Colors.grey[600] : Colors.grey[350];
              final indicatorBorderColor = isActive
                  ? AppColors.primary
                  : isDark
                      ? Colors.grey[600]!
                      : Colors.grey[350]!;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Indicator
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  isActive ? AppColors.primary : inactiveColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: indicatorBorderColor,
                              ),
                            ),
                            child: isActive
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 30,
                              color:
                                  isActive ? AppColors.primary : inactiveColor,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isActive
                                    ? theme.textTheme.titleMedium?.color
                                    : theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.8),
                              ),
                            ),
                            if (hasLog) ...[
                              const SizedBox(height: 4),
                              Text(
                                logTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                            if (statusLog.isNotEmpty &&
                                statusLog[0].note != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                statusLog[0].note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                            if (!isLast) const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
