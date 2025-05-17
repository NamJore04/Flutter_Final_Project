class AdminStats {
  final int totalUsers;
  final int totalOrders;
  final int totalProducts;
  final double totalRevenue;
  final int pendingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int newUsers;
  final double salesGrowth;
  final double orderGrowth;

  AdminStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.newUsers,
    required this.salesGrowth,
    required this.orderGrowth,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
      shippedOrders: json['shippedOrders'] ?? 0,
      deliveredOrders: json['deliveredOrders'] ?? 0,
      newUsers: json['newUsers'] ?? 0,
      salesGrowth: (json['salesGrowth'] ?? 0).toDouble(),
      orderGrowth: (json['orderGrowth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalOrders': totalOrders,
      'totalProducts': totalProducts,
      'totalRevenue': totalRevenue,
      'pendingOrders': pendingOrders,
      'shippedOrders': shippedOrders,
      'deliveredOrders': deliveredOrders,
      'newUsers': newUsers,
      'salesGrowth': salesGrowth,
      'orderGrowth': orderGrowth,
    };
  }

  AdminStats copyWith({
    int? totalUsers,
    int? totalOrders,
    int? totalProducts,
    double? totalRevenue,
    int? pendingOrders,
    int? shippedOrders,
    int? deliveredOrders,
    int? newUsers,
    double? salesGrowth,
    double? orderGrowth,
  }) {
    return AdminStats(
      totalUsers: totalUsers ?? this.totalUsers,
      totalOrders: totalOrders ?? this.totalOrders,
      totalProducts: totalProducts ?? this.totalProducts,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      shippedOrders: shippedOrders ?? this.shippedOrders,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      newUsers: newUsers ?? this.newUsers,
      salesGrowth: salesGrowth ?? this.salesGrowth,
      orderGrowth: orderGrowth ?? this.orderGrowth,
    );
  }
} 