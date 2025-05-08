import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_item_model.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_status_log.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final double total;
  final String deliveryAddress;
  final String contactPhone;
  final String contactName;
  final String paymentMethod;
  final bool isPaid;
  final OrderStatus status;
  final String? trackingNumber;
  final String? couponCode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderStatusLog> statusLogs;
  final int? loyaltyPointsEarned;
  final String? notes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.deliveryAddress,
    required this.contactPhone,
    required this.contactName,
    required this.paymentMethod,
    required this.isPaid,
    required this.status,
    this.trackingNumber,
    this.couponCode,
    required this.createdAt,
    this.updatedAt,
    required this.statusLogs,
    this.loyaltyPointsEarned,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      shippingFee: json['shippingFee'].toDouble(),
      tax: json['tax'].toDouble(),
      discount: json['discount'].toDouble(),
      total: json['total'].toDouble(),
      deliveryAddress: json['deliveryAddress'],
      contactPhone: json['contactPhone'],
      contactName: json['contactName'],
      paymentMethod: json['paymentMethod'],
      isPaid: json['isPaid'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.processing,
      ),
      trackingNumber: json['trackingNumber'],
      couponCode: json['couponCode'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      statusLogs: (json['statusLogs'] as List)
          .map((log) => OrderStatusLog.fromJson(log))
          .toList(),
      loyaltyPointsEarned: json['loyaltyPointsEarned'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'deliveryAddress': deliveryAddress,
      'contactPhone': contactPhone,
      'contactName': contactName,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'status': status.toString().split('.').last,
      'trackingNumber': trackingNumber,
      'couponCode': couponCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'statusLogs': statusLogs.map((log) => log.toJson()).toList(),
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'notes': notes,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? discount,
    double? total,
    String? deliveryAddress,
    String? contactPhone,
    String? contactName,
    String? paymentMethod,
    bool? isPaid,
    OrderStatus? status,
    String? trackingNumber,
    String? couponCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderStatusLog>? statusLogs,
    int? loyaltyPointsEarned,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      contactPhone: contactPhone ?? this.contactPhone,
      contactName: contactName ?? this.contactName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      couponCode: couponCode ?? this.couponCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      statusLogs: statusLogs ?? this.statusLogs,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      notes: notes ?? this.notes,
    );
  }

  bool get canCancel => status.canCancel;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isRefunded => status == OrderStatus.refunded;
  bool get isReturned => status == OrderStatus.returned;
}
