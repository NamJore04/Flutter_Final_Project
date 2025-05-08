import 'package:team_nlq_tdtu/features/order/domain/enums/reward_type.dart';

class RewardTransaction {
  final String id;
  final String userId;
  final int points;
  final RewardType type;
  final String? orderId;
  final String? productId;
  final String description;
  final DateTime timestamp;
  final DateTime? expiryDate;
  final bool isExpired;

  RewardTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    this.orderId,
    this.productId,
    required this.description,
    required this.timestamp,
    this.expiryDate,
    this.isExpired = false,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      id: json['id'],
      userId: json['userId'],
      points: json['points'],
      type: RewardType.values.firstWhere(
          (e) => e.toString() == 'RewardType.${json['type']}'),
      orderId: json['orderId'],
      productId: json['productId'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'type': type.toString().split('.').last,
      'orderId': orderId,
      'productId': productId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isExpired': isExpired,
    };
  }

  bool get isPositive => points > 0;
}

class RewardPointsModel {
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int spentPoints;
  final int expiredPoints;
  final List<RewardTransaction> transactions;
  final String? membershipLevel;
  final int? pointsToNextLevel;
  final double conversionRate; // Tỷ lệ quy đổi điểm thành tiền

  RewardPointsModel({
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.spentPoints,
    required this.expiredPoints,
    required this.transactions,
    this.membershipLevel,
    this.pointsToNextLevel,
    this.conversionRate = 100.0, // Mặc định 100 điểm = 1.000đ
  });

  factory RewardPointsModel.fromJson(Map<String, dynamic> json) {
    return RewardPointsModel(
      userId: json['userId'],
      totalPoints: json['totalPoints'],
      availablePoints: json['availablePoints'],
      spentPoints: json['spentPoints'],
      expiredPoints: json['expiredPoints'],
      transactions: (json['transactions'] as List)
          .map((tx) => RewardTransaction.fromJson(tx))
          .toList(),
      membershipLevel: json['membershipLevel'],
      pointsToNextLevel: json['pointsToNextLevel'],
      conversionRate: json['conversionRate'] ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'spentPoints': spentPoints,
      'expiredPoints': expiredPoints,
      'transactions': transactions.map((tx) => tx.toJson()).toList(),
      'membershipLevel': membershipLevel,
      'pointsToNextLevel': pointsToNextLevel,
      'conversionRate': conversionRate,
    };
  }

  /// Quy đổi điểm thành tiền (VND)
  double pointsToMoney(int points) {
    return (points / conversionRate) * 1000;
  }

  /// Quy đổi tiền (VND) thành điểm
  int moneyToPoints(double money) {
    return (money / 1000 * conversionRate).round();
  }
}

class MembershipLevel {
  final String id;
  final String name;
  final String description;
  final int requiredPoints;
  final double discountPercent;
  final List<String> benefits;
  final String iconUrl;

  MembershipLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredPoints,
    required this.discountPercent,
    required this.benefits,
    required this.iconUrl,
  });

  factory MembershipLevel.fromJson(Map<String, dynamic> json) {
    return MembershipLevel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      requiredPoints: json['requiredPoints'],
      discountPercent: json['discountPercent'].toDouble(),
      benefits: List<String>.from(json['benefits']),
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requiredPoints': requiredPoints,
      'discountPercent': discountPercent,
      'benefits': benefits,
      'iconUrl': iconUrl,
    };
  }
} 