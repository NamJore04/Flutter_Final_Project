import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/models/admin_model.dart';
import '../../domain/models/admin_role_model.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final ApiService _apiService;

  AdminRepositoryImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<Either<Failure, List<AdminModel>>> getAdmins({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    int? roleId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'q': search,
        if (isActive != null) 'is_active': isActive.toString(),
        if (roleId != null) 'role_id': roleId.toString(),
      };

      final response = await _apiService.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'];
      final admins = data.map((json) => AdminModel.fromJson(json)).toList();
      return Right(admins);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể lấy danh sách admin: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminModel>> getAdminById(int id) async {
    try {
      final response = await _apiService.get('/admin/users/$id');
      final admin = AdminModel.fromJson(response.data);
      return Right(admin);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể lấy thông tin admin: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminModel>> createAdmin(AdminModel admin, String password) async {
    try {
      final data = {
        ...admin.toJson(),
        'password': password,
      };
      
      final response = await _apiService.post(
        '/admin/users',
        data: data,
      );
      
      final createdAdmin = AdminModel.fromJson(response.data);
      return Right(createdAdmin);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể tạo người dùng admin: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminModel>> updateAdmin(AdminModel admin) async {
    try {
      if (admin.id == null) {
        return Left(GeneralFailure(message: 'ID người dùng không được để trống'));
      }
      
      final response = await _apiService.put(
        '/admin/users/${admin.id}',
        data: admin.toJson(),
      );
      
      final updatedAdmin = AdminModel.fromJson(response.data);
      return Right(updatedAdmin);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể cập nhật người dùng admin: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAdmin(int id) async {
    try {
      await _apiService.delete('/admin/users/$id');
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể xóa người dùng admin: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminModel>> toggleAdminStatus(int id, bool isActive) async {
    try {
      final response = await _apiService.patch(
        '/admin/users/$id/status',
        data: {'is_active': isActive},
      );
      
      final updatedAdmin = AdminModel.fromJson(response.data);
      return Right(updatedAdmin);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể cập nhật trạng thái admin: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetAdminPassword(int id, String newPassword) async {
    try {
      await _apiService.post(
        '/admin/users/$id/reset-password',
        data: {'password': newPassword},
      );
      
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể đặt lại mật khẩu: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminRoleModel>>> getRoles({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'q': search,
      };

      final response = await _apiService.get(
        '/admin/roles',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'];
      final roles = data.map((json) => AdminRoleModel.fromJson(json)).toList();
      return Right(roles);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể lấy danh sách vai trò: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminRoleModel>> getRoleById(int id) async {
    try {
      final response = await _apiService.get('/admin/roles/$id');
      final role = AdminRoleModel.fromJson(response.data);
      return Right(role);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể lấy thông tin vai trò: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminRoleModel>> createRole(AdminRoleModel role) async {
    try {
      final response = await _apiService.post(
        '/admin/roles',
        data: role.toJson(),
      );
      
      final createdRole = AdminRoleModel.fromJson(response.data);
      return Right(createdRole);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể tạo vai trò admin: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminRoleModel>> updateRole(AdminRoleModel role) async {
    try {
      if (role.id == null) {
        return Left(GeneralFailure(message: 'ID vai trò không được để trống'));
      }
      
      final response = await _apiService.put(
        '/admin/roles/${role.id}',
        data: role.toJson(),
      );
      
      final updatedRole = AdminRoleModel.fromJson(response.data);
      return Right(updatedRole);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể cập nhật vai trò admin: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRole(int id) async {
    try {
      await _apiService.delete('/admin/roles/$id');
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể xóa vai trò admin: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAdminActivityLog(int adminId, {
    int page = 1,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiService.get(
        '/admin/users/$adminId/activity-log',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'];
      final logs = data.map((item) => item.toString()).toList();
      return Right(logs);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Lỗi kết nối đến máy chủ'));
    } catch (e) {
      return Left(GeneralFailure(message: 'Không thể lấy nhật ký hoạt động: $e'));
    }
  }
} 