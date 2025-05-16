class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final double? discountPrice;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String categoryId;
  final String? categoryName;
  final String? brand;
  final Map<String, dynamic>? attributes;
  final int stock;
  final bool isAvailable;
  final bool isOnSale;
  final List<Map<String, dynamic>>? features;
  final Map<String, dynamic>? specifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.discountPrice,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.categoryId,
    this.categoryName,
    this.brand,
    this.attributes,
    required this.stock,
    this.isAvailable = true,
    this.isOnSale = false,
    this.features,
    this.specifications,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating a Product from JSON data
  factory Product.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>>? featuresFromJson;
    if (json['features'] != null) {
      featuresFromJson = List<Map<String, dynamic>>.from(json['features']);
    }
    
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      images: List<String>.from(json['images']),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      brand: json['brand'],
      attributes: json['attributes'],
      stock: json['stock'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      isOnSale: json['isOnSale'] ?? false,
      features: featuresFromJson,
      specifications: json['specifications'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Method to convert a Product to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'attributes': attributes,
      'stock': stock,
      'isAvailable': isAvailable,
      'isOnSale': isOnSale,
      'features': features,
      'specifications': specifications,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  // Get current price (discounted price if available, otherwise regular price)
  double get currentPrice => discountPrice ?? price;
  
  // Check if product has a discount
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  // Calculate discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }
  
  // Get stock quantity
  int get stockQuantity => stock;
  
  // Check if product is in stock
  bool get isInStock => stock > 0;
  
  // Create a copy of this Product with some changes
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    double? discountPrice,
    List<String>? images,
    double? rating,
    int? reviewCount,
    String? categoryId,
    String? categoryName,
    String? brand,
    Map<String, dynamic>? attributes,
    int? stock,
    bool? isAvailable,
    bool? isOnSale,
    List<Map<String, dynamic>>? features,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brand: brand ?? this.brand,
      attributes: attributes ?? this.attributes,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnSale: isOnSale ?? this.isOnSale,
      features: features ?? this.features,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 