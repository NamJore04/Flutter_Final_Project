import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';

abstract class ReviewRepository {
  Future<ReviewsData> getProductReviews(
    String productId, {
    int? page,
    int? limit,
    int? rating,
    String? sortBy,
  });

  Future<Review> addReview({
    required String productId,
    required int rating,
    required String comment,
    List<String>? images,
  });

  Future<bool> markReviewAsHelpful(String reviewId);

  Future<bool> reportReview({
    required String reviewId,
    required String reason,
    String? description,
  });

  Future<bool> deleteReview(String reviewId);
}

class ReviewRepositoryImpl implements ReviewRepository {
  @override
  Future<ReviewsData> getProductReviews(
    String productId, {
    int? page,
    int? limit,
    int? rating,
    String? sortBy,
  }) async {
    // Mock data - Sẽ thay bằng API call thực tế
    await Future.delayed(const Duration(milliseconds: 500));

    final List<Review> reviews = List.generate(
      10,
      (index) => Review(
        id: 'review_$index',
        userId: 'user_$index',
        productId: productId,
        userName: 'Người dùng ${index + 1}',
        userAvatar:
            index % 3 == 0
                ? null
                : 'https://ui-avatars.com/api/?name=User+${index + 1}',
        rating: 5 - (index % 5),
        comment:
            'Đây là đánh giá thứ ${index + 1} cho sản phẩm. Sản phẩm rất tốt, đóng gói cẩn thận, giao hàng nhanh. Tôi rất hài lòng với sản phẩm này.',
        images:
            index % 4 == 0
                ? [
                  'https://picsum.photos/id/${100 + index}/300/300',
                  'https://picsum.photos/id/${101 + index}/300/300',
                ]
                : null,
        createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        helpfulCount: index * 5,
        verified: index % 2 == 0,
      ),
    );

    final Map<int, int> ratingCounts = {5: 3, 4: 2, 3: 2, 2: 2, 1: 1};

    const double averageRating = 3.4;

    return ReviewsData(
      reviews: reviews,
      totalCount: 50,
      ratingCounts: ratingCounts,
      averageRating: averageRating,
    );
  }

  @override
  Future<Review> addReview({
    required String productId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    // Mock data - Sẽ thay bằng API call thực tế
    await Future.delayed(const Duration(seconds: 1));

    return Review(
      id: 'new_review_id',
      userId: 'current_user_id',
      productId: productId,
      userName: 'Người dùng hiện tại',
      userAvatar: null,
      rating: rating,
      comment: comment,
      images: images,
      createdAt: DateTime.now(),
      helpfulCount: 0,
      verified: true,
    );
  }

  @override
  Future<bool> markReviewAsHelpful(String reviewId) async {
    // Mock data - Sẽ thay bằng API call thực tế
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> reportReview({
    required String reviewId,
    required String reason,
    String? description,
  }) async {
    // Mock data - Sẽ thay bằng API call thực tế
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> deleteReview(String reviewId) async {
    // Mock data - Sẽ thay bằng API call thực tế
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
