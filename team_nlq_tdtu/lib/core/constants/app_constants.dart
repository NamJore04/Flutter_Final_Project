class AppConstants {
  static const String appName = 'Team NLQ TDTU';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://api.example.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/categories';
  static const String authEndpoint = '/auth';
  static const String ordersEndpoint = '/orders';
  static const String usersEndpoint = '/users';
  static const String couponsEndpoint = '/coupons';
  
  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String themeModeKey = 'theme_mode';
  
  // Categories
  static const String promotionCategory = 'Sản phẩm khuyến mại';
  static const String newProductsCategory = 'Sản phẩm mới';
  static const String bestSellerCategory = 'Bán chạy';
  static const String laptopCategory = 'Laptop';
  static const String monitorCategory = 'Màn hình';
  static const String hardDriveCategory = 'Ổ cứng';
  static const String processorCategory = 'CPU';
  static const String graphicsCardCategory = 'Card đồ họa';
  
  // Pagination
  static const int itemsPerPage = 10;
  
  // Order Status
  static const String statusProcessing = 'Đang xử lý';
  static const String statusConfirmed = 'Đã xác nhận';
  static const String statusShipping = 'Đang vận chuyển';
  static const String statusDelivered = 'Đã giao hàng';
  
  // Loyalty Points
  static const double loyaltyPointRate = 0.1; // 10% of order value
  
  // Coupon
  static const int couponCodeLength = 5;
  static const int maxCouponUses = 10;
} 