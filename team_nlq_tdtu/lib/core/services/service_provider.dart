import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'offline_sync_service.dart';

/// Mô hình Provider cho tất cả các dịch vụ cốt lõi của ứng dụng
class ServiceProvider extends ChangeNotifier {
  late final ConnectivityService _connectivityService;
  late final ApiService _apiService;
  late final CacheService _cacheService;
  late final OfflineSyncService _offlineSyncService;
  
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // Flag trạng thái khởi tạo
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  
  // Getters cho các dịch vụ
  ConnectivityService get connectivity => _connectivityService;
  ApiService get api => _apiService;
  CacheService get cache => _cacheService;
  OfflineSyncService get offlineSync => _offlineSyncService;
  
  /// Constructor
  ServiceProvider() {
    _connectivityService = ConnectivityService();
    _apiService = ApiService();
    _cacheService = CacheService();
    _offlineSyncService = OfflineSyncService();
  }
  
  /// Khởi tạo tất cả các dịch vụ theo đúng thứ tự phụ thuộc
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      // 1. Khởi tạo Connectivity Service trước tiên
      await _connectivityService.checkConnectivity();
      
      // 2. Khởi tạo API Service
      await _apiService.init();
      
      // 3. Khởi tạo Cache Service với dependency cần thiết
      await _cacheService.init(
        connectivityService: _connectivityService,
        apiService: _apiService,
      );
      
      // 4. Khởi tạo Offline Sync Service với các dependency
      await _offlineSyncService.init(
        apiService: _apiService,
        cacheService: _cacheService,
      );
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo các dịch vụ: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }
  
  /// Lấy instance từ context
  static ServiceProvider of(BuildContext context) {
    return Provider.of<ServiceProvider>(context, listen: false);
  }
  
  /// Lấy instance từ context với lắng nghe thay đổi
  static ServiceProvider watch(BuildContext context) {
    return Provider.of<ServiceProvider>(context);
  }
  
  /// Phương thức tạo các Providers
  static List<SingleChildWidget> providers() {
    return [
      ChangeNotifierProvider<ServiceProvider>(
        create: (_) => ServiceProvider(),
      ),
      ProxyProvider<ServiceProvider, ConnectivityService>(
        update: (_, serviceProvider, __) => serviceProvider.connectivity,
      ),
      ProxyProvider<ServiceProvider, ApiService>(
        update: (_, serviceProvider, __) => serviceProvider.api,
      ),
      ProxyProvider<ServiceProvider, CacheService>(
        update: (_, serviceProvider, __) => serviceProvider.cache,
      ),
      ProxyProvider<ServiceProvider, OfflineSyncService>(
        update: (_, serviceProvider, __) => serviceProvider.offlineSync,
      ),
    ];
  }
  
  /// Làm sạch tài nguyên
  @override
  void dispose() {
    _connectivityService.dispose();
    _apiService.dispose();
    _cacheService.dispose();
    _offlineSyncService.dispose();
    super.dispose();
  }
} 