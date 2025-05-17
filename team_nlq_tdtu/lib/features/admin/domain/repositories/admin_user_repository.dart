import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../models/admin_user_model.dart';

/// Repository định nghĩa các hoạt động liên quan đến quản lý người dùng admin
abstract class AdminUserRepository {
  /// Lấy danh sách tất cả người dùng admin
  Future<List<AdminUserModel>> getAdminUsers();

  /// Lấy thông tin người dùng admin theo ID
  Future<AdminUserModel?> getAdminUserById(int id);

  /// Lấy thông tin người dùng admin theo email
  Future<AdminUserModel?> getAdminUserByEmail(String email);

  /// Tạo người dùng admin mới
  Future<AdminUserModel> createAdminUser({
    required String fullName,
    required String email,
    required String password,
    required int roleId,
    String? phoneNumber,
    String? avatarUrl,
  });

  /// Cập nhật thông tin người dùng admin
  Future<AdminUserModel> updateAdminUser({
    required int id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    int? roleId,
    bool? isActive,
  });

  /// Thay đổi mật khẩu người dùng admin
  Future<bool> changeAdminUserPassword({
    required int id,
    required String currentPassword,
    required String newPassword,
  });

  /// Reset mật khẩu người dùng admin (chỉ dành cho Super Admin)
  Future<bool> resetAdminUserPassword({
    required int id,
    required String newPassword,
  });

  /// Xóa người dùng admin
  Future<bool> deleteAdminUser(int id);

  /// Vô hiệu hóa tài khoản người dùng admin
  Future<bool> deactivateAdminUser(int id);

  /// Kích hoạt tài khoản người dùng admin
  Future<bool> activateAdminUser(int id);

  /// Lấy danh sách người dùng admin theo vai trò
  Future<List<AdminUserModel>> getAdminUsersByRole(int roleId);

  /// Lấy danh sách lịch sử đăng nhập của người dùng admin
  Future<List<Map<String, dynamic>>> getLoginHistory(int userId,
      {int limit = 10});
}
