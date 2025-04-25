import 'package:flutter/material.dart';
import 'package:team_nlq_tdtu/features/user/domain/models/address_model.dart';

enum UserStatus { initial, loading, success, error }

class UserProvider extends ChangeNotifier {
  UserStatus _status = UserStatus.initial;
  UserModel? _user;
  List<AddressModel> _addresses = [];
  String? _errorMessage;

  // Getters
  UserStatus get status => _status;
  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  List<AddressModel> get addresses => _addresses;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // Initialize user from cache or storage
  Future<void> initialize() async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement loading user from storage/cache
      await Future.delayed(const Duration(seconds: 1));

      _user = UserModel(
        id: '1',
        name: 'Người dùng',
        email: 'user@example.com',
        phoneNumber: '0123456789',
        avatar: null,
      );

      _addresses = [
        const AddressModel(
          id: '1',
          fullName: 'Người dùng',
          phoneNumber: '0123456789',
          addressLine1: '123 Đường Số 1',
          city: 'TP HCM',
          district: 'Quận 1',
          ward: 'Phường Bến Nghé',
          postalCode: '70000',
          isDefault: true,
        ),
      ];

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Get user profile
  Future<void> getUserProfile() async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement API call to get user profile
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _user = UserModel(
        id: '1',
        name: 'Người dùng',
        email: 'user@example.com',
        phoneNumber: '0123456789',
        avatar: null,
      );

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Get user addresses
  Future<void> getUserAddresses() async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement API call to get user addresses
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _addresses = [
        const AddressModel(
          id: '1',
          fullName: 'Người dùng',
          phoneNumber: '0123456789',
          addressLine1: '123 Đường Số 1',
          city: 'TP HCM',
          district: 'Quận 1',
          ward: 'Phường Bến Nghé',
          postalCode: '70000',
          isDefault: true,
        ),
      ];

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement API call to update user profile
      await Future.delayed(const Duration(seconds: 1));

      // Update local user data
      _user = _user?.copyWith(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Add address
  Future<void> addAddress(AddressModel address) async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement API call to add address
      await Future.delayed(const Duration(seconds: 1));

      // Update local addresses
      _addresses.add(address);

      // If address is default, update other addresses
      if (address.isDefault) {
        _addresses = _addresses.map((a) {
          if (a.id != address.id) {
            return a.copyWith(isDefault: false);
          }
          return a;
        }).toList();
      }

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Update address
  Future<void> updateAddress(AddressModel address) async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement API call to update address
      await Future.delayed(const Duration(seconds: 1));

      // Update local addresses
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;

        // If address is default, update other addresses
        if (address.isDefault) {
          _addresses = _addresses.map((a) {
            if (a.id != address.id) {
              return a.copyWith(isDefault: false);
            }
            return a;
          }).toList();
        }
      }

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    _status = UserStatus.loading;
    notifyListeners();

    try {
      // TODO: Implement API call to delete address
      await Future.delayed(const Duration(seconds: 1));

      // Update local addresses
      _addresses.removeWhere((a) => a.id == addressId);

      _status = UserStatus.success;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Logout
  void logout() {
    _user = null;
    _addresses = [];
    _status = UserStatus.initial;
    notifyListeners();
  }
}

// Placeholder for UserModel - Should be created in separate file
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.avatar,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
    );
  }
}
