import 'package:team_nlq_tdtu/core/constants/app_constants.dart';
import 'package:team_nlq_tdtu/core/utils/api_helper.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/category_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/product_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/models/review_model.dart';
import 'package:team_nlq_tdtu/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiHelper _apiHelper;

  ProductRepositoryImpl({required ApiHelper apiHelper})
    : _apiHelper = apiHelper;

  @override
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
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (categoryId != null) 'category_id': categoryId,
        if (query != null) 'q': query,
        if (sortBy != null) 'sort_by': sortBy,
        if (ascending != null) 'order': ascending ? 'asc' : 'desc',
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (brand != null) 'brand': brand,
      };

      final response = await _apiHelper.request(
        endpoint: AppConstants.productsEndpoint,
        method: HttpMethod.get,
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get products',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error fetching products: ${e.toString()}', 500);
    }
  }

  @override
  Future<ApiResponse<Product>> getProductById(String id) async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/$id',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final product = Product.fromJson(response.data);
        return ApiResponse.success(product, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get product',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error fetching product: ${e.toString()}', 500);
    }
  }

  @override
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await _apiHelper.request(
        endpoint: AppConstants.categoriesEndpoint,
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final categories = data.map((json) => Category.fromJson(json)).toList();
        return ApiResponse.success(categories, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get categories',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching categories: ${e.toString()}',
        500,
      );
    }
  }

  @override
  Future<ApiResponse<Category>> getCategoryById(String id) async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.categoriesEndpoint}/$id',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final category = Category.fromJson(response.data);
        return ApiResponse.success(category, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get category',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error fetching category: ${e.toString()}', 500);
    }
  }

  @override
  Future<ApiResponse<List<Product>>> getFeaturedProducts() async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/featured',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get featured products',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching featured products: ${e.toString()}',
        500,
      );
    }
  }

  @override
  Future<ApiResponse<List<Product>>> getNewArrivals() async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/new',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get new arrivals',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching new arrivals: ${e.toString()}',
        500,
      );
    }
  }

  @override
  Future<ApiResponse<List<Product>>> getBestSellers() async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/bestsellers',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get bestsellers',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching bestsellers: ${e.toString()}',
        500,
      );
    }
  }

  @override
  Future<ApiResponse<List<Product>>> getRelatedProducts(
    String productId,
  ) async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/$productId/related',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get related products',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error fetching related products: ${e.toString()}',
        500,
      );
    }
  }

  @override
  Future<ApiResponse<List<Review>>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/$productId/reviews',
        method: HttpMethod.get,
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final reviews = data.map((json) => Review.fromJson(json)).toList();
        return ApiResponse.success(reviews, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get reviews',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error fetching reviews: ${e.toString()}', 500);
    }
  }

  @override
  Future<ApiResponse<Review>> addReview({
    required String productId,
    required double rating,
    required String comment,
    List<String>? images,
  }) async {
    try {
      final data = {
        'product_id': productId,
        'rating': rating,
        'comment': comment,
        if (images != null) 'images': images,
      };

      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/$productId/reviews',
        method: HttpMethod.post,
        data: data,
      );

      if (response.isSuccess) {
        final review = Review.fromJson(response.data);
        return ApiResponse.success(review, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to add review',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error adding review: ${e.toString()}', 500);
    }
  }

  @override
  Future<ApiResponse<bool>> markReviewHelpful(String reviewId) async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/reviews/$reviewId/helpful',
        method: HttpMethod.post,
      );

      if (response.isSuccess) {
        return ApiResponse.success(true, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to mark review as helpful',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error marking review as helpful: ${e.toString()}',
        500,
      );
    }
  }

  @override
  Future<ApiResponse<List<String>>> getProductBrands() async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/brands',
        method: HttpMethod.get,
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final brands = data.map((json) => json.toString()).toList();
        return ApiResponse.success(brands, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to get brands',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error fetching brands: ${e.toString()}', 500);
    }
  }

  @override
  Future<ApiResponse<List<Product>>> searchProducts(String query) async {
    try {
      final response = await _apiHelper.request(
        endpoint: '${AppConstants.productsEndpoint}/search',
        method: HttpMethod.get,
        queryParameters: {'q': query},
      );

      if (response.isSuccess) {
        final List<dynamic> data = response.data;
        final products = data.map((json) => Product.fromJson(json)).toList();
        return ApiResponse.success(products, response.statusCode);
      } else {
        return ApiResponse.error(
          response.errorMessage ?? 'Failed to search products',
          response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Error searching products: ${e.toString()}',
        500,
      );
    }
  }
}
