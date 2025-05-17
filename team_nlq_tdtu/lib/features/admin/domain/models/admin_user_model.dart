import 'admin_role_model.dart';

/// Model đại diện cho người dùng Admin trong hệ thống
class AdminUserModel {
  final int? id;
  final String username;
  final String email;
  final String fullName;
  final String? avatar;
  final int roleId;
  final AdminRoleModel? role;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUserModel({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.avatar,
    required this.roleId,
    this.role,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  /// Tạo đối tượng AdminUserModel từ JSON
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
      roleId: json['role_id'],
      role: json['role'] != null ? AdminRoleModel.fromJson(json['role']) : null,
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Chuyển đổi đối tượng AdminUserModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      if (avatar != null) 'avatar': avatar,
      'role_id': roleId,
      'is_active': isActive,
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Tạo bản sao với các giá trị đã được cập nhật
  AdminUserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? avatar,
    int? roleId,
    AdminRoleModel? role,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      roleId: roleId ?? this.roleId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Kiểm tra xem người dùng admin có quyền cụ thể không
  bool hasPermission(AdminPermission permission) {
    return role?.hasPermission(permission) ?? false;
  }

  /// Tạo đối tượng từ JSON
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: AdminRoleModel.fromJson(json['role'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool,
      lastLogin: DateTime.parse(json['last_login'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'role': role.toJson(),
      'is_active': isActive,
      'last_login': lastLogin.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Kiểm tra xem người dùng có quyền hạn cụ thể hay không
  bool hasPermission(AdminPermission permission) {
    return role.hasPermission(permission);
  }

  /// Kiểm tra xem người dùng có bất kỳ quyền hạn nào trong danh sách hay không
  bool hasAnyPermission(List<AdminPermission> permissionList) {
    return role.hasAnyPermission(permissionList);
  }

  /// Kiểm tra xem người dùng có tất cả quyền hạn trong danh sách hay không
  bool hasAllPermissions(List<AdminPermission> permissionList) {
    return role.hasAllPermissions(permissionList);
  }

  @override
  List<Object?> get props => [id, email, role, isActive];
}
