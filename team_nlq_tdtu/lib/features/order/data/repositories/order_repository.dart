import 'dart:convert';

import 'package:team_nlq_tdtu/core/services/api_service.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/reward_points_model.dart';
import 'package:dio/dio.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository({required ApiService apiService}) : _apiService = apiService;

  // Lấy danh sách đơn hàng của người dùng
  Future<List<OrderModel>> getUserOrders({
    required String userId,
    OrderStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'userId': userId,
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _apiService.get(
        '/orders',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Lấy chi tiết đơn hàng theo ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      return OrderModel.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Tạo đơn hàng mới
  Future<OrderModel> createOrder({
    required String userId,
    required OrderModel order,
  }) async {
    try {
      final response = await _apiService.post(
        '/orders',
        data: order.toJson(),
      );
      return OrderModel.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? note,
  }) async {
    try {
      final response = await _apiService.patch(
        '/orders/$orderId/status',
        data: {
          'status': status.toString().split('.').last,
          'note': note,
        },
      );
      return OrderModel.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Hủy đơn hàng
  Future<OrderModel> cancelOrder({
    required String orderId,
    String? cancelReason,
  }) async {
    try {
      final response = await _apiService.patch(
        '/orders/$orderId/cancel',
        data: {
          'reason': cancelReason,
        },
      );
      return OrderModel.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Trả hàng/hoàn tiền
  Future<OrderModel> returnOrder({
    required String orderId,
    required String returnReason,
    List<String>? returnImages,
  }) async {
    try {
      final response = await _apiService.post(
        '/orders/$orderId/returns',
        data: {
          'reason': returnReason,
          'images': returnImages,
        },
      );
      return OrderModel.fromJson(response.data);
    } catch (error) {
      throw _handleError(error);
    }
  }

  // Lấy lịch sử đơn hàng
  Future<List<OrderStatusHistory>> getOrderStatusHistory(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/history');
      final List<dynamic> historyData = jsonDecode(response.body)['data'];
      return historyData
          .map((data) => OrderStatusHistory.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy lịch sử đơn hàng: $e');
    }
  }

  // ============ REWARD POINTS SYSTEM ============

  // Lấy thông tin điểm thưởng của người dùng
  Future<RewardPointsModel> getUserRewardPoints(String userId) async {
    try {
      final response = await _apiService.get('/rewards/users/$userId');
      final rewardData = jsonDecode(response.body)['data'];
      return RewardPointsModel.fromJson(rewardData);
    } catch (e) {
      throw Exception('Không thể lấy thông tin điểm thưởng: $e');
    }
  }

  // Lấy lịch sử giao dịch điểm thưởng
  Future<List<RewardTransaction>> getRewardTransactions(String userId) async {
    try {
      final response =
          await _apiService.get('/rewards/users/$userId/transactions');
      final List<dynamic> transactionsData = jsonDecode(response.body)['data'];
      return transactionsData
          .map((data) => RewardTransaction.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy lịch sử giao dịch điểm thưởng: $e');
    }
  }

  // Sử dụng điểm thưởng cho đơn hàng
  Future<OrderModel> applyRewardPoints(
      String orderId, int points, String userId) async {
    try {
      final response = await _apiService.post(
        '/orders/$orderId/apply-points',
        body: jsonEncode({
          'points': points,
          'userId': userId,
        }),
      );
      final orderData = jsonDecode(response.body)['data'];
      return OrderModel.fromJson(orderData);
    } catch (e) {
      throw Exception('Không thể áp dụng điểm thưởng: $e');
    }
  }

  // Lấy danh sách cấp độ thành viên
  Future<List<MembershipLevel>> getMembershipLevels() async {
    try {
      final response = await _apiService.get('/rewards/membership-levels');
      final List<dynamic> levelsData = jsonDecode(response.body)['data'];
      return levelsData.map((data) => MembershipLevel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách cấp độ thành viên: $e');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;

        if (statusCode == 404) {
          return Exception('Đơn hàng không tồn tại');
        } else if (statusCode == 403) {
          return Exception('Bạn không có quyền truy cập đơn hàng này');
        } else if (statusCode == 400) {
          return Exception(data['message'] ?? 'Dữ liệu đơn hàng không hợp lệ');
        } else {
          return Exception('Lỗi máy chủ: ${error.message}');
        }
      }
      return Exception('Lỗi kết nối: ${error.message}');
    }
    return Exception('Đã xảy ra lỗi không xác định: $error');
  }
}
