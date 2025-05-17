import 'admin_role_model.dart';
import 'admin_permission.dart';

class AdminModel {
  final int? id;
  final String username;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatar;
  final bool isActive;
  final bool isSuperAdmin;
  final AdminRoleModel? role;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? activityLog;

  AdminModel({
    this.id,
    required this.username,
    required this.email,
    this.phone,
    this.fullName,
    this.avatar,
    this.isActive = true,
    this.isSuperAdmin = false,
    this.role,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.activityLog,
  });

  // Tạo từ JSON
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      isSuperAdmin: json['is_super_admin'] ?? false,
      role: json['role'] != null ? AdminRoleModel.fromJson(json['role']) : null,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      activityLog: json['activity_log'] != null ? List<String>.from(json['activity_log']) : null,
    );
  }

  // Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      if (phone != null) 'phone': phone,
      if (fullName != null) 'full_name': fullName,
      if (avatar != null) 'avatar': avatar,
      'is_active': isActive,
      'is_super_admin': isSuperAdmin,
      if (role != null) 'role': role!.toJson(),
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (activityLog != null) 'activity_log': activityLog,
    };
  }

  // Tạo bản sao với các thuộc tính được cập nhật
  AdminModel copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? avatar,
    bool? isActive,
    bool? isSuperAdmin,
    AdminRoleModel? role,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? activityLog,
  }) {
    return AdminModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  // Kiểm tra xem admin có quyền cụ thể không
  bool hasPermission(AdminPermission permission) {
    if (isSuperAdmin) return true;
    if (role == null) return false;
    return role!.hasPermission(permission);
  }

  @override
  String toString() {
    return 'AdminModel(id: $id, username: $username, email: $email, isActive: $isActive, isSuperAdmin: $isSuperAdmin)';
  }
} 
 