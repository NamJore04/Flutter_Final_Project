import 'package:team_nlq_tdtu/core/utils/api_helper.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/category_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/product_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';

abstract class ProductRepository {
  Future<ApiResponse<List<Product>>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? query,
    String? sortBy,
    bool? ascending,
    double? minPrice,
    double? maxPrice,
    String? brand,
  });

  Future<ApiResponse<Product>> getProductById(String id);

  Future<ApiResponse<List<Category>>> getCategories();

  Future<ApiResponse<Category>> getCategoryById(String id);

  Future<ApiResponse<List<Product>>> getFeaturedProducts();

  Future<ApiResponse<List<Product>>> getNewArrivals();

  Future<ApiResponse<List<Product>>> getBestSellers();

  Future<ApiResponse<List<Product>>> getRelatedProducts(String productId);

  Future<ApiResponse<List<Review>>> getProductReviews(String productId, {int page = 1, int limit = 10});

  Future<ApiResponse<Review>> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String>? images,
  });

  Future<ApiResponse<bool>> markReviewHelpful(String reviewId);

  Future<ApiResponse<List<String>>> getProductBrands();

  Future<ApiResponse<List<Product>>> searchProducts(String query);
} 