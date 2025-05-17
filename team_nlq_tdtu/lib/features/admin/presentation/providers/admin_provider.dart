import 'package:flutter/foundation.dart';

import '../../domain/models/admin_model.dart';
import '../../domain/models/admin_permission.dart';
import '../../domain/models/admin_role_model.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/enums/loading_status.dart';

enum AdminActionStatus { initial, loading, success, error }

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  // Admin users state
  List<AdminModel> _admins = [];
  bool _isLoadingAdmins = false;
  bool _hasMoreAdmins = true;
  String? _adminErrorMessage;
  int _currentAdminPage = 1;
  String? _adminSearchQuery;
  bool? _adminIsActiveFilter;
  int? _adminRoleIdFilter;
  AdminModel? _selectedAdmin;
  AdminActionStatus _createAdminStatus = AdminActionStatus.initial;
  AdminActionStatus _updateAdminStatus = AdminActionStatus.initial;
  AdminActionStatus _deleteAdminStatus = AdminActionStatus.initial;

  // Admin roles state
  List<AdminRoleModel> _roles = [];
  bool _isLoadingRoles = false;
  bool _hasMoreRoles = true;
  String? _roleErrorMessage;
  int _currentRolePage = 1;
  String? _roleSearchQuery;
  AdminRoleModel? _selectedRole;
  AdminActionStatus _createRoleStatus = AdminActionStatus.initial;
  AdminActionStatus _updateRoleStatus = AdminActionStatus.initial;
  AdminActionStatus _deleteRoleStatus = AdminActionStatus.initial;

  // Activity log state
  List<String> _activityLogs = [];
  bool _isLoadingLogs = false;
  bool _hasMoreLogs = true;
  String? _logErrorMessage;
  int _currentLogPage = 1;

  // Getters
  List<AdminModel> get admins => _admins;
  bool get isLoadingAdmins => _isLoadingAdmins;
  bool get hasMoreAdmins => _hasMoreAdmins;
  String? get adminErrorMessage => _adminErrorMessage;
  AdminModel? get selectedAdmin => _selectedAdmin;
  AdminActionStatus get createAdminStatus => _createAdminStatus;
  AdminActionStatus get updateAdminStatus => _updateAdminStatus;
  AdminActionStatus get deleteAdminStatus => _deleteAdminStatus;

  List<AdminRoleModel> get roles => _roles;
  bool get isLoadingRoles => _isLoadingRoles;
  bool get hasMoreRoles => _hasMoreRoles;
  String? get roleErrorMessage => _roleErrorMessage;
  AdminRoleModel? get selectedRole => _selectedRole;
  AdminActionStatus get createRoleStatus => _createRoleStatus;
  AdminActionStatus get updateRoleStatus => _updateRoleStatus;
  AdminActionStatus get deleteRoleStatus => _deleteRoleStatus;

  List<String> get activityLogs => _activityLogs;
  bool get isLoadingLogs => _isLoadingLogs;
  bool get hasMoreLogs => _hasMoreLogs;
  String? get logErrorMessage => _logErrorMessage;

  // Các thông tin lọc
  String? get adminSearchQuery => _adminSearchQuery;
  bool? get adminIsActiveFilter => _adminIsActiveFilter;
  int? get adminRoleIdFilter => _adminRoleIdFilter;
  String? get roleSearchQuery => _roleSearchQuery;

  // Map nhóm quyền
  Map<String, List<AdminPermission>> get permissionGroups => getAllPermissionsByGroup();

  AdminProvider({required AdminRepository repository}) : _repository = repository;

  // Phương thức quản lý admin
  Future<void> getAdmins({bool refresh = false}) async {
    if (refresh) {
      _currentAdminPage = 1;
      _admins = [];
      _hasMoreAdmins = true;
    }

    if (!_hasMoreAdmins || _isLoadingAdmins) return;

    _isLoadingAdmins = true;
    _adminErrorMessage = null;
    notifyListeners();

    final result = await _repository.getAdmins(
      page: _currentAdminPage,
      limit: 10,
      search: _adminSearchQuery,
      isActive: _adminIsActiveFilter,
      roleId: _adminRoleIdFilter,
    );

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _isLoadingAdmins = false;
        notifyListeners();
      },
      (admins) {
        if (admins.isEmpty) {
          _hasMoreAdmins = false;
        } else {
          _admins.addAll(admins);
          _currentAdminPage++;
        }
        _isLoadingAdmins = false;
        notifyListeners();
      },
    );
  }

  Future<void> getAdminById(int id) async {
    _isLoadingAdmins = true;
    _adminErrorMessage = null;
    notifyListeners();

    final result = await _repository.getAdminById(id);

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _isLoadingAdmins = false;
        notifyListeners();
      },
      (admin) {
        _selectedAdmin = admin;
        _isLoadingAdmins = false;
        notifyListeners();
      },
    );
  }

  void setAdminFilters({String? search, bool? isActive, int? roleId}) {
    _adminSearchQuery = search;
    _adminIsActiveFilter = isActive;
    _adminRoleIdFilter = roleId;
    notifyListeners();
  }

  void clearAdminFilters() {
    _adminSearchQuery = null;
    _adminIsActiveFilter = null;
    _adminRoleIdFilter = null;
    notifyListeners();
  }

  Future<void> createAdmin(AdminModel admin, String password) async {
    _createAdminStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.createAdmin(admin, password);

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _createAdminStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (createdAdmin) {
        _admins.insert(0, createdAdmin);
        _createAdminStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  Future<void> updateAdmin(AdminModel admin) async {
    _updateAdminStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.updateAdmin(admin);

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _updateAdminStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (updatedAdmin) {
        final index = _admins.indexWhere((a) => a.id == updatedAdmin.id);
        if (index != -1) {
          _admins[index] = updatedAdmin;
        }
        
        if (_selectedAdmin?.id == updatedAdmin.id) {
          _selectedAdmin = updatedAdmin;
        }
        
        _updateAdminStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  Future<void> deleteAdmin(int id) async {
    _deleteAdminStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.deleteAdmin(id);

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _deleteAdminStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (success) {
        _admins.removeWhere((admin) => admin.id == id);
        if (_selectedAdmin?.id == id) {
          _selectedAdmin = null;
        }
        _deleteAdminStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  Future<void> toggleAdminStatus(int id, bool isActive) async {
    _updateAdminStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.toggleAdminStatus(id, isActive);

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _updateAdminStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (updatedAdmin) {
        final index = _admins.indexWhere((a) => a.id == updatedAdmin.id);
        if (index != -1) {
          _admins[index] = updatedAdmin;
        }
        
        if (_selectedAdmin?.id == updatedAdmin.id) {
          _selectedAdmin = updatedAdmin;
        }
        
        _updateAdminStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  Future<void> resetAdminPassword(int id, String newPassword) async {
    _updateAdminStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.resetAdminPassword(id, newPassword);

    result.fold(
      (failure) {
        _adminErrorMessage = failure.message;
        _updateAdminStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (success) {
        _updateAdminStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  // Phương thức quản lý vai trò
  Future<void> getRoles({bool refresh = false}) async {
    if (refresh) {
      _currentRolePage = 1;
      _roles = [];
      _hasMoreRoles = true;
    }

    if (!_hasMoreRoles || _isLoadingRoles) return;

    _isLoadingRoles = true;
    _roleErrorMessage = null;
    notifyListeners();

    final result = await _repository.getRoles(
      page: _currentRolePage,
      limit: 10,
      search: _roleSearchQuery,
    );

    result.fold(
      (failure) {
        _roleErrorMessage = failure.message;
        _isLoadingRoles = false;
        notifyListeners();
      },
      (roles) {
        if (roles.isEmpty) {
          _hasMoreRoles = false;
        } else {
          _roles.addAll(roles);
          _currentRolePage++;
        }
        _isLoadingRoles = false;
        notifyListeners();
      },
    );
  }

  Future<void> getRoleById(int id) async {
    _isLoadingRoles = true;
    _roleErrorMessage = null;
    notifyListeners();

    final result = await _repository.getRoleById(id);

    result.fold(
      (failure) {
        _roleErrorMessage = failure.message;
        _isLoadingRoles = false;
        notifyListeners();
      },
      (role) {
        _selectedRole = role;
        _isLoadingRoles = false;
        notifyListeners();
      },
    );
  }

  void setRoleFilters({String? search}) {
    _roleSearchQuery = search;
    notifyListeners();
  }

  void clearRoleFilters() {
    _roleSearchQuery = null;
    notifyListeners();
  }

  Future<void> createRole(AdminRoleModel role) async {
    _createRoleStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.createRole(role);

    result.fold(
      (failure) {
        _roleErrorMessage = failure.message;
        _createRoleStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (createdRole) {
        _roles.insert(0, createdRole);
        _createRoleStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  Future<void> updateRole(AdminRoleModel role) async {
    _updateRoleStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.updateRole(role);

    result.fold(
      (failure) {
        _roleErrorMessage = failure.message;
        _updateRoleStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (updatedRole) {
        final index = _roles.indexWhere((r) => r.id == updatedRole.id);
        if (index != -1) {
          _roles[index] = updatedRole;
        }
        
        if (_selectedRole?.id == updatedRole.id) {
          _selectedRole = updatedRole;
        }
        
        _updateRoleStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  Future<void> deleteRole(int id) async {
    _deleteRoleStatus = AdminActionStatus.loading;
    notifyListeners();

    final result = await _repository.deleteRole(id);

    result.fold(
      (failure) {
        _roleErrorMessage = failure.message;
        _deleteRoleStatus = AdminActionStatus.error;
        notifyListeners();
      },
      (success) {
        _roles.removeWhere((role) => role.id == id);
        if (_selectedRole?.id == id) {
          _selectedRole = null;
        }
        _deleteRoleStatus = AdminActionStatus.success;
        notifyListeners();
      },
    );
  }

  // Phương thức lấy nhật ký hoạt động
  Future<void> getActivityLogs(int adminId, {bool refresh = false}) async {
    if (refresh) {
      _currentLogPage = 1;
      _activityLogs = [];
      _hasMoreLogs = true;
    }

    if (!_hasMoreLogs || _isLoadingLogs) return;

    _isLoadingLogs = true;
    _logErrorMessage = null;
    notifyListeners();

    final result = await _repository.getAdminActivityLog(
      adminId,
      page: _currentLogPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        _logErrorMessage = failure.message;
        _isLoadingLogs = false;
        notifyListeners();
      },
      (logs) {
        if (logs.isEmpty) {
          _hasMoreLogs = false;
        } else {
          _activityLogs.addAll(logs);
          _currentLogPage++;
        }
        _isLoadingLogs = false;
        notifyListeners();
      },
    );
  }

  // Reset các trạng thái
  void resetActionStatus() {
    _createAdminStatus = AdminActionStatus.initial;
    _updateAdminStatus = AdminActionStatus.initial;
    _deleteAdminStatus = AdminActionStatus.initial;
    _createRoleStatus = AdminActionStatus.initial;
    _updateRoleStatus = AdminActionStatus.initial;
    _deleteRoleStatus = AdminActionStatus.initial;
    _adminErrorMessage = null;
    _roleErrorMessage = null;
    _logErrorMessage = null;
    notifyListeners();
  }
} 