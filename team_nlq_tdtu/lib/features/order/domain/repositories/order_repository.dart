import 'package:team_nlq_tdtu/core/services/api_service.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:flutter/foundation.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository({required ApiService apiService}) : _apiService = apiService;

  /// Lấy danh sách đơn hàng của người dùng
  Future<Map<String, dynamic>> getUserOrders({
    required int userId,
    int page = 1,
    int limit = 10,
    OrderStatus? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.value;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }

      final response = await _apiService.get(
        '/orders/user/$userId',
        queryParameters: queryParams,
      );

      // Kiểm tra lỗi từ API
      if (response is Map<String, dynamic> && response['error'] == true) {
        // Trả về dữ liệu rỗng với định dạng hợp lệ để ứng dụng không bị crash
        return {
          'data': [],
          'pagination': {
            'total': 0,
            'page': page,
            'limit': limit,
            'totalPages': 0,
          },
          'error': response['message'] ?? 'Không thể tải danh sách đơn hàng',
          'offline': response['offline'] ?? false,
        };
      }

      return response;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách đơn hàng: $e');
      // Trả về dữ liệu rỗng với định dạng hợp lệ
      return {
        'data': [],
        'pagination': {
          'total': 0,
          'page': page,
          'limit': limit,
          'totalPages': 0,
        },
        'error': e.toString(),
      };
    }
  }

  // Lấy chi tiết đơn hàng theo ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return null;
        }
        
        if (response['data'] != null) {
          return OrderModel.fromJson(response['data']);
        }
        return null;
      } else if (response != null && response.statusCode == 200 && response.data != null) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        debugPrint('Không thể lấy chi tiết đơn hàng: ${response?.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy chi tiết đơn hàng: $e');
      return null;
    }
  }

  // Tạo đơn hàng mới
  Future<OrderModel?> createOrder({
    required String userId,
    required OrderModel order,
  }) async {
    try {
      final data = order.toJson();
      data['userId'] = userId;
      
      final response = await _apiService.post(
        '/orders',
        data: data,
      );
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return null;
        }
        
        if (response['data'] != null) {
          return OrderModel.fromJson(response['data']);
        }
        return null;
      } else if (response != null && response.statusCode == 201 && response.data != null) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        debugPrint('Không thể tạo đơn hàng: ${response?.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi tạo đơn hàng: $e');
      return null;
    }
  }
  
  // Cập nhật trạng thái đơn hàng
  Future<OrderModel?> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? note,
  }) async {
    try {
      final data = {
        'status': status.value,
      };
      
      if (note != null) {
        data['note'] = note;
      }
      
      final response = await _apiService.put(
        '/orders/$orderId/status',
        data: data,
      );
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return null;
        }
        
        if (response['data'] != null) {
          return OrderModel.fromJson(response['data']);
        }
        return null;
      } else if (response != null && response.statusCode == 200 && response.data != null) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        debugPrint('Không thể cập nhật trạng thái đơn hàng: ${response?.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật trạng thái đơn hàng: $e');
      return null;
    }
  }
  
  // Hủy đơn hàng
  Future<OrderModel?> cancelOrder({
    required String orderId,
    String? cancelReason,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (cancelReason != null) {
        data['reason'] = cancelReason;
      }
      
      final response = await _apiService.put(
        '/orders/$orderId/cancel',
        data: data,
      );
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return null;
        }
        
        if (response['data'] != null) {
          return OrderModel.fromJson(response['data']);
        }
        return null;
      } else if (response != null && response.statusCode == 200 && response.data != null) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        debugPrint('Không thể hủy đơn hàng: ${response?.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi hủy đơn hàng: $e');
      return null;
    }
  }
  
  // Trả hàng
  Future<OrderModel?> returnOrder({
    required String orderId,
    required String returnReason,
    List<String>? returnImages,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'reason': returnReason,
      };
      
      if (returnImages != null && returnImages.isNotEmpty) {
        data['images'] = returnImages;
      }
      
      final response = await _apiService.post(
        '/orders/$orderId/return',
        data: data,
      );
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return null;
        }
        
        if (response['data'] != null) {
          return OrderModel.fromJson(response['data']);
        }
        return null;
      } else if (response != null && response.statusCode == 200 && response.data != null) {
        return OrderModel.fromJson(response.data['data']);
      } else {
        debugPrint('Không thể trả hàng: ${response?.statusMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi khi trả hàng: $e');
      return null;
    }
  }

  // Cập nhật đơn hàng
  Future<bool> updateOrder(OrderModel order) async {
    try {
      final response = await _apiService.put(
        '/orders/${order.id}',
        data: order.toJson(),
      );
      
      if (response is Map<String, dynamic>) {
        return response['error'] != true;
      } else if (response != null && response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Không thể cập nhật đơn hàng: ${response?.statusMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi khi cập nhật đơn hàng: $e');
      return false;
    }
  }

  // Tìm kiếm đơn hàng
  Future<List<OrderModel>> searchOrders(String userId, String keyword) async {
    try {
      final response = await _apiService.get(
        '/orders/search',
        queryParameters: {
          'userId': userId,
          'keyword': keyword,
        },
      );
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return [];
        }
        
        if (response['data'] != null && response['data'] is List) {
          try {
            return (response['data'] as List)
                .map((item) => OrderModel.fromJson(item))
                .toList();
          } catch (e) {
            debugPrint('Lỗi chuyển đổi dữ liệu tìm kiếm: $e');
            return [];
          }
        }
        return [];
      } else if (response != null && response.statusCode == 200 && response.data != null) {
        try {
          final List<dynamic> data = response.data['data'];
          return data.map((item) => OrderModel.fromJson(item)).toList();
        } catch (e) {
          debugPrint('Lỗi chuyển đổi dữ liệu tìm kiếm: $e');
          return [];
        }
      } else {
        debugPrint('Không thể tìm kiếm đơn hàng: ${response?.statusMessage}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi tìm kiếm đơn hàng: $e');
      return [];
    }
  }

  // Lọc đơn hàng theo khoảng thời gian
  Future<List<OrderModel>> filterOrdersByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final response = await _apiService.get(
        '/orders/filter',
        queryParameters: {
          'userId': userId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      
      if (response is Map<String, dynamic>) {
        if (response['error'] == true) {
          debugPrint('Lỗi API: ${response['message']}');
          return [];
        }
        
        if (response['data'] != null && response['data'] is List) {
          try {
            return (response['data'] as List)
                .map((item) => OrderModel.fromJson(item))
                .toList();
          } catch (e) {
            debugPrint('Lỗi chuyển đổi dữ liệu lọc: $e');
            return [];
          }
        }
        return [];
      } else if (response != null && response.statusCode == 200 && response.data != null) {
        try {
          final List<dynamic> data = response.data['data'];
          return data.map((item) => OrderModel.fromJson(item)).toList();
        } catch (e) {
          debugPrint('Lỗi chuyển đổi dữ liệu lọc: $e');
          return [];
        }
      } else {
        debugPrint('Không thể lọc đơn hàng: ${response?.statusMessage}');
        return [];
      }
    } catch (e) {
      debugPrint('Lỗi khi lọc đơn hàng: $e');
      return [];
    }
  }
} 