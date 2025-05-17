/// Enum định nghĩa các quyền hạn có sẵn trong hệ thống
enum AdminPermission {
  // Quản lý người dùng
  viewUsers,
  createUser,
  updateUser,
  deleteUser,

  // Quản lý sản phẩm
  viewProducts,
  createProduct,
  updateProduct,
  deleteProduct,

  // Quản lý danh mục
  viewCategories,
  createCategory,
  updateCategory,
  deleteCategory,

  // Quản lý đơn hàng
  viewOrders,
  updateOrderStatus,
  cancelOrder,

  // Quản lý khuyến mãi
  viewPromotions,
  createPromotion,
  updatePromotion,
  deletePromotion,

  // Quản lý bài đánh giá
  viewReviews,
  approveReview,
  deleteReview,

  // Quản lý báo cáo
  viewReports,

  // Quản lý hệ thống
  manageSettings,
  manageAdmins,
  manageRoles,
}

/// Class mô tả một vai trò Admin trong hệ thống
class AdminRoleModel {
  final int? id;
  final String name;
  final String description;
  final List<AdminPermission> permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int adminCount;

  AdminRoleModel({
    this.id,
    required this.name,
    required this.description,
    required this.permissions,
    this.createdAt,
    this.updatedAt,
    this.adminCount = 0,
  });

  /// Chuyển đổi từ JSON thành đối tượng AdminRoleModel
  factory AdminRoleModel.fromJson(Map<String, dynamic> json) {
    return AdminRoleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => AdminPermission.values.firstWhere(
                  (e) => e.toString() == 'AdminPermission.$p',
                  orElse: () => AdminPermission.viewUsers))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      adminCount: json['admin_count'] ?? 0,
    );
  }

  /// Chuyển đổi đối tượng AdminRoleModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'permissions':
          permissions.map((p) => p.toString().split('.').last).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'admin_count': adminCount,
    };
  }

  /// Tạo bản sao với các giá trị đã được cập nhật
  AdminRoleModel copyWith({
    int? id,
    String? name,
    String? description,
    List<AdminPermission>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? adminCount,
  }) {
    return AdminRoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? List.from(this.permissions),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminCount: adminCount ?? this.adminCount,
    );
  }

  /// Kiểm tra xem vai trò có quyền cụ thể không
  bool hasPermission(AdminPermission permission) {
    return permissions.contains(permission.toString());
  }

  /// Kiểm tra xem vai trò có tất cả các quyền được chỉ định không
  bool hasAllPermissions(List<AdminPermission> requiredPermissions) {
    return requiredPermissions
        .every((permission) => permissions.contains(permission));
  }
}
