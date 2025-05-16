class Review {
  final String id;
  final String userId;
  final String productId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final List<String>? images;
  final DateTime createdAt;
  final int helpfulCount;
  final bool verified;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.images,
    required this.createdAt,
    this.helpfulCount = 0,
    this.verified = false,
  });

  Review copyWith({
    String? id,
    String? userId,
    String? productId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    int? helpfulCount,
    bool? verified,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      verified: verified ?? this.verified,
    );
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'helpfulCount': helpfulCount,
      'verified': verified,
    };
  }

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, productId: $productId, userName: $userName, rating: $rating, comment: $comment, helpfulCount: $helpfulCount, verified: $verified)';
  }
}

class ReviewsData {
  final List<Review> reviews;
  final int totalCount;
  final Map<int, int> ratingCounts;
  final double averageRating;

  ReviewsData({
    required this.reviews,
    required this.totalCount,
    required this.ratingCounts,
    required this.averageRating,
  });

  factory ReviewsData.empty() {
    return ReviewsData(
      reviews: [],
      totalCount: 0,
      ratingCounts: {
        5: 0,
        4: 0,
        3: 0,
        2: 0,
        1: 0,
      },
      averageRating: 0,
    );
  }

  factory ReviewsData.fromJson(Map<String, dynamic> json) {
    return ReviewsData(
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      ratingCounts: Map<int, int>.from(json['ratingCounts'] as Map),
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'totalCount': totalCount,
      'ratingCounts': ratingCounts,
      'averageRating': averageRating,
    };
  }
} 