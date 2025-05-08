import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';

class OrderStatusLog {
  final String id;
  final OrderStatus status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;

  OrderStatusLog({
    required this.id,
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
  });

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) {
    return OrderStatusLog(
      id: json['id'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.processing,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'updatedBy': updatedBy,
    };
  }
} 