import '../models/admin_role_model.dart';

/// Repository định nghĩa các hoạt động liên quan đến quản lý vai trò admin
abstract class AdminRoleRepository {
  /// Lấy danh sách tất cả vai trò admin
  Future<List<AdminRoleModel>> getAdminRoles();
  
  /// Lấy thông tin vai trò admin theo ID
  Future<AdminRoleModel?> getAdminRoleById(int id);
  
  /// Tạo vai trò admin mới
  Future<AdminRoleModel> createAdminRole({
    required String name,
    required String description,
    required List<AdminPermission> permissions,
  });
  
  /// Cập nhật thông tin vai trò admin
  Future<AdminRoleModel> updateAdminRole({
    required int id,
    String? name,
    String? description,
    List<AdminPermission>? permissions,
  });
  
  /// Xóa vai trò admin
  Future<bool> deleteAdminRole(int id);
  
  /// Kiểm tra xem vai trò có đang được sử dụng bởi bất kỳ người dùng admin nào không
  Future<bool> isRoleInUse(int id);
  
  /// Lấy danh sách tất cả quyền hạn có sẵn trong hệ thống
  Future<List<AdminPermission>> getAllPermissions();
  
  /// Lấy danh sách vai trò theo quyền hạn cụ thể
  Future<List<AdminRoleModel>> getRolesByPermission(AdminPermission permission);
} 