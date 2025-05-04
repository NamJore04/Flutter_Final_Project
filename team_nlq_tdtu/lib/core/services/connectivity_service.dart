import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';

/// Enum cho các trạng thái kết nối
enum ConnectivityStatus {
  connected,    // Đã kết nối mạng (WiFi, Mobile, Ethernet)
  disconnected, // Mất kết nối mạng
  unknown,      // Trạng thái kết nối chưa xác định
}

/// Service quản lý trạng thái kết nối mạng cho ứng dụng
class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  bool _isInitialized = false;
  
  /// Loại kết nối hiện tại
  ConnectivityResult _connectionType = ConnectivityResult.none;
  
  /// Đếm số lần mất kết nối
  int _disconnectionCount = 0;
  
  /// Thời gian mất kết nối cuối cùng
  DateTime? _lastDisconnectedTime;
  
  /// Stream cho trạng thái kết nối
  final BehaviorSubject<ConnectivityStatus> _connectivitySubject = 
      BehaviorSubject<ConnectivityStatus>.seeded(ConnectivityStatus.unknown);
  
  /// Stream lắng nghe trạng thái kết nối
  Stream<ConnectivityStatus> get connectivityStream => _connectivitySubject.stream;

  /// Constructor
  ConnectivityService() {
    _initialize();
  }

  /// Khởi tạo service và lắng nghe sự thay đổi kết nối
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      // Kiểm tra kết nối hiện tại
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      _updateStatus(result);
      
      // Lắng nghe sự thay đổi kết nối
      _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Lỗi khi khởi tạo ConnectivityService: $e');
      _status = ConnectivityStatus.unknown;
      _connectivitySubject.add(_status);
      notifyListeners();
    }
  }

  /// Cập nhật trạng thái kết nối và thông báo cho người nghe
  void _updateStatus(ConnectivityResult result) {
    _connectionType = result;
    
    ConnectivityStatus newStatus;
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        newStatus = ConnectivityStatus.connected;
        break;
      case ConnectivityResult.none:
        newStatus = ConnectivityStatus.disconnected;
        _disconnectionCount++;
        _lastDisconnectedTime = DateTime.now();
        break;
      default:
        newStatus = ConnectivityStatus.unknown;
        break;
    }
    
    if (_status != newStatus) {
      _status = newStatus;
      _connectivitySubject.add(_status);
      notifyListeners();
    }
  }

  /// Getter cho trạng thái kết nối hiện tại
  ConnectivityStatus get status => _status;
  
  /// Getter cho loại kết nối hiện tại
  ConnectivityResult get connectionType => _connectionType;
  
  /// Kiểm tra trạng thái kết nối hiện tại
  bool get isConnected => _status == ConnectivityStatus.connected;
  bool get isDisconnected => _status == ConnectivityStatus.disconnected;
  
  /// Lấy số lần mất kết nối
  int get disconnectionCount => _disconnectionCount;
  
  /// Lấy thời gian mất kết nối cuối cùng
  DateTime? get lastDisconnectedTime => _lastDisconnectedTime;
  
  /// Kiểm tra xem kết nối có phải là WiFi không
  bool get isWifi => _connectionType == ConnectivityResult.wifi;
  
  /// Kiểm tra xem kết nối có phải là mạng di động không
  bool get isMobile => _connectionType == ConnectivityResult.mobile;

  /// Phương thức kiểm tra kết nối thủ công
  Future<ConnectivityStatus> checkConnectivity() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return _status;
  }
  
  /// Thông báo mỗi khi kết nối thay đổi từ offline sang online
  Stream<bool> get onConnectionRestored => 
      connectivityStream
          .distinct()
          .pairwise()
          .where((pair) => 
              pair.first == ConnectivityStatus.disconnected && 
              pair.last == ConnectivityStatus.connected)
          .map((_) => true);
  
  /// Thông báo mỗi khi kết nối bị mất
  Stream<bool> get onConnectionLost => 
      connectivityStream
          .distinct()
          .pairwise()
          .where((pair) => 
              pair.first == ConnectivityStatus.connected && 
              pair.last == ConnectivityStatus.disconnected)
          .map((_) => true);

  /// Hủy đăng ký lắng nghe khi service bị hủy
  @override
  void dispose() {
    _subscription?.cancel();
    _connectivitySubject.close();
    super.dispose();
  }
} 