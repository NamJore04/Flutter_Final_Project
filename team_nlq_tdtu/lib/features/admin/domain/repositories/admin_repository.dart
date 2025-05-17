import 'package:dartz/dartz.dart';

import '../models/admin_user_model.dart';
import '../models/admin_role_model.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/error/failures.dart';

/// Repository xử lý các hoạt động liên quan đến Admin trong hệ thống
abstract class AdminRepository {
  /// Lấy danh sách admin
  Future<Either<Failure, List<AdminUserModel>>> getAdmins({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    int? roleId,
  });

  /// Lấy chi tiết admin
  Future<Either<Failure, AdminUserModel>> getAdminById(int id);

  /// Tạo admin mới
  Future<Either<Failure, AdminUserModel>> createAdmin(
      AdminUserModel admin, String password);

  /// Cập nhật thông tin admin
  Future<Either<Failure, AdminUserModel>> updateAdmin(AdminUserModel admin);

  /// Xóa admin
  Future<Either<Failure, bool>> deleteAdmin(int id);

  /// Thay đổi trạng thái hoạt động của admin
  Future<Either<Failure, AdminUserModel>> toggleAdminStatus(
      int id, bool isActive);

  /// Đặt lại mật khẩu admin
  Future<Either<Failure, bool>> resetAdminPassword(int id, String newPassword);

  /// Lấy danh sách vai trò
  Future<Either<Failure, List<AdminRoleModel>>> getRoles({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// Lấy chi tiết vai trò
  Future<Either<Failure, AdminRoleModel>> getRoleById(int id);

  /// Tạo vai trò mới
  Future<Either<Failure, AdminRoleModel>> createRole(AdminRoleModel role);

  /// Cập nhật vai trò
  Future<Either<Failure, AdminRoleModel>> updateRole(AdminRoleModel role);

  /// Xóa vai trò
  Future<Either<Failure, bool>> deleteRole(int id);

  /// Lấy nhật ký hoạt động của admin
  Future<Either<Failure, List<String>>> getAdminActivityLog(
    int adminId, {
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  });
}
