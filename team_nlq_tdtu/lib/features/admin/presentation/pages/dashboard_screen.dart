import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:team_nlq_tdtu/core/widgets/custom_button.dart';
import 'package:team_nlq_tdtu/core/widgets/loading_indicator.dart';
import 'package:team_nlq_tdtu/features/admin/domain/models/admin_stats_model.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;

  // Dữ liệu mẫu - sẽ thay thế bằng dữ liệu từ API
  late AdminStats _stats;
  final List<FlSpot> _salesData = [];
  final List<FlSpot> _ordersData = [];

  // Dữ liệu dashboard
  late DashboardData _dashboardData;

  // Format tiền tệ
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMockData() async {
    // Giả lập thời gian tải dữ liệu
    await Future.delayed(const Duration(seconds: 1));

    // Tạo dữ liệu giả
    _stats = AdminStats(
      totalUsers: 1250,
      totalOrders: 856,
      totalProducts: 128,
      totalRevenue: 156500000,
      pendingOrders: 42,
      shippedOrders: 35,
      deliveredOrders: 779,
      newUsers: 68,
      salesGrowth: 15.7,
      orderGrowth: 12.3,
    );

    // Tạo dữ liệu biểu đồ doanh thu theo ngày
    _salesData.clear();
    for (int i = 0; i < 30; i++) {
      // Giả lập dữ liệu doanh thu với một số biến động
      double value = 5000000 +
          (i * 500000) +
          (i % 3 == 0 ? 2000000 : 0) -
          (i % 7 == 0 ? 1500000 : 0);
      _salesData.add(
          FlSpot(i.toDouble(), value / 1000000)); // Hiển thị theo đơn vị triệu
    }

    // Tạo dữ liệu biểu đồ đơn hàng theo ngày
    _ordersData.clear();
    for (int i = 0; i < 30; i++) {
      // Giả lập số lượng đơn hàng với một số biến động
      double value = 20 + (i % 5) + (i % 3 == 0 ? 8 : 0) - (i % 7 == 0 ? 5 : 0);
      _ordersData.add(FlSpot(i.toDouble(), value));
    }

    // Tạo dữ liệu dashboard
    _dashboardData = DashboardData(
      summaryCards: [
        SummaryCardData(
          title: 'Tổng doanh thu',
          value: 75420000,
          changePercentage: 12.5,
          isIncreasing: true,
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        SummaryCardData(
          title: 'Đơn hàng mới',
          value: 42,
          changePercentage: 8.3,
          isIncreasing: true,
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        SummaryCardData(
          title: 'Người dùng mới',
          value: 18,
          changePercentage: 5.2,
          isIncreasing: true,
          icon: Icons.person_add,
          color: Colors.orange,
        ),
        SummaryCardData(
          title: 'Tỷ lệ hoàn đơn',
          value: 2.3,
          changePercentage: 0.8,
          isIncreasing: false,
          icon: Icons.assignment_return,
          color: Colors.red,
        ),
      ],
      revenueData: [
        RevenueData(
            date: DateTime.now().subtract(const Duration(days: 6)),
            revenue: 8500000),
        RevenueData(
            date: DateTime.now().subtract(const Duration(days: 5)),
            revenue: 7200000),
        RevenueData(
            date: DateTime.now().subtract(const Duration(days: 4)),
            revenue: 9800000),
        RevenueData(
            date: DateTime.now().subtract(const Duration(days: 3)),
            revenue: 11200000),
        RevenueData(
            date: DateTime.now().subtract(const Duration(days: 2)),
            revenue: 10500000),
        RevenueData(
            date: DateTime.now().subtract(const Duration(days: 1)),
            revenue: 12800000),
        RevenueData(date: DateTime.now(), revenue: 15420000),
      ],
      categoryData: [
        CategoryData(name: 'Điện thoại', percentage: 35.8),
        CategoryData(name: 'Laptop', percentage: 28.3),
        CategoryData(name: 'Máy tính bảng', percentage: 15.6),
        CategoryData(name: 'Phụ kiện', percentage: 12.4),
        CategoryData(name: 'Khác', percentage: 7.9),
      ],
      recentOrders: [
        RecentOrderData(
          id: 'OR12345',
          customerName: 'Nguyễn Văn A',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          amount: 3200000,
          status: 'Đang xử lý',
        ),
        RecentOrderData(
          id: 'OR12344',
          customerName: 'Trần Thị B',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          amount: 1800000,
          status: 'Đã giao hàng',
        ),
        RecentOrderData(
          id: 'OR12343',
          customerName: 'Lê Văn C',
          date: DateTime.now().subtract(const Duration(hours: 8)),
          amount: 4500000,
          status: 'Đang vận chuyển',
        ),
        RecentOrderData(
          id: 'OR12342',
          customerName: 'Phạm Thị D',
          date: DateTime.now().subtract(const Duration(hours: 12)),
          amount: 2700000,
          status: 'Đã giao hàng',
        ),
        RecentOrderData(
          id: 'OR12341',
          customerName: 'Hoàng Văn E',
          date: DateTime.now().subtract(const Duration(hours: 16)),
          amount: 5200000,
          status: 'Đã hủy',
        ),
      ],
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
        ),
        body: const Center(
          child: LoadingIndicator(
            size: LoadingSize.large,
            message: 'Đang tải dữ liệu...',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Doanh thu'),
            Tab(text: 'Đơn hàng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildRevenueTab(theme),
          _buildOrdersTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan kinh doanh',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Thống kê tổng quan
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Tổng người dùng',
                  _stats.totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Tổng đơn hàng',
                  _stats.totalOrders.toString(),
                  Icons.shopping_basket,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Tổng sản phẩm',
                  _stats.totalProducts.toString(),
                  Icons.inventory_2,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Doanh thu',
                  '${(_stats.totalRevenue / 1000000).toStringAsFixed(2)}M',
                  Icons.monetization_on,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            'Tình trạng đơn hàng',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Thống kê đơn hàng
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.amber,
                            value: _stats.pendingOrders.toDouble(),
                            title: '${_stats.pendingOrders}',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.blue,
                            value: _stats.shippedOrders.toDouble(),
                            title: '${_stats.shippedOrders}',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.green,
                            value: _stats.deliveredOrders.toDouble(),
                            title: '${_stats.deliveredOrders}',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(theme, Colors.amber, 'Chờ xử lý',
                          _stats.pendingOrders),
                      const SizedBox(height: 8),
                      _buildLegendItem(theme, Colors.blue, 'Đang giao hàng',
                          _stats.shippedOrders),
                      const SizedBox(height: 8),
                      _buildLegendItem(theme, Colors.green, 'Đã giao hàng',
                          _stats.deliveredOrders),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Các nút truy cập nhanh
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.people),
                label: const Text('Quản lý người dùng'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.inventory),
                label: const Text('Quản lý sản phẩm'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long),
                label: const Text('Quản lý đơn hàng'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                label: const Text('Cài đặt hệ thống'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thống kê doanh thu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    _stats.salesGrowth >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: _stats.salesGrowth >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_stats.salesGrowth.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color:
                          _stats.salesGrowth >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Doanh thu 30 ngày qua (triệu VNĐ)',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Biểu đồ doanh thu
          Container(
            height: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  verticalInterval: 5,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text('${value.toInt() + 1}'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('${value.toInt()}'),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: 29,
                minY: 0,
                maxY: 15,
                lineBarsData: [
                  LineChartBarData(
                    spots: _salesData,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.purple.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Thống kê chi tiết
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildRevenueStatCard(theme, 'Doanh thu hôm nay', '12.5M', 8.7),
              _buildRevenueStatCard(theme, 'Doanh thu tuần này', '65.8M', 12.3),
              _buildRevenueStatCard(
                  theme, 'Doanh thu tháng này', '156.5M', 15.7),
              _buildRevenueStatCard(
                  theme, 'Doanh thu trung bình / ngày', '5.2M', 6.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thống kê đơn hàng',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    _stats.orderGrowth >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: _stats.orderGrowth >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_stats.orderGrowth.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color:
                          _stats.orderGrowth >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng 30 ngày qua',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Biểu đồ đơn hàng
          Container(
            height: 300,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text('${value.toInt() + 1}'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('${value.toInt()}'),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 30,
                barGroups: _ordersData.map((spot) {
                  return BarChartGroupData(
                    x: spot.x.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: spot.y,
                        color: Colors.orange,
                        width: 6,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Thống kê tổng quan theo trạng thái
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tình trạng đơn hàng',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Số lượng',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildOrderStatusRow(
                    theme, 'Chờ xử lý', _stats.pendingOrders, Colors.amber),
                const Divider(height: 16),
                _buildOrderStatusRow(
                    theme, 'Đang giao hàng', _stats.shippedOrders, Colors.blue),
                const Divider(height: 16),
                _buildOrderStatusRow(
                    theme, 'Đã giao', _stats.deliveredOrders, Colors.green),
                const Divider(height: 16),
                _buildOrderStatusRow(theme, 'Tổng đơn hàng', _stats.totalOrders,
                    theme.colorScheme.primary),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nút quản lý đơn hàng
          CustomButton(
            text: 'Quản lý đơn hàng',
            onPressed: () {},
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.arrow_upward, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      ThemeData theme, Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 4),
        Text(
          '($value)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueStatCard(
      ThemeData theme, String title, String value, double growth) {
    final isPositive = growth >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${growth.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusRow(
      ThemeData theme, String status, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
        Text(
          count.toString(),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Lớp dữ liệu
class DashboardData {
  final List<SummaryCardData> summaryCards;
  final List<RevenueData> revenueData;
  final List<CategoryData> categoryData;
  final List<RecentOrderData> recentOrders;

  DashboardData({
    required this.summaryCards,
    required this.revenueData,
    required this.categoryData,
    required this.recentOrders,
  });
}

class SummaryCardData {
  final String title;
  final dynamic value; // Có thể là số hoặc tiền
  final double changePercentage;
  final bool isIncreasing;
  final IconData icon;
  final Color color;

  SummaryCardData({
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isIncreasing,
    required this.icon,
    required this.color,
  });
}

class RevenueData {
  final DateTime date;
  final double revenue;

  RevenueData({
    required this.date,
    required this.revenue,
  });
}

class CategoryData {
  final String name;
  final double percentage;

  CategoryData({
    required this.name,
    required this.percentage,
  });
}

class RecentOrderData {
  final String id;
  final String customerName;
  final DateTime date;
  final double amount;
  final String status;

  RecentOrderData({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.status,
  });
}
