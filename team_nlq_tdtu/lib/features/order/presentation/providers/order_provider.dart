import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/core/services/api_service.dart';
import 'package:team_nlq_tdtu/features/order/domain/enums/order_status.dart';
import 'package:team_nlq_tdtu/features/order/domain/models/order_model.dart';
import 'package:team_nlq_tdtu/features/order/domain/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final ApiService _apiService;

  OrderProvider({
    required OrderRepository orderRepository,
    required ApiService apiService,
  })  : _orderRepository = orderRepository,
        _apiService = apiService;

  // Trạng thái
  bool _isLoading = false;
  bool _isCreatingOrder = false;
  bool _hasError = false;
  String? _errorMessage;

  // Dữ liệu
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  OrderStatus? _statusFilter;

  // Getters
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  OrderStatus? get statusFilter => _statusFilter;

  // Lọc đơn hàng theo trạng thái
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Lấy danh sách đơn hàng của người dùng
  Future<void> getUserOrders(
    String userId, {
    OrderStatus? status,
    bool refresh = false,
    int page = 1,
    int limit = 10,
  }) async {
    if (refresh) {
      _orders = [];
    }

    if (page == 1) {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _orderRepository.getUserOrders(
        userId: int.tryParse(userId) ?? 0,
        status: status,
        page: page,
        limit: limit,
      );

      // Xử lý dữ liệu trả về từ repository
      if (response.containsKey('error') &&
          response['error'] != null &&
          response['error'] is String) {
        _hasError = true;
        _errorMessage = response['error'].toString();
      } else {
        // Chuyển đổi dữ liệu từ API thành danh sách OrderModel
        List<OrderModel> newOrders = [];
        if (response.containsKey('data') && response['data'] is List) {
          for (var item in response['data']) {
            try {
              newOrders.add(OrderModel.fromJson(item));
            } catch (e) {
              debugPrint('Lỗi chuyển đổi đơn hàng: $e');
            }
          }
        }

        if (page == 1) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }
      }

      _statusFilter = status;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  // Lấy chi tiết đơn hàng
  Future<void> getOrderDetails(String orderId) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderRepository.getOrderById(orderId);
      if (order != null) {
        _selectedOrder = order;
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Không thể tải thông tin đơn hàng, vui lòng thử lại sau';
        notifyListeners();
      }
    } catch (error) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  // Tạo đơn hàng mới
  Future<OrderModel?> createOrder({
    required String userId,
    required OrderModel order,
  }) async {
    _isCreatingOrder = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final newOrder = await _orderRepository.createOrder(
        userId: userId,
        order: order,
      );

      _isCreatingOrder = false;

      if (newOrder == null) {
        _hasError = true;
        _errorMessage = 'Không thể tạo đơn hàng, vui lòng thử lại sau';
      }

      notifyListeners();
      return newOrder;
    } catch (error) {
      _isCreatingOrder = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? note,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
        note: note,
      );

      if (updatedOrder != null) {
        // Cập nhật lại đơn hàng trong danh sách nếu có
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }

        // Cập nhật đơn hàng đang chọn nếu có
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = updatedOrder;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Không thể cập nhật trạng thái đơn hàng, vui lòng thử lại sau';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  // Hủy đơn hàng
  Future<bool> cancelOrder({
    required String orderId,
    String? cancelReason,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderRepository.cancelOrder(
        orderId: orderId,
        cancelReason: cancelReason,
      );

      if (updatedOrder != null) {
        // Cập nhật lại đơn hàng trong danh sách nếu có
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }

        // Cập nhật đơn hàng đang chọn nếu có
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = updatedOrder;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Không thể hủy đơn hàng, vui lòng thử lại sau';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  // Trả hàng/yêu cầu hoàn tiền
  Future<bool> returnOrder({
    required String orderId,
    required String returnReason,
    List<String>? returnImages,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderRepository.returnOrder(
        orderId: orderId,
        returnReason: returnReason,
        returnImages: returnImages,
      );

      if (updatedOrder != null) {
        // Cập nhật lại đơn hàng trong danh sách nếu có
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }

        // Cập nhật đơn hàng đang chọn nếu có
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = updatedOrder;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Không thể trả hàng, vui lòng thử lại sau';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  // Lọc đơn hàng theo trạng thái
  void filterByStatus(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  // Reset trạng thái lỗi
  void resetError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Tìm kiếm đơn hàng
  Future<void> searchOrders(String userId, String keyword) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final orders = await _orderRepository.searchOrders(userId, keyword);
      _orders = orders;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tìm kiếm đơn hàng: ${e.toString()}';
      notifyListeners();
    }
  }

  // Lọc đơn hàng theo khoảng thời gian
  Future<void> filterOrdersByDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final orders = await _orderRepository.filterOrdersByDateRange(
          userId, startDate, endDate);
      _orders = orders;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể lọc đơn hàng: ${e.toString()}';
      notifyListeners();
    }
  }
}
