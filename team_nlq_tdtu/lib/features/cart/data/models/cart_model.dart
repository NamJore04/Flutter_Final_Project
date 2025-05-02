import 'package:flutter/foundation.dart';
import 'cart_item_model.dart';

@immutable
class CartModel {
  final String id;
  final List<CartItemModel> items;
  final String? couponCode;
  final double couponDiscount;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;

  CartModel({
    required this.id,
    this.items = const [],
    this.couponCode,
    this.couponDiscount = 0.0,
    this.shipping = 0.0,
    this.tax = 0.0,
  }) : 
    subtotal = _calculateSubtotal(items),
    total = _calculateTotal(items, couponDiscount, tax, shipping);
  
  static double _calculateSubtotal(List<CartItemModel> items) {
    double sum = 0.0;
    for (var item in items) {
      sum += item.totalPrice;
    }
    return sum;
  }
  
  static double _calculateTotal(List<CartItemModel> items, double couponDiscount, double tax, double shipping) {
    double sum = 0.0;
    for (var item in items) {
      sum += item.totalPrice;
    }
    return sum - couponDiscount + tax + shipping;
  }

  CartModel copyWith({
    String? id,
    List<CartItemModel>? items,
    String? couponCode,
    double? couponDiscount,
    double? shipping,
    double? tax,
  }) {
    return CartModel(
      id: id ?? this.id,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'couponCode': couponCode,
      'couponDiscount': couponDiscount,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>).map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)).toList(),
      couponCode: json['couponCode'] as String?,
      couponDiscount: (json['couponDiscount'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
    );
  }

  int get itemCount => items.length;
  
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CartModel &&
      other.id == id &&
      listEquals(other.items, items) &&
      other.couponCode == couponCode &&
      other.couponDiscount == couponDiscount &&
      other.subtotal == subtotal &&
      other.tax == tax &&
      other.shipping == shipping &&
      other.total == total;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      items.hashCode ^
      couponCode.hashCode ^
      couponDiscount.hashCode ^
      subtotal.hashCode ^
      tax.hashCode ^
      shipping.hashCode ^
      total.hashCode;
  }
} 