import 'package:flutter/foundation.dart';

@immutable
class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final double originalPrice;
  final int quantity;
  final Map<String, String> selectedOptions; // Ví dụ: {"Color": "Red", "Size": "XL"}
  final double totalPrice;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.quantity,
    this.selectedOptions = const {},
  }) : totalPrice = price * quantity;

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    double? price,
    double? originalPrice,
    int? quantity,
    Map<String, String>? selectedOptions,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'totalPrice': totalPrice,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      selectedOptions: Map<String, String>.from(json['selectedOptions'] as Map),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CartItemModel &&
      other.id == id &&
      other.productId == productId &&
      other.name == name &&
      other.image == image &&
      other.price == price &&
      other.originalPrice == originalPrice &&
      other.quantity == quantity &&
      mapEquals(other.selectedOptions, selectedOptions);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      productId.hashCode ^
      name.hashCode ^
      image.hashCode ^
      price.hashCode ^
      originalPrice.hashCode ^
      quantity.hashCode ^
      selectedOptions.hashCode;
  }
} 