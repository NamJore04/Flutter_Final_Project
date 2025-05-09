import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:team_nlq_tdtu/core/providers/connectivity_provider.dart';
import 'package:team_nlq_tdtu/core/widgets/app_scaffold.dart';
import 'package:team_nlq_tdtu/core/widgets/empty_state.dart';
import 'package:team_nlq_tdtu/core/widgets/error_state.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/core/widgets/network_aware_widget.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';
import 'package:team_nlq_tdtu/features/order/presentation/providers/order_provider.dart';
import 'package:team_nlq_tdtu/features/order/presentation/widgets/order_list_item.dart';
import 'package:team_nlq_tdtu/features/user/presentation/providers/user_provider.dart';

class OrderListScreen extends StatefulWidget {
  static const String routeName = '/orders';

  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderStatus?> _tabs = [
    null, // Tất cả
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.completed,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Lấy userId từ UserProvider
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.currentUser?.id;

    if (userId != null) {
      // Fetch tất cả đơn hàng khi khởi tạo
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OrderProvider>().getUserOrders(userId);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.currentUser?.id;

      if (userId != null) {
        final orderProvider = context.read<OrderProvider>();
        orderProvider.filterByStatus(_tabs[_tabController.index]);

        // Kiểm tra kết nối trước khi tải dữ liệu
        final connectivityProvider = context.read<ConnectivityProvider>();
        if (connectivityProvider.isConnected) {
          orderProvider.getUserOrders(
            userId,
            status: _tabs[_tabController.index],
            refresh: true,
          );
        } else {
          // Nếu không có kết nối, chỉ áp dụng bộ lọc trên dữ liệu đã có
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có kết nối mạng. Hiển thị dữ liệu đã lưu.'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _getTabLabel(OrderStatus? status) {
    if (status == null) return 'Tất cả';
    return status.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Đơn hàng của tôi',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: theme.primaryColor,
            tabs:
                _tabs.map((status) => Tab(text: _getTabLabel(status))).toList(),
          ),
          Expanded(
            child: NetworkAwareWidget(
              // Cho phép hiển thị dữ liệu đã lưu trong cache khi không có mạng
              checkOnlyIfNeeded: true,
              offlineMessage: 'Không thể tải đơn hàng mới',
              onRetry: () {
                final userProvider = context.read<UserProvider>();
                final userId = userProvider.currentUser?.id;
                if (userId != null) {
                  context.read<OrderProvider>().getUserOrders(
                        userId,
                        status: _tabs[_tabController.index],
                        refresh: true,
                      );
                }
              },
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                    return const Center(child: LoadingIndicator());
                  }

                  // Kiểm tra xem lỗi có phải do kết nối không
                  if (orderProvider.hasError) {
                    final connectivityProvider =
                        context.read<ConnectivityProvider>();
                    if (!connectivityProvider.isConnected &&
                        orderProvider.orders.isNotEmpty) {
                      // Nếu không có kết nối nhưng có dữ liệu trong cache, hiển thị thông báo nhỏ
                      return Column(
                        children: [
                          Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.wifi_off_rounded, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Đang hiển thị đơn hàng đã lưu',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    final userProvider =
                                        context.read<UserProvider>();
                                    final userId = userProvider.currentUser?.id;
                                    if (userId != null) {
                                      orderProvider.getUserOrders(
                                        userId,
                                        status: _tabs[_tabController.index],
                                        refresh: true,
                                      );
                                    }
                                  },
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _buildOrdersList(
                              orderProvider.orders,
                              canRefresh:
                                  false, // Không cho phép làm mới khi offline
                            ),
                          ),
                        ],
                      );
                    }

                    return ErrorState(
                      message: orderProvider.errorMessage ??
                          'Đã xảy ra lỗi khi tải đơn hàng',
                      onRetry: () {
                        final userProvider = context.read<UserProvider>();
                        final userId = userProvider.currentUser?.id;
                        if (userId != null) {
                          orderProvider.getUserOrders(
                            userId,
                            status: _tabs[_tabController.index],
                            refresh: true,
                          );
                        }
                      },
                    );
                  }

                  final orders = orderProvider.orders;
                  if (orders.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Không có đơn hàng',
                      message: 'Bạn chưa có đơn hàng nào trong danh mục này',
                      iconColor: isDark ? Colors.white70 : Colors.black54,
                    );
                  }

                  return _buildOrdersList(orders);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, {bool canRefresh = true}) {
    final orderProvider = context.read<OrderProvider>();
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.currentUser?.id;

    if (!canRefresh) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderListItem(
            order: order,
            onTap: () => _navigateToOrderDetails(order),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (userId != null) {
          await orderProvider.getUserOrders(
            userId,
            status: _tabs[_tabController.index],
            refresh: true,
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderListItem(
            order: order,
            onTap: () => _navigateToOrderDetails(order),
          );
        },
      ),
    );
  }

  void _navigateToOrderDetails(OrderModel order) {
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: order.id,
    );
  }
}
