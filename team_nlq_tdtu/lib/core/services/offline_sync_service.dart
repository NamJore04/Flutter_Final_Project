import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

import 'api_service.dart';
import 'cache_service.dart';

// Enum trạng thái đồng bộ
enum SyncStatus {
  idle,        // Không có quá trình đồng bộ nào
  syncing,     // Đang đồng bộ
  completed,   // Đồng bộ hoàn tất
  failed,      // Đồng bộ thất bại
  offline      // Không có kết nối mạng
}

// Model cho các mục đang chờ đồng bộ
class SyncItem {
  final String id;
  final String endpoint;
  final String method;
  final Map<String, dynamic> data;
  final String entityType;
  final String entityId;
  final int timestamp;
  int retryCount;

  SyncItem({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.data,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'],
      endpoint: json['endpoint'],
      method: json['method'],
      data: jsonDecode(json['data']),
      entityType: json['entityType'],
      entityId: json['entityId'],
      timestamp: json['timestamp'],
      retryCount: json['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endpoint': endpoint,
      'method': method,
      'data': jsonEncode(data),
      'entityType': entityType,
      'entityId': entityId,
      'timestamp': timestamp,
      'retryCount': retryCount,
    };
  }
}

/// Service quản lý đồng bộ hóa dữ liệu offline-online
class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;

  OfflineSyncService._internal();

  late ApiService _apiService;
  late CacheService _cacheService;
  late Box<dynamic> _syncBox;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Stream báo cáo trạng thái đồng bộ
  final BehaviorSubject<SyncStatus> _syncStatusSubject = BehaviorSubject<SyncStatus>.seeded(SyncStatus.idle);
  Stream<SyncStatus> get syncStatus => _syncStatusSubject.stream;
  
  // Stream báo cáo số lượng mục cần đồng bộ
  final BehaviorSubject<int> _pendingCountSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get pendingCount => _pendingCountSubject.stream;
  
  bool _initialized = false;
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  /// Khởi tạo dịch vụ
  Future<void> init({
    required ApiService apiService, 
    required CacheService cacheService
  }) async {
    if (_initialized) return;

    _apiService = apiService;
    _cacheService = cacheService;
    
    // Mở box lưu trữ dữ liệu đồng bộ
    _syncBox = await Hive.openBox('offline_sync');
    
    // Lắng nghe thay đổi kết nối
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    
    // Kiểm tra kết nối ban đầu
    _updateConnectionStatus(await _connectivity.checkConnectivity());
    
    // Thiết lập timer kiểm tra đồng bộ định kỳ
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) => syncPendingData());
    
    // Cập nhật số lượng mục đang chờ
    _updatePendingCount();
    
    _initialized = true;
  }
  
  /// Xử lý thay đổi kết nối
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    _updateConnectionStatus(result);
    
    if (result != ConnectivityResult.none) {
      // Khi có kết nối mạng, thực hiện đồng bộ
      syncPendingData();
    }
  }
  
  /// Cập nhật trạng thái kết nối
  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _syncStatusSubject.add(SyncStatus.offline);
    } else {
      // Chỉ cập nhật nếu đang ở trạng thái offline
      if (_syncStatusSubject.value == SyncStatus.offline) {
        _syncStatusSubject.add(SyncStatus.idle);
      }
    }
  }
  
  /// Cập nhật số lượng mục đang chờ đồng bộ
  void _updatePendingCount() {
    _pendingCountSubject.add(_syncBox.length);
  }
  
  /// Thêm một thao tác vào hàng đợi đồng bộ
  Future<void> addToSyncQueue({
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
    required String entityType,
    required String entityId,
  }) async {
    final syncItem = SyncItem(
      id: '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
      endpoint: endpoint,
      method: method,
      data: data,
      entityType: entityType,
      entityId: entityId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    
    await _syncBox.put(syncItem.id, syncItem.toJson());
    _updatePendingCount();
    
    // Thử đồng bộ ngay nếu có kết nối
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      syncPendingData();
    }
  }
  
  /// Đồng bộ tất cả dữ liệu đang chờ
  Future<void> syncPendingData() async {
    // Kiểm tra nếu đang đồng bộ hoặc không có kết nối
    if (_isSyncing) return;
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _syncStatusSubject.add(SyncStatus.offline);
      return;
    }
    
    _isSyncing = true;
    _syncStatusSubject.add(SyncStatus.syncing);
    
    try {
      final keys = _syncBox.keys.toList();
      if (keys.isEmpty) {
        _syncStatusSubject.add(SyncStatus.completed);
        _isSyncing = false;
        return;
      }
      
      int successCount = 0;
      
      // Sắp xếp các mục theo thời gian
      keys.sort((a, b) {
        final itemA = SyncItem.fromJson(_syncBox.get(a));
        final itemB = SyncItem.fromJson(_syncBox.get(b));
        return itemA.timestamp.compareTo(itemB.timestamp);
      });
      
      for (var key in keys) {
        // Kiểm tra lại kết nối giữa mỗi lần gửi
        if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
          _syncStatusSubject.add(SyncStatus.offline);
          _isSyncing = false;
          return;
        }
        
        final syncItemJson = _syncBox.get(key);
        if (syncItemJson == null) continue;
        
        final syncItem = SyncItem.fromJson(syncItemJson);
        
        try {
          // Thực hiện request API
          await _apiService.request(
            syncItem.endpoint,
            method: syncItem.method,
            data: syncItem.data,
          );
          
          // Xóa khỏi hàng đợi nếu thành công
          await _syncBox.delete(key);
          successCount++;
        } catch (e) {
          // Tăng số lần thử lại
          syncItem.retryCount++;
          
          // Nếu thử lại quá 5 lần, đánh dấu thất bại và xóa
          if (syncItem.retryCount > 5) {
            await _syncBox.delete(key);
            
            // Lưu vào log thất bại
            final failedBox = await Hive.openBox('failed_syncs');
            await failedBox.put(key, {
              ...syncItem.toJson(),
              'error': e.toString(),
              'failedAt': DateTime.now().toIso8601String(),
            });
          } else {
            // Lưu lại với số lần thử mới
            await _syncBox.put(key, syncItem.toJson());
          }
        }
      }
      
      _updatePendingCount();
      
      if (_syncBox.isEmpty) {
        _syncStatusSubject.add(SyncStatus.completed);
      } else {
        if (successCount > 0) {
          // Một phần đã đồng bộ thành công
          _syncStatusSubject.add(SyncStatus.completed);
        } else {
          // Không có mục nào đồng bộ thành công
          _syncStatusSubject.add(SyncStatus.failed);
        }
      }
    } catch (e) {
      _syncStatusSubject.add(SyncStatus.failed);
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Xóa tất cả dữ liệu đồng bộ
  Future<void> clearSyncQueue() async {
    await _syncBox.clear();
    _updatePendingCount();
    _syncStatusSubject.add(SyncStatus.idle);
  }
  
  /// Lấy danh sách các mục đang chờ đồng bộ
  List<SyncItem> getPendingSyncItems() {
    return _syncBox.values
        .map((json) => SyncItem.fromJson(json))
        .toList();
  }
  
  /// Kiểm tra xem một entity cụ thể có đang chờ đồng bộ không
  bool isEntityPendingSync(String entityType, String entityId) {
    final pendingItems = getPendingSyncItems();
    return pendingItems.any((item) => 
        item.entityType == entityType && item.entityId == entityId);
  }
  
  /// Đồng bộ hóa dữ liệu theo entity cụ thể
  Future<bool> syncEntity(String entityType, String entityId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    bool success = true;
    
    // Tìm tất cả các mục đang chờ của entity này
    final keys = _syncBox.keys.where((key) {
      final item = SyncItem.fromJson(_syncBox.get(key));
      return item.entityType == entityType && item.entityId == entityId;
    }).toList();
    
    if (keys.isEmpty) return true;
    
    _syncStatusSubject.add(SyncStatus.syncing);
    
    try {
      for (var key in keys) {
        final syncItem = SyncItem.fromJson(_syncBox.get(key));
        
        try {
          await _apiService.request(
            syncItem.endpoint,
            method: syncItem.method,
            data: syncItem.data,
          );
          
          await _syncBox.delete(key);
        } catch (e) {
          success = false;
          syncItem.retryCount++;
          
          if (syncItem.retryCount > 5) {
            await _syncBox.delete(key);
            final failedBox = await Hive.openBox('failed_syncs');
            await failedBox.put(key, {
              ...syncItem.toJson(),
              'error': e.toString(),
              'failedAt': DateTime.now().toIso8601String(),
            });
          } else {
            await _syncBox.put(key, syncItem.toJson());
          }
        }
      }
      
      _updatePendingCount();
      _syncStatusSubject.add(success ? SyncStatus.completed : SyncStatus.failed);
      return success;
    } catch (e) {
      _syncStatusSubject.add(SyncStatus.failed);
      return false;
    }
  }
  
  /// Hủy đăng ký và giải phóng tài nguyên
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _syncStatusSubject.close();
    _pendingCountSubject.close();
  }
} 