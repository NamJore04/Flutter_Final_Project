import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'Tất cả';
  String _timeRange = '30 ngày qua';
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];

  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusOptions = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang xử lý',
    'Đang giao hàng',
    'Đã giao hàng',
    'Đã hủy',
    'Đã hoàn trả',
    'Đã hoàn tiền'
  ];

  final List<String> _timeRanges = [
    'Hôm nay',
    '7 ngày qua',
    '30 ngày qua',
    'Quý này',
    'Năm nay',
    'Tất cả thời gian'
  ];

  @override
  void initState() {
    super.initState();
    _loadMockOrders();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _filterOrders();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMockOrders() async {
    // Giả lập thời gian tải dữ liệu
    await Future.delayed(const Duration(seconds: 1));

    // Tạo dữ liệu đơn hàng giả lập
    _orders = List.generate(50, (index) => _createMockOrder(index));
    _filteredOrders = List.from(_orders);

    setState(() {
      _isLoading = false;
    });
  }

  OrderModel _createMockOrder(int index) {
    // Thông tin khách hàng giả định
    final List<String> customerNames = [
      'Nguyễn Văn An',
      'Trần Thị Bình',
      'Lê Hoàng Cường',
      'Phạm Minh Đức',
      'Hoàng Thị Hà',
      'Vũ Quang Huy',
      'Đặng Thu Hiền',
      'Bùi Xuân Kiên',
      'Ngô Thanh Lan',
      'Mai Văn Nam',
    ];

    // Danh sách địa chỉ giả định
    final List<String> addresses = [
      'Quận 1, TP. Hồ Chí Minh',
      'Quận Cầu Giấy, Hà Nội',
      'Quận Hải Châu, Đà Nẵng',
      'TP. Biên Hòa, Đồng Nai',
      'TP. Vũng Tàu, Bà Rịa - Vũng Tàu',
      'Quận Ninh Kiều, Cần Thơ',
      'TP. Nha Trang, Khánh Hòa',
      'TP. Huế, Thừa Thiên-Huế',
      'TP. Hải Phòng',
      'TP. Đà Lạt, Lâm Đồng',
    ];

    // Danh sách phương thức thanh toán
    final List<String> paymentMethods = [
      'COD (Thanh toán khi nhận hàng)',
      'Chuyển khoản ngân hàng',
      'Ví điện tử MoMo',
      'Thẻ tín dụng/ghi nợ',
      'ZaloPay',
    ];

    // Tạo ngày đặt hàng (ngày gần hơn cho các đơn hàng có index thấp hơn)
    final DateTime orderDate =
        DateTime.now().subtract(Duration(days: index % 60));

    // Số lượng sản phẩm trong đơn hàng (1-5)
    final int itemCount = 1 + (index % 5);

    // Tổng giá trị đơn hàng
    final double total = 200000 + (index % 10) * 500000 + (itemCount * 100000);

    // Tạo trạng thái đơn hàng dựa trên index
    OrderStatus status;
    if (index % 20 == 0) {
      status = OrderStatus.cancelled; // Đã hủy
    } else if (index % 15 == 0) {
      status = OrderStatus.returned; // Đã hoàn trả
    } else if (index % 12 == 0) {
      status = OrderStatus.refunded; // Đã hoàn tiền
    } else if (index % 6 == 0) {
      status = OrderStatus.delivered; // Đã giao hàng
    } else if (index % 5 == 0) {
      status = OrderStatus.shipped; // Đang giao hàng
    } else if (index % 4 == 0) {
      status = OrderStatus.processing; // Đang xử lý
    } else {
      status = OrderStatus.pending; // Chờ xác nhận
    }

    // Tạo ID đơn hàng với định dạng ORD + số tự tăng, bắt đầu từ 100
    final String orderId = 'ORD${100000 + index}';

    // Tạo đơn hàng giả định
    return OrderModel(
      id: orderId,
      userId: 'USER${index % 100}',
      userName: customerNames[index % customerNames.length],
      products: List.generate(itemCount, (index) => _createMockItem(index)),
      total: total,
      status: status,
      address: addresses[index % addresses.length],
      phoneNumber: '0${9}${index % 10}${100000 + index % 900000}',
      createdAt: orderDate,
    );
  }

  OrderItem _createMockItem(int index) {
    // Thông tin sản phẩm giả định
    final List<String> productNames = [
      'iPhone 15 Pro Max',
      'AirPods Pro 2',
      'MacBook Pro M3',
      'iPad Pro',
      'Samsung Galaxy S23 Ultra',
      'Samsung Galaxy Watch 6',
      'Xiaomi Robot Vacuum',
      'Sony WH-1000XM5',
    ];

    // Tạo sản phẩm giả định
    return OrderItem(
      productId: index.toString(),
      name: productNames[index % productNames.length],
      price: 100000 + (index % 10) * 50000,
      quantity: 1 + (index % 3),
    );
  }

  void _filterOrders() {
    setState(() {
      _filteredOrders = _orders.where((order) {
        // Lọc theo từ khóa tìm kiếm
        final searchMatch = order.id
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            order.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.phoneNumber.contains(_searchQuery);

        // Lọc theo trạng thái
        final statusMatch = _selectedStatus == 'Tất cả' ||
            _getStatusText(order.status) == _selectedStatus;

        // Lọc theo khoảng thời gian
        final timeMatch = _filterByTimeRange(order.createdAt);

        return searchMatch && statusMatch && timeMatch;
      }).toList();
    });
  }

  bool _filterByTimeRange(DateTime orderDate) {
    final now = DateTime.now();

    switch (_timeRange) {
      case 'Hôm nay':
        return orderDate.year == now.year &&
            orderDate.month == now.month &&
            orderDate.day == now.day;

      case '7 ngày qua':
        final weekAgo = now.subtract(const Duration(days: 7));
        return orderDate.isAfter(weekAgo);

      case '30 ngày qua':
        final monthAgo = now.subtract(const Duration(days: 30));
        return orderDate.isAfter(monthAgo);

      case 'Quý này':
        final currentQuarter = (now.month - 1) ~/ 3;
        final startOfQuarter = DateTime(now.year, currentQuarter * 3 + 1, 1);
        return orderDate.isAfter(startOfQuarter);

      case 'Năm nay':
        final startOfYear = DateTime(now.year, 1, 1);
        return orderDate.isAfter(startOfYear);

      case 'Tất cả thời gian':
      default:
        return true;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao hàng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      case OrderStatus.returned:
        return 'Đã hoàn trả';
      case OrderStatus.refunded:
        return 'Đã hoàn tiền';
      default:
        return 'Không xác định';
    }
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
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.brown;
      case OrderStatus.refunded:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _isLoading = true;
    });

    await _loadMockOrders();
    _filterOrders();
  }

  void _showOrderOptionsDialog(OrderModel order) {
    // Xác định các hành động có thể thực hiện dựa trên trạng thái hiện tại
    final List<OrderStatus> availableStatuses =
        _getAvailableStatuses(order.status);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quản lý đơn hàng: ${order.id}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfoItem('Khách hàng', order.userName),
                _buildOrderInfoItem('Điện thoại', order.phoneNumber),
                _buildOrderInfoItem('Địa chỉ', order.address),
                _buildOrderInfoItem('Ngày đặt',
                    DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
                _buildOrderInfoItem(
                    'Tổng tiền', _currencyFormat.format(order.total)),
                _buildOrderInfoItem('Thanh toán', order.products.first.name),
                _buildOrderInfoItem(
                    'Trạng thái thanh toán',
                    order.status == OrderStatus.delivered
                        ? 'Đã thanh toán'
                        : 'Chưa thanh toán'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (availableStatuses.isNotEmpty) ...[
                  const Text(
                    'Cập nhật trạng thái:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...availableStatuses.map((status) => ListTile(
                        leading: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                        ),
                        title: Text(_getStatusText(status)),
                        onTap: () {
                          setState(() {
                            // Tìm đơn hàng trong danh sách và cập nhật trạng thái
                            final index = _orders.indexOf(order);
                            if (index != -1) {
                              _orders[index] = order.copyWith(
                                status: status,
                              );
                              // Cập nhật trong danh sách đã lọc nếu có
                              final filteredIndex =
                                  _filteredOrders.indexOf(order);
                              if (filteredIndex != -1) {
                                _filteredOrders[filteredIndex] = _orders[index];
                              }
                            }
                          });
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Đã cập nhật trạng thái đơn hàng ${order.id} sang ${_getStatusText(status)}'),
                              backgroundColor: _getStatusColor(status),
                            ),
                          );
                        },
                        contentPadding: EdgeInsets.zero,
                      )),
                  const SizedBox(height: 16),
                ],
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Xem chi tiết đơn hàng'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Điều hướng đến màn hình chi tiết đơn hàng
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('In hóa đơn'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Thêm logic in hóa đơn
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  List<OrderStatus> _getAvailableStatuses(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return [OrderStatus.processing, OrderStatus.cancelled];
      case OrderStatus.processing:
        return [OrderStatus.shipped, OrderStatus.cancelled];
      case OrderStatus.shipped:
        return [OrderStatus.delivered, OrderStatus.returned];
      case OrderStatus.delivered:
        return [OrderStatus.returned, OrderStatus.refunded];
      case OrderStatus.returned:
        return [OrderStatus.refunded];
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
      default:
        return []; // Không có hành động tiếp theo cho các trạng thái này
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.processing:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.returned:
        return Icons.assignment_return;
      case OrderStatus.refunded:
        return Icons.payments;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
            tooltip: 'Làm mới dữ liệu',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: LoadingIndicator(
                size: LoadingSize.large,
                message: 'Đang tải dữ liệu đơn hàng...',
              ),
            )
          : Column(
              children: [
                _buildFilters(),
                _buildOrderStats(),
                const Divider(height: 1),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? _buildEmptyState()
                      : _buildOrderList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ô tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm theo mã đơn, tên hoặc SĐT khách hàng',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _filterOrders();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Bộ lọc
          Row(
            children: [
              // Lọc theo trạng thái
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                        _filterOrders();
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Lọc theo thời gian
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _timeRange,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Thời gian',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: _timeRanges.map((range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(range),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _timeRange = value;
                        _filterOrders();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    // Tính toán số lượng đơn hàng theo trạng thái
    final pendingCount =
        _orders.where((o) => o.status == OrderStatus.pending).length;
    final processingCount =
        _orders.where((o) => o.status == OrderStatus.processing).length;
    final shippedCount =
        _orders.where((o) => o.status == OrderStatus.shipped).length;
    final completedCount = _orders
        .where((o) =>
            o.status == OrderStatus.delivered ||
            o.status == OrderStatus.refunded)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hiển thị ${_filteredOrders.length} / ${_orders.length} đơn hàng',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  const Text('Sắp xếp:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: 'newest',
                    items: const [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('Mới nhất'),
                      ),
                      DropdownMenuItem(
                        value: 'oldest',
                        child: Text('Cũ nhất'),
                      ),
                      DropdownMenuItem(
                        value: 'highest',
                        child: Text('Giá trị cao nhất'),
                      ),
                    ],
                    onChanged: (value) {
                      // TODO: Thêm logic sắp xếp
                    },
                    underline: Container(),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Thống kê theo trạng thái
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusCard('Chờ xác nhận', pendingCount, Colors.blue),
                _buildStatusCard('Đang xử lý', processingCount, Colors.orange),
                _buildStatusCard('Đang giao', shippedCount, Colors.purple),
                _buildStatusCard('Hoàn thành', completedCount, Colors.green),
                _buildStatusCard('Tổng', _orders.length, Colors.grey.shade700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredOrders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return _buildOrderItem(order);
      },
    );
  }

  Widget _buildOrderItem(OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);

    return InkWell(
      onTap: () => _showOrderOptionsDialog(order),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1: ID đơn hàng và ngày đặt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('HH:mm - dd/MM/yyyy').format(order.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Hàng 2: Thông tin khách hàng
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.userName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(order.phoneNumber),
              ],
            ),

            const SizedBox(height: 4),

            // Hàng 3: Địa chỉ
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Hàng 4: Tổng tiền, phương thức thanh toán và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tổng tiền và số lượng sản phẩm
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currencyFormat.format(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${order.products.length} sản phẩm',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                // Phương thức thanh toán
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          order.status == OrderStatus.delivered
                              ? Icons.check_circle
                              : Icons.access_time,
                          size: 14,
                          color: order.status == OrderStatus.delivered
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.status == OrderStatus.delivered
                              ? 'Đã thanh toán'
                              : 'Chưa thanh toán',
                          style: TextStyle(
                            fontSize: 13,
                            color: order.status == OrderStatus.delivered
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(order.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 13,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedStatus != 'Tất cả' ||
                    _timeRange != 'Tất cả thời gian'
                ? 'Không tìm thấy đơn hàng phù hợp với bộ lọc'
                : 'Chưa có đơn hàng nào',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedStatus != 'Tất cả' ||
                    _timeRange != 'Tất cả thời gian'
                ? 'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'
                : 'Đơn hàng mới sẽ xuất hiện ở đây',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty ||
              _selectedStatus != 'Tất cả' ||
              _timeRange != 'Tất cả thời gian')
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedStatus = 'Tất cả';
                  _timeRange = '30 ngày qua';
                  _filterOrders();
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Xóa bộ lọc'),
            ),
        ],
      ),
    );
  }
}
