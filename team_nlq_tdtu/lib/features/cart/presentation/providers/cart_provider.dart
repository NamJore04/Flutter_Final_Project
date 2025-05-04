import 'package:flutter/foundation.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/coupon_model.dart';
import '../../data/repositories/cart_repository.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  error,
}

class CartProvider with ChangeNotifier {
  final CartRepository _cartRepository;
  
  CartProvider(this._cartRepository) {
    // Tự động lấy giỏ hàng khi khởi tạo provider
    _fetchCart();
  }
  
  // Trạng thái
  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _errorMessage;
  CouponModel? _coupon;
  List<CouponModel> _availableCoupons = [];
  bool _isProcessing = false;
  String? _selectedAddressId;
  
  // Getters
  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CartStatus.loading || _isProcessing;
  CouponModel? get coupon => _coupon;
  List<CouponModel> get availableCoupons => _availableCoupons;
  String? get selectedAddressId => _selectedAddressId;
  
  // Các tính toán phái sinh
  int get itemCount => _cart?.itemCount ?? 0;
  int get totalQuantity => _cart?.totalQuantity ?? 0;
  bool get isEmpty => _cart?.isEmpty ?? true;
  bool get isNotEmpty => _cart?.isNotEmpty ?? false;
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get tax => _cart?.tax ?? 0.0;
  double get shipping => _cart?.shipping ?? 0.0;
  double get couponDiscount => _cart?.couponDiscount ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  
  // Trạng thái xử lý
  bool _setLoading() {
    if (_isProcessing) return false;
    _isProcessing = true;
    notifyListeners();
    return true;
  }
  
  void _setLoaded(CartModel cart) {
    _cart = cart;
    _status = CartStatus.loaded;
    _isProcessing = false;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    _status = CartStatus.error;
    _isProcessing = false;
    notifyListeners();
  }
  
  // Các phương thức nghiệp vụ
  Future<void> _fetchCart() async {
    _status = CartStatus.loading;
    notifyListeners();
    
    try {
      final cart = await _cartRepository.getCart();
      _cart = cart;
      _status = CartStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = CartStatus.error;
    }
    
    notifyListeners();
  }
  
  Future<void> refreshCart() async {
    if (!_setLoading()) return;
    
    try {
      final cart = await _cartRepository.getCart();
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> addItem(CartItemModel item) async {
    if (!_setLoading()) return;
    
    try {
      final cart = await _cartRepository.addItem(item);
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> updateItemQuantity(String itemId, int quantity) async {
    if (!_setLoading()) return;
    
    try {
      // Lấy item hiện tại
      final currentItem = _cart?.items.firstWhere((item) => item.id == itemId);
      if (currentItem == null) {
        throw Exception('Không tìm thấy sản phẩm trong giỏ hàng');
      }
      
      if (quantity <= 0) {
        // Xóa sản phẩm nếu số lượng <= 0
        await removeItem(itemId);
      } else {
        // Cập nhật số lượng
        final updatedItem = currentItem.copyWith(quantity: quantity);
        final cart = await _cartRepository.updateItem(updatedItem);
        _setLoaded(cart);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> removeItem(String itemId) async {
    if (!_setLoading()) return;
    
    try {
      final cart = await _cartRepository.removeItem(itemId);
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> clearCart() async {
    if (!_setLoading()) return;
    
    try {
      final cart = await _cartRepository.clearCart();
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> applyCoupon(String couponCode) async {
    if (!_setLoading()) return;
    
    try {
      final coupon = await _cartRepository.applyCoupon(couponCode);
      _coupon = coupon;
      
      // Refresh cart sau khi áp dụng coupon
      final cart = await _cartRepository.getCart();
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> removeCoupon() async {
    if (!_setLoading()) return;
    
    try {
      _coupon = null;
      final cart = await _cartRepository.removeCoupon();
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadAvailableCoupons() async {
    if (!_setLoading()) return;
    
    try {
      final coupons = await _cartRepository.getAvailableCoupons();
      _availableCoupons = coupons;
      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> setShippingAddress(String addressId) async {
    if (!_setLoading()) return;
    
    try {
      _selectedAddressId = addressId;
      
      // Tính lại phí vận chuyển
      final shippingFee = await _cartRepository.calculateShipping(addressId);
      
      // Refresh cart để cập nhật tổng
      final cart = await _cartRepository.getCart();
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> syncCartWithServer() async {
    if (!_setLoading()) return;
    
    try {
      final cart = await _cartRepository.syncCart();
      _setLoaded(cart);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Xử lý khi người dùng đăng nhập/đăng xuất
  Future<void> handleAuthChange(bool isLoggedIn) async {
    if (isLoggedIn) {
      // Đồng bộ giỏ hàng giữa local và server khi đăng nhập
      await syncCartWithServer();
    } else {
      // Giữ nguyên giỏ hàng nhưng cập nhật ID (giỏ hàng cho khách)
      if (_cart != null) {
        _cart = _cart!.copyWith(id: 'guest-cart');
        notifyListeners();
      }
    }
  }
} 