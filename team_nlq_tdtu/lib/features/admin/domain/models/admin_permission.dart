enum AdminPermission {
  // Quyền hạn quản lý người dùng
  viewUsers,
  createUsers,
  editUsers,
  deleteUsers,
  
  // Quyền hạn quản lý sản phẩm
  viewProducts,
  createProducts,
  editProducts,
  deleteProducts,
  
  // Quyền hạn quản lý đơn hàng
  viewOrders,
  updateOrders,
  cancelOrders,
  
  // Quyền hạn quản lý danh mục
  viewCategories,
  createCategories,
  editCategories,
  deleteCategories,
  
  // Quyền hạn quản lý đánh giá
  viewReviews,
  approveReviews,
  deleteReviews,
  
  // Quyền hạn quản lý khuyến mãi
  viewPromotions,
  createPromotions,
  editPromotions,
  deletePromotions,
  
  // Quyền hạn quản lý vai trò admin
  viewAdmins,
  createAdmins,
  editAdmins,
  deleteAdmins,
  
  // Quyền hạn quản lý vai trò
  viewRoles,
  createRoles,
  editRoles,
  deleteRoles,
  
  // Quyền hạn báo cáo và phân tích
  viewReports,
  exportReports,
  
  // Quyền hạn cấu hình hệ thống
  viewSettings,
  updateSettings
}

// Extension để lấy tên hiển thị cho mỗi quyền hạn
extension AdminPermissionExtension on AdminPermission {
  String get displayName {
    switch (this) {
      // Quyền hạn quản lý người dùng
      case AdminPermission.viewUsers:
        return 'Xem người dùng';
      case AdminPermission.createUsers:
        return 'Tạo người dùng';
      case AdminPermission.editUsers:
        return 'Chỉnh sửa người dùng';
      case AdminPermission.deleteUsers:
        return 'Xóa người dùng';
      
      // Quyền hạn quản lý sản phẩm
      case AdminPermission.viewProducts:
        return 'Xem sản phẩm';
      case AdminPermission.createProducts:
        return 'Tạo sản phẩm';
      case AdminPermission.editProducts:
        return 'Chỉnh sửa sản phẩm';
      case AdminPermission.deleteProducts:
        return 'Xóa sản phẩm';
      
      // Quyền hạn quản lý đơn hàng
      case AdminPermission.viewOrders:
        return 'Xem đơn hàng';
      case AdminPermission.updateOrders:
        return 'Cập nhật đơn hàng';
      case AdminPermission.cancelOrders:
        return 'Hủy đơn hàng';
      
      // Quyền hạn quản lý danh mục
      case AdminPermission.viewCategories:
        return 'Xem danh mục';
      case AdminPermission.createCategories:
        return 'Tạo danh mục';
      case AdminPermission.editCategories:
        return 'Chỉnh sửa danh mục';
      case AdminPermission.deleteCategories:
        return 'Xóa danh mục';
      
      // Quyền hạn quản lý đánh giá
      case AdminPermission.viewReviews:
        return 'Xem đánh giá';
      case AdminPermission.approveReviews:
        return 'Duyệt đánh giá';
      case AdminPermission.deleteReviews:
        return 'Xóa đánh giá';
      
      // Quyền hạn quản lý khuyến mãi
      case AdminPermission.viewPromotions:
        return 'Xem khuyến mãi';
      case AdminPermission.createPromotions:
        return 'Tạo khuyến mãi';
      case AdminPermission.editPromotions:
        return 'Chỉnh sửa khuyến mãi';
      case AdminPermission.deletePromotions:
        return 'Xóa khuyến mãi';
      
      // Quyền hạn quản lý admin
      case AdminPermission.viewAdmins:
        return 'Xem quản trị viên';
      case AdminPermission.createAdmins:
        return 'Tạo quản trị viên';
      case AdminPermission.editAdmins:
        return 'Chỉnh sửa quản trị viên';
      case AdminPermission.deleteAdmins:
        return 'Xóa quản trị viên';
      
      // Quyền hạn quản lý vai trò
      case AdminPermission.viewRoles:
        return 'Xem vai trò';
      case AdminPermission.createRoles:
        return 'Tạo vai trò';
      case AdminPermission.editRoles:
        return 'Chỉnh sửa vai trò';
      case AdminPermission.deleteRoles:
        return 'Xóa vai trò';
      
      // Quyền hạn báo cáo và phân tích
      case AdminPermission.viewReports:
        return 'Xem báo cáo';
      case AdminPermission.exportReports:
        return 'Xuất báo cáo';
      
      // Quyền hạn cấu hình hệ thống
      case AdminPermission.viewSettings:
        return 'Xem cài đặt';
      case AdminPermission.updateSettings:
        return 'Cập nhật cài đặt';
    }
  }

  String get code {
    return toString().split('.').last;
  }

  // Nhóm quyền hạn
  String get group {
    switch (this) {
      case AdminPermission.viewUsers:
      case AdminPermission.createUsers:
      case AdminPermission.editUsers:
      case AdminPermission.deleteUsers:
        return 'Quản lý người dùng';
      
      case AdminPermission.viewProducts:
      case AdminPermission.createProducts:
      case AdminPermission.editProducts:
      case AdminPermission.deleteProducts:
        return 'Quản lý sản phẩm';
      
      case AdminPermission.viewOrders:
      case AdminPermission.updateOrders:
      case AdminPermission.cancelOrders:
        return 'Quản lý đơn hàng';
      
      case AdminPermission.viewCategories:
      case AdminPermission.createCategories:
      case AdminPermission.editCategories:
      case AdminPermission.deleteCategories:
        return 'Quản lý danh mục';
      
      case AdminPermission.viewReviews:
      case AdminPermission.approveReviews:
      case AdminPermission.deleteReviews:
        return 'Quản lý đánh giá';
      
      case AdminPermission.viewPromotions:
      case AdminPermission.createPromotions:
      case AdminPermission.editPromotions:
      case AdminPermission.deletePromotions:
        return 'Quản lý khuyến mãi';
      
      case AdminPermission.viewAdmins:
      case AdminPermission.createAdmins:
      case AdminPermission.editAdmins:
      case AdminPermission.deleteAdmins:
        return 'Quản lý quản trị viên';
      
      case AdminPermission.viewRoles:
      case AdminPermission.createRoles:
      case AdminPermission.editRoles:
      case AdminPermission.deleteRoles:
        return 'Quản lý vai trò';
      
      case AdminPermission.viewReports:
      case AdminPermission.exportReports:
        return 'Báo cáo và phân tích';
      
      case AdminPermission.viewSettings:
      case AdminPermission.updateSettings:
        return 'Cấu hình hệ thống';
    }
  }
}

// Lấy tất cả quyền hạn theo nhóm
Map<String, List<AdminPermission>> getAllPermissionsByGroup() {
  final map = <String, List<AdminPermission>>{};
  
  for (final permission in AdminPermission.values) {
    final group = permission.group;
    if (!map.containsKey(group)) {
      map[group] = [];
    }
    map[group]!.add(permission);
  }
  
  return map;
} 