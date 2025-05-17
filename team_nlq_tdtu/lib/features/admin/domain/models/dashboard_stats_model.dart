class DashboardStatsModel {
  final int totalOrders;
  final int pendingOrders;
  final int processingOrders;
  final int deliveredOrders;
  final double totalRevenue;
  final double todayRevenue;
  final int totalProducts;
  final int lowStockProducts;
  final int totalUsers;
  final int newUsers;
  final List<ChartData> salesChart;
  final List<ChartData> orderStatusChart;

  DashboardStatsModel({
    required this.totalOrders,
    required this.pendingOrders,
    required this.processingOrders,
    required this.deliveredOrders,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalUsers,
    required this.newUsers,
    required this.salesChart,
    required this.orderStatusChart,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      processingOrders: json['processingOrders'] ?? 0,
      deliveredOrders: json['deliveredOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      totalProducts: json['totalProducts'] ?? 0,
      lowStockProducts: json['lowStockProducts'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
      salesChart: (json['salesChart'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
      orderStatusChart: (json['orderStatusChart'] as List<dynamic>?)
              ?.map((e) => ChartData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'processingOrders': processingOrders,
      'deliveredOrders': deliveredOrders,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'totalProducts': totalProducts,
      'lowStockProducts': lowStockProducts,
      'totalUsers': totalUsers,
      'newUsers': newUsers,
      'salesChart': salesChart.map((e) => e.toJson()).toList(),
      'orderStatusChart': orderStatusChart.map((e) => e.toJson()).toList(),
    };
  }
}

class ChartData {
  final String label;
  final double value;
  final String? color;

  ChartData({
    required this.label,
    required this.value,
    this.color,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color,
    };
  }
} 