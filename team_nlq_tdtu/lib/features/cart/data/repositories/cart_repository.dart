import 'package:flutter/foundation.dart';
import 'package:team_nlq_tdtu/core/services/api_service.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';
import '../models/coupon_model.dart';

abstract class CartRepository {
  Future<CartModel> getCart();
  Future<CartModel> addItem(CartItemModel item);
  Future<CartModel> updateItem(CartItemModel item);
  Future<CartModel> removeItem(String itemId);
  Future<CartModel> clearCart();
  Future<CouponModel?> applyCoupon(String couponCode);
  Future<CartModel> removeCoupon();
  Future<List<CouponModel>> getAvailableCoupons();
  Future<CartModel> syncCart();
  Future<double> calculateShipping(String addressId);
}

class CartRepositoryImpl implements CartRepository {
  final ApiService _apiService;

  CartRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  // Giả lập một giỏ hàng cho việc phát triển ban đầu
  CartModel _cart = CartModel(
    id: 'cart-001',
    items: const [],
    couponCode: null,
    couponDiscount: 0.0,
    shipping: 0.0,
    tax: 0.0,
  );

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await _apiService.get('/cart');

      if (response != null && response.statusCode == 200) {
        return CartModel.fromJson(response.data['data']);
      } else {
        throw Exception('Không thể lấy thông tin giỏ hàng');
      }
    } catch (e) {
      // Trả về giỏ hàng trống nếu có lỗi
      return CartModel(id: 'temp_cart_id');
    }
  }

  @override
  Future<CartModel> addItem(CartItemModel item) async {
    // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
    final existingItemIndex = _cart.items.indexWhere((i) =>
        i.productId == item.productId &&
        mapEquals(i.selectedOptions, item.selectedOptions));

    if (existingItemIndex >= 0) {
      // Nếu đã có, tăng số lượng
      final existingItem = _cart.items[existingItemIndex];
      final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity);

      final updatedItems = List<CartItemModel>.from(_cart.items);
      updatedItems[existingItemIndex] = updatedItem;

      _cart = _cart.copyWith(items: updatedItems);
    } else {
      // Nếu chưa có, thêm mới
      _cart = _cart.copyWith(items: [..._cart.items, item]);
    }

    // Trong triển khai thực tế
    // await _apiService.addToCart(item);

    // Giả lập delay mạng
    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<CartModel> updateItem(CartItemModel item) async {
    final updatedItems =
        _cart.items.map((i) => i.id == item.id ? item : i).toList();

    _cart = _cart.copyWith(items: updatedItems);

    // Trong triển khai thực tế
    // await _apiService.updateCartItem(item);

    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<CartModel> removeItem(String itemId) async {
    final updatedItems =
        _cart.items.where((item) => item.id != itemId).toList();
    _cart = _cart.copyWith(items: updatedItems);

    // Trong triển khai thực tế
    // await _apiService.removeFromCart(itemId);

    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<CartModel> clearCart() async {
    _cart = _cart.copyWith(
      items: [],
      couponCode: null,
      couponDiscount: 0.0,
    );

    // Trong triển khai thực tế
    // await _apiService.clearCart();

    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<CouponModel?> applyCoupon(String couponCode) async {
    // Giả lập một vài mã giảm giá để test
    final coupons = [
      CouponModel(
        id: 'coupon-001',
        code: 'WELCOME10',
        description: 'Giảm 10% cho đơn hàng đầu tiên',
        type: CouponType.percentage,
        value: 10.0,
        minOrderValue: 100000.0,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validTo: DateTime.now().add(const Duration(days: 30)),
      ),
      CouponModel(
        id: 'coupon-002',
        code: 'FREESHIP',
        description: 'Miễn phí vận chuyển',
        type: CouponType.freeShipping,
        value: 0.0,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validTo: DateTime.now().add(const Duration(days: 30)),
      ),
    ];

    // Tìm mã giảm giá hợp lệ
    final coupon = coupons.firstWhere((c) => c.code == couponCode && c.isValid,
        orElse: () =>
            throw Exception('Mã giảm giá không hợp lệ hoặc đã hết hạn'));

    // Kiểm tra giá trị tối thiểu
    if (_cart.subtotal < coupon.minOrderValue) {
      throw Exception(
          'Đơn hàng chưa đạt giá trị tối thiểu ${coupon.minOrderValue}đ');
    }

    // Áp dụng mã giảm giá
    double discount = coupon.calculateDiscount(_cart.subtotal);

    if (coupon.type == CouponType.freeShipping) {
      _cart = _cart.copyWith(
        couponCode: couponCode,
        shipping: 0.0,
      );
    } else {
      _cart = _cart.copyWith(
        couponCode: couponCode,
        couponDiscount: discount,
      );
    }

    // Trong triển khai thực tế
    // await _apiService.applyCoupon(couponCode);

    await Future.delayed(const Duration(milliseconds: 300));
    return coupon;
  }

  @override
  Future<CartModel> removeCoupon() async {
    _cart = _cart.copyWith(
      couponCode: null,
      couponDiscount: 0.0,
    );

    // Trong triển khai thực tế
    // await _apiService.removeCoupon();

    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<List<CouponModel>> getAvailableCoupons() async {
    // Giả lập dữ liệu để test
    final coupons = [
      CouponModel(
        id: 'coupon-001',
        code: 'WELCOME10',
        description: 'Giảm 10% cho đơn hàng đầu tiên',
        type: CouponType.percentage,
        value: 10.0,
        minOrderValue: 100000.0,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validTo: DateTime.now().add(const Duration(days: 30)),
      ),
      CouponModel(
        id: 'coupon-002',
        code: 'FREESHIP',
        description: 'Miễn phí vận chuyển',
        type: CouponType.freeShipping,
        value: 0.0,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validTo: DateTime.now().add(const Duration(days: 30)),
      ),
      CouponModel(
        id: 'coupon-003',
        code: 'SAVE50K',
        description: 'Giảm 50.000đ cho đơn hàng từ 200.000đ',
        type: CouponType.fixedAmount,
        value: 50000.0,
        minOrderValue: 200000.0,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validTo: DateTime.now().add(const Duration(days: 30)),
      ),
    ];

    // Trong triển khai thực tế
    // return await _apiService.getAvailableCoupons();

    await Future.delayed(const Duration(milliseconds: 300));
    return coupons;
  }

  @override
  Future<CartModel> syncCart() async {
    // Đồng bộ giỏ hàng giữa local và server khi người dùng đăng nhập
    // Trong triển khai thực tế
    // final serverCart = await _apiService.getCart();
    // final localCart = await _storageService.getCart();
    // Merge serverCart và localCart

    // Giả lập cho phát triển
    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<double> calculateShipping(String addressId) async {
    // Tính phí vận chuyển dựa trên địa chỉ và các sản phẩm trong giỏ hàng
    // Trong triển khai thực tế
    // final shippingFee = await _apiService.calculateShipping(addressId, _cart.items);

    // Giả lập cho phát triển
    await Future.delayed(const Duration(milliseconds: 300));

    // Miễn phí vận chuyển nếu đã áp dụng mã FREESHIP
    if (_cart.couponCode == 'FREESHIP') {
      return 0.0;
    }

    // Miễn phí vận chuyển cho đơn hàng > 500.000đ
    if (_cart.subtotal > 500000.0) {
      return 0.0;
    }

    // Phí cơ bản
    double shippingFee = 30000.0;

    // Cập nhật giỏ hàng
    _cart = _cart.copyWith(shipping: shippingFee);

    return shippingFee;
  }
}
