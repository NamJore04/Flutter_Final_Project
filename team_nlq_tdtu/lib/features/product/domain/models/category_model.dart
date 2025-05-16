class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final int productCount;
  final bool featured;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.productCount,
    this.featured = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      productCount: json['productCount'],
      featured: json['featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'productCount': productCount,
      'featured': featured,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? productCount,
    bool? featured,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      productCount: productCount ?? this.productCount,
      featured: featured ?? this.featured,
    );
  }
} 