import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/features/product/data/repositories/review_repository.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/enums/review_sort_option.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _reviewRepository;
  
  ReviewProvider({
    required ReviewRepository reviewRepository,
  }) : _reviewRepository = reviewRepository;

  // Trạng thái danh sách đánh giá
  ReviewsData? _reviewsData;
  bool _isLoading = false;
  String? _error;
  
  // Trạng thái bộ lọc & sắp xếp
  int? _selectedRating;
  ReviewSortOption _currentSortOption = ReviewSortOption.newest;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  
  // Getters
  ReviewsData? get reviewsData => _reviewsData;
  List<Review> get reviews => _reviewsData?.reviews ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedRating => _selectedRating;
  bool get hasMore => _hasMore;
  ReviewSortOption get currentSortOption => _currentSortOption;
  
  // Lấy đánh giá cho sản phẩm
  Future<void> getProductReviews(String productId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _reviewsData = null;
    }
    
    if (!_hasMore || _isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _reviewRepository.getProductReviews(
        productId,
        page: _currentPage,
        limit: _pageSize,
        rating: _selectedRating,
        sortBy: _getSortByString(_currentSortOption),
      );
      
      if (_currentPage == 1) {
        _reviewsData = result;
      } else {
        final updatedReviews = [..._reviewsData!.reviews, ...result.reviews];
        _reviewsData = _reviewsData!.copyWith(reviews: updatedReviews);
      }
      
      _hasMore = result.reviews.length >= _pageSize;
      _currentPage++;
    } catch (e) {
      _error = 'Không thể tải đánh giá: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Tải thêm đánh giá
  Future<void> loadMore(String productId) async {
    if (!_hasMore || _isLoading) return;
    await getProductReviews(productId);
  }
  
  // Lọc theo số sao
  Future<void> filterByRating(String productId, int? rating) async {
    if (_selectedRating == rating) return;
    
    _selectedRating = rating;
    await getProductReviews(productId, refresh: true);
  }
  
  // Sắp xếp đánh giá
  Future<void> sortReviews(String productId, ReviewSortOption sortOption) async {
    if (_currentSortOption == sortOption) return;
    
    _currentSortOption = sortOption;
    await getProductReviews(productId, refresh: true);
  }
  
  // Chuyển đổi ReviewSortOption thành chuỗi cho API
  String _getSortByString(ReviewSortOption option) {
    switch (option) {
      case ReviewSortOption.newest:
        return 'newest';
      case ReviewSortOption.oldest:
        return 'oldest';
      case ReviewSortOption.highestRating:
        return 'highest_rating';
      case ReviewSortOption.lowestRating:
        return 'lowest_rating';
      case ReviewSortOption.mostHelpful:
        return 'most_helpful';
    }
  }
  
  // Thêm đánh giá mới
  Future<void> addReview({
    required String productId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newReview = await _reviewRepository.addReview(
        productId: productId,
        rating: rating,
        comment: comment,
        images: images,
      );
      
      // Thêm đánh giá mới vào đầu danh sách
      if (_reviewsData != null) {
        final updatedReviews = [newReview, ..._reviewsData!.reviews];
        _reviewsData = _reviewsData!.copyWith(
          reviews: updatedReviews,
          totalCount: _reviewsData!.totalCount + 1,
        );
      }
    } catch (e) {
      _error = 'Không thể thêm đánh giá: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Đánh dấu đánh giá là hữu ích
  Future<void> markReviewAsHelpful(String reviewId) async {
    try {
      await _reviewRepository.markReviewAsHelpful(reviewId);
      
      // Cập nhật số lượng đánh giá hữu ích
      if (_reviewsData != null) {
        final updatedReviews = _reviewsData!.reviews.map((review) {
          if (review.id == reviewId) {
            return review.copyWith(helpfulCount: review.helpfulCount + 1);
          }
          return review;
        }).toList();
        
        _reviewsData = _reviewsData!.copyWith(reviews: updatedReviews);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể đánh dấu đánh giá là hữu ích: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Báo cáo đánh giá
  Future<bool> reportReview({
    required String reviewId,
    required String reason,
    String? description,
  }) async {
    try {
      return await _reviewRepository.reportReview(
        reviewId: reviewId,
        reason: reason,
        description: description,
      );
    } catch (e) {
      _error = 'Không thể báo cáo đánh giá: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Xóa đánh giá
  Future<bool> deleteReview(String reviewId) async {
    try {
      final result = await _reviewRepository.deleteReview(reviewId);
      
      if (result && _reviewsData != null) {
        // Loại bỏ đánh giá khỏi danh sách
        final updatedReviews = _reviewsData!.reviews
            .where((review) => review.id != reviewId)
            .toList();
        
        _reviewsData = _reviewsData!.copyWith(
          reviews: updatedReviews,
          totalCount: _reviewsData!.totalCount - 1,
        );
        
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _error = 'Không thể xóa đánh giá: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Reset lỗi
  void resetError() {
    _error = null;
    notifyListeners();
  }

  // Đặt tùy chọn sắp xếp hiện tại
  void setSortOption(ReviewSortOption option) {
    if (_currentSortOption != option) {
      _currentSortOption = option;
      notifyListeners();
    }
  }
} 