enum AdminPermission {
  dashboard,
  manageProducts,
  manageCategories,
  manageUsers,
  manageOrders,
  manageCoupons,
  manageCustomerSupport,
  manageSettings,
}

extension AdminPermissionExtension on AdminPermission {
  String get displayName {
    switch (this) {
      case AdminPermission.dashboard:
        return 'Dashboard';
      case AdminPermission.manageProducts:
        return 'Quản lý sản phẩm';
      case AdminPermission.manageCategories:
        return 'Quản lý danh mục';
      case AdminPermission.manageUsers:
        return 'Quản lý người dùng';
      case AdminPermission.manageOrders:
        return 'Quản lý đơn hàng';
      case AdminPermission.manageCoupons:
        return 'Quản lý mã giảm giá';
      case AdminPermission.manageCustomerSupport:
        return 'Hỗ trợ khách hàng';
      case AdminPermission.manageSettings:
        return 'Cài đặt hệ thống';
    }
  }

  String get description {
    switch (this) {
      case AdminPermission.dashboard:
        return 'Xem tổng quan và báo cáo của hệ thống';
      case AdminPermission.manageProducts:
        return 'Thêm, sửa, xóa và quản lý sản phẩm';
      case AdminPermission.manageCategories:
        return 'Thêm, sửa, xóa và quản lý danh mục sản phẩm';
      case AdminPermission.manageUsers:
        return 'Quản lý tài khoản người dùng và phân quyền';
      case AdminPermission.manageOrders:
        return 'Xem và xử lý đơn hàng của khách';
      case AdminPermission.manageCoupons:
        return 'Tạo và quản lý mã giảm giá, khuyến mãi';
      case AdminPermission.manageCustomerSupport:
        return 'Trả lời và hỗ trợ khách hàng qua chat';
      case AdminPermission.manageSettings:
        return 'Thiết lập và cấu hình hệ thống';
    }
  }

  String get icon {
    switch (this) {
      case AdminPermission.dashboard:
        return 'dashboard';
      case AdminPermission.manageProducts:
        return 'inventory';
      case AdminPermission.manageCategories:
        return 'category';
      case AdminPermission.manageUsers:
        return 'people';
      case AdminPermission.manageOrders:
        return 'shopping_cart';
      case AdminPermission.manageCoupons:
        return 'local_offer';
      case AdminPermission.manageCustomerSupport:
        return 'support_agent';
      case AdminPermission.manageSettings:
        return 'settings';
    }
  }
} 