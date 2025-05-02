import 'package:flutter/foundation.dart';

enum CouponType {
  percentage,    // Giảm theo phần trăm
  fixedAmount,   // Giảm theo số tiền cố định
  freeShipping,  // Miễn phí vận chuyển
}

@immutable
class CouponModel {
  final String id;
  final String code;
  final String description;
  final CouponType type;
  final double value;
  final double minOrderValue;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isActive;
  final int usageLimit;
  final int usageCount;
  final List<String> applicableProductIds;
  final List<String> applicableCategoryIds;

  const CouponModel({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderValue = 0.0,
    required this.validFrom,
    required this.validTo,
    this.isActive = true,
    this.usageLimit = 0, // 0 = không giới hạn
    this.usageCount = 0,
    this.applicableProductIds = const [],
    this.applicableCategoryIds = const [],
  });

  bool get isValid => isActive && DateTime.now().isAfter(validFrom) && DateTime.now().isBefore(validTo);

  bool get hasReachedLimit => usageLimit > 0 && usageCount >= usageLimit;

  bool isApplicableToProduct(String productId) {
    return applicableProductIds.isEmpty || applicableProductIds.contains(productId);
  }

  bool isApplicableToCategory(String categoryId) {
    return applicableCategoryIds.isEmpty || applicableCategoryIds.contains(categoryId);
  }

  double calculateDiscount(double subtotal) {
    if (!isValid || hasReachedLimit || subtotal < minOrderValue) {
      return 0.0;
    }

    switch (type) {
      case CouponType.percentage:
        return (subtotal * value / 100).clamp(0.0, subtotal);
      case CouponType.fixedAmount:
        return value.clamp(0.0, subtotal);
      case CouponType.freeShipping:
        return 0.0; // Được xử lý riêng tại bước tính toán vận chuyển
    }
  }

  CouponModel copyWith({
    String? id,
    String? code,
    String? description,
    CouponType? type,
    double? value,
    double? minOrderValue,
    DateTime? validFrom,
    DateTime? validTo,
    bool? isActive,
    int? usageLimit,
    int? usageCount,
    List<String>? applicableProductIds,
    List<String>? applicableCategoryIds,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableCategoryIds: applicableCategoryIds ?? this.applicableCategoryIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'minOrderValue': minOrderValue,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'applicableProductIds': applicableProductIds,
      'applicableCategoryIds': applicableCategoryIds,
    };
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      type: CouponType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CouponType.percentage,
      ),
      value: (json['value'] as num).toDouble(),
      minOrderValue: (json['minOrderValue'] as num).toDouble(),
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      isActive: json['isActive'] as bool,
      usageLimit: json['usageLimit'] as int,
      usageCount: json['usageCount'] as int,
      applicableProductIds: List<String>.from(json['applicableProductIds'] as List),
      applicableCategoryIds: List<String>.from(json['applicableCategoryIds'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CouponModel &&
      other.id == id &&
      other.code == code &&
      other.description == description &&
      other.type == type &&
      other.value == value &&
      other.minOrderValue == minOrderValue &&
      other.validFrom == validFrom &&
      other.validTo == validTo &&
      other.isActive == isActive &&
      other.usageLimit == usageLimit &&
      other.usageCount == usageCount &&
      listEquals(other.applicableProductIds, applicableProductIds) &&
      listEquals(other.applicableCategoryIds, applicableCategoryIds);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      code.hashCode ^
      description.hashCode ^
      type.hashCode ^
      value.hashCode ^
      minOrderValue.hashCode ^
      validFrom.hashCode ^
      validTo.hashCode ^
      isActive.hashCode ^
      usageLimit.hashCode ^
      usageCount.hashCode ^
      applicableProductIds.hashCode ^
      applicableCategoryIds.hashCode;
  }
} 