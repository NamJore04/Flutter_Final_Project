import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

import 'api_service.dart';
import 'connectivity_service.dart';

/// Chiến lược cache: cách xử lý dữ liệu trong cache
enum CacheStrategy {
  /// Luôn sử dụng cache, chỉ tải dữ liệu mới khi không có cache
  cacheFirst,

  /// Luôn tải dữ liệu mới, sử dụng cache khi offline
  networkFirst,

  /// Tải dữ liệu mới và cập nhật cache, nhưng hiển thị dữ liệu cache trước
  cacheThenNetwork,

  /// Sử dụng cache nếu còn mới, nếu không thì tải dữ liệu mới
  cacheIfRecent,

  /// Không sử dụng cache, luôn tải dữ liệu mới
  noCache,
}

/// Đối tượng cấu hình cache
class CacheConfig {
  /// Thời gian cache hết hạn (mặc định 1 giờ)
  final Duration expiration;

  /// Chiến lược cache
  final CacheStrategy strategy;

  /// Mã hóa dữ liệu
  final bool encrypt;

  /// Nén dữ liệu
  final bool compress;

  const CacheConfig({
    this.expiration = const Duration(hours: 1),
    this.strategy = CacheStrategy.cacheFirst,
    this.encrypt = false,
    this.compress = false,
  });
}

/// Mục dữ liệu trong cache
class CacheItem<T> {
  /// Dữ liệu được lưu trữ
  final T data;

  /// Thời gian lưu trữ
  final DateTime timestamp;

  /// Thời gian hết hạn
  final DateTime? expiration;

  /// Key để truy xuất dữ liệu
  final String key;

  CacheItem({
    required this.data,
    required this.timestamp,
    required this.key,
    this.expiration,
  });

  /// Kiểm tra xem cache đã hết hạn chưa
  bool isExpired() {
    if (expiration == null) return false;
    return DateTime.now().isAfter(expiration!);
  }

  /// Tạo từ JSON
  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      key: json['key'],
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'])
          : null,
    );
  }

  /// Chuyển thành JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'key': key,
      'expiration': expiration?.toIso8601String(),
    };
  }
}

/// Dịch vụ quản lý cache cho ứng dụng
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  CacheService._internal();

  late Box<dynamic> _cacheBox;
  late ConnectivityService _connectivityService;
  ApiService? _apiService;

  /// Kích thước tối đa của cache (mặc định 100MB)
  int _maxCacheSize = 100 * 1024 * 1024; // 100MB

  /// Thời gian mặc định cho cache hết hạn
  Duration _defaultExpiration = const Duration(hours: 1);

  /// Flag xác định có đang online hay không
  bool _isOnline = true;

  /// Đường dẫn thư mục cache
  String? _cacheDirPath;

  /// Stream báo cáo thay đổi kích thước cache
  final BehaviorSubject<int> _cacheSizeSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get cacheSizeStream => _cacheSizeSubject.stream;

  /// Liệu service đã được khởi tạo chưa
  bool _initialized = false;

  /// Timer để dọn dẹp cache
  Timer? _cleanupTimer;

  /// Khởi tạo dịch vụ cache
  Future<void> init({
    required ConnectivityService connectivityService,
    ApiService? apiService,
    int? maxCacheSize,
    Duration? defaultExpiration,
  }) async {
    if (_initialized) return;

    _connectivityService = connectivityService;
    _apiService = apiService;

    if (maxCacheSize != null) {
      _maxCacheSize = maxCacheSize;
    }

    if (defaultExpiration != null) {
      _defaultExpiration = defaultExpiration;
    }

    // Lắng nghe thay đổi kết nối
    _isOnline = _connectivityService.isConnected;
    _connectivityService.addListener(_onConnectivityChanged);

    // Khởi tạo Hive và mở box cache
    await _setupHive();

    // Thiết lập thư mục cache
    await _setupCacheDirectory();

    // Thiết lập timer dọn dẹp cache định kỳ
    _cleanupTimer = Timer.periodic(const Duration(hours: 12), (_) {
      _cleanupExpiredCache();
    });

    // Cập nhật kích thước cache ban đầu
    await _updateCacheSize();

    _initialized = true;
  }

  /// Thiết lập Hive để lưu trữ cache
  Future<void> _setupHive() async {
    if (!Hive.isBoxOpen('app_cache')) {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
    }

    _cacheBox = await Hive.openBox('app_cache');
  }

  /// Thiết lập thư mục cache
  Future<void> _setupCacheDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    final appCacheDir = Directory('${cacheDir.path}/app_cache');

    if (!await appCacheDir.exists()) {
      await appCacheDir.create(recursive: true);
    }

    _cacheDirPath = appCacheDir.path;
  }

  /// Xử lý thay đổi trạng thái kết nối
  void _onConnectivityChanged() {
    _isOnline = _connectivityService.isConnected;
  }

  /// Tạo khóa cache từ URL và tham số
  String _createCacheKey(String url, {Map<String, dynamic>? params}) {
    String key = url;

    if (params != null && params.isNotEmpty) {
      key += '_${jsonEncode(params)}';
    }

    // Tạo mã băm MD5 từ key để có độ dài cố định
    return md5.convert(utf8.encode(key)).toString();
  }

  /// Lưu dữ liệu vào cache
  Future<void> saveToCache<T>(
    String key,
    T data, {
    Duration? expiration,
    bool encrypt = false,
    bool compress = false,
  }) async {
    if (!_initialized) {
      debugPrint('Cache service chưa được khởi tạo');
      return;
    }

    final now = DateTime.now();
    final expiryTime =
        expiration != null ? now.add(expiration) : now.add(_defaultExpiration);

    final cacheItem = CacheItem<T>(
      data: data,
      timestamp: now,
      key: key,
      expiration: expiryTime,
    );

    // Chuẩn bị dữ liệu để lưu trữ
    String serializedData = jsonEncode(cacheItem.toJson());

    // Nén dữ liệu nếu cần
    if (compress) {
      final compressedData = gzip.encode(utf8.encode(serializedData));
      serializedData = base64Encode(compressedData);
    }

    // Mã hóa dữ liệu nếu cần (ở đây chỉ là giả lập bằng Base64)
    if (encrypt) {
      serializedData = base64Encode(utf8.encode(serializedData));
    }

    // Lưu vào Hive
    await _cacheBox.put(key, serializedData);

    // Cập nhật kích thước cache
    await _updateCacheSize();

    // Dọn dẹp cache nếu vượt quá giới hạn
    if (await getCacheSize() > _maxCacheSize) {
      await _cleanupOldestCache();
    }
  }

  /// Lấy dữ liệu từ cache
  Future<T?> getFromCache<T>(
    String key, {
    bool decrypt = false,
    bool decompress = false,
  }) async {
    if (!_initialized) {
      debugPrint('Cache service chưa được khởi tạo');
      return null;
    }

    final serializedData = _cacheBox.get(key);
    if (serializedData == null) return null;

    String processedData = serializedData as String;

    // Giải mã nếu cần
    if (decrypt) {
      final decodedBytes = base64Decode(processedData);
      processedData = utf8.decode(decodedBytes);
    }

    // Giải nén nếu cần
    if (decompress) {
      final decoded = base64Decode(processedData);
      final decompressed = gzip.decode(decoded);
      processedData = utf8.decode(decompressed);
    }

    try {
      final jsonData = jsonDecode(processedData);
      final cacheItem = CacheItem<T>.fromJson(jsonData);

      // Kiểm tra hết hạn
      if (cacheItem.isExpired()) {
        await removeFromCache(key);
        return null;
      }

      return cacheItem.data;
    } catch (e) {
      debugPrint('Lỗi khi đọc dữ liệu cache: $e');
      await removeFromCache(key);
      return null;
    }
  }

  /// Xóa một mục khỏi cache
  Future<void> removeFromCache(String key) async {
    if (!_initialized) return;
    await _cacheBox.delete(key);
    await _updateCacheSize();
  }

  /// Xóa tất cả cache
  Future<void> clearCache() async {
    if (!_initialized) return;
    await _cacheBox.clear();

    // Xóa cả các file cache
    if (_cacheDirPath != null) {
      final dir = Directory(_cacheDirPath!);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
    }

    await _updateCacheSize();
  }

  /// Cập nhật kích thước cache
  Future<void> _updateCacheSize() async {
    int size = 0;

    // Kích thước cache trong Hive
    for (var key in _cacheBox.keys) {
      final value = _cacheBox.get(key);
      if (value is String) {
        size += value.length;
      }
    }

    // Kích thước cache trong thư mục
    if (_cacheDirPath != null) {
      final dir = Directory(_cacheDirPath!);
      if (await dir.exists()) {
        await for (final file
            in dir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            final stat = await file.stat();
            size += stat.size;
          }
        }
      }
    }

    _cacheSizeSubject.add(size);
  }

  /// Lấy kích thước cache hiện tại
  Future<int> getCacheSize() async {
    if (!_initialized) return 0;
    await _updateCacheSize();
    return _cacheSizeSubject.value;
  }

  /// Xóa cache đã hết hạn
  Future<void> _cleanupExpiredCache() async {
    if (!_initialized) return;

    final keysToRemove = <String>[];

    for (var key in _cacheBox.keys) {
      final value = _cacheBox.get(key);
      if (value == null) continue;

      try {
        final jsonData = jsonDecode(value as String);
        final expirationStr = jsonData['expiration'];

        if (expirationStr != null) {
          final expiration = DateTime.parse(expirationStr);
          if (DateTime.now().isAfter(expiration)) {
            keysToRemove.add(key as String);
          }
        }
      } catch (e) {
        // Nếu không thể đọc giá trị, xóa nó
        keysToRemove.add(key as String);
      }
    }

    for (var key in keysToRemove) {
      await _cacheBox.delete(key);
    }

    await _updateCacheSize();
  }

  /// Xóa cache cũ nhất khi vượt quá giới hạn
  Future<void> _cleanupOldestCache() async {
    if (!_initialized) return;

    // Tạo danh sách các mục với timestamp
    final entries = <MapEntry<String, DateTime>>[];

    for (var key in _cacheBox.keys) {
      final value = _cacheBox.get(key);
      if (value == null) continue;

      try {
        final jsonData = jsonDecode(value as String);
        final timestampStr = jsonData['timestamp'];

        if (timestampStr != null) {
          final timestamp = DateTime.parse(timestampStr);
          entries.add(MapEntry(key as String, timestamp));
        }
      } catch (e) {
        // Bỏ qua
      }
    }

    // Sắp xếp theo thời gian, cũ nhất đầu tiên
    entries.sort((a, b) => a.value.compareTo(b.value));

    // Xóa 20% mục cũ nhất
    final removeCount = (entries.length * 0.2).ceil();
    for (var i = 0; i < removeCount && i < entries.length; i++) {
      await _cacheBox.delete(entries[i].key);
    }

    await _updateCacheSize();
  }

  /// Lưu file vào cache
  Future<String?> cacheFile(String url, List<int> bytes,
      {String? fileName}) async {
    if (!_initialized || _cacheDirPath == null) return null;

    try {
      final key = _createCacheKey(url);
      final actualFileName = fileName ?? key;
      final filePath = '$_cacheDirPath/$actualFileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Lưu thông tin file vào cache box để quản lý
      await saveToCache(
        key,
        {
          'filePath': filePath,
          'url': url,
          'fileName': actualFileName,
          'size': bytes.length,
        },
      );

      return filePath;
    } catch (e) {
      debugPrint('Lỗi khi lưu file vào cache: $e');
      return null;
    }
  }

  /// Lấy file từ cache
  Future<File?> getCachedFile(String url) async {
    if (!_initialized) return null;

    final key = _createCacheKey(url);
    final fileInfo = await getFromCache<Map<String, dynamic>>(key);

    if (fileInfo == null) return null;

    final filePath = fileInfo['filePath'] as String?;
    if (filePath == null) return null;

    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }

    // Nếu file không tồn tại, xóa thông tin khỏi cache
    await removeFromCache(key);
    return null;
  }

  /// Tải dữ liệu từ mạng và lưu vào cache
  Future<T?> fetchAndCache<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    CacheConfig? config,
  }) async {
    if (!_initialized) {
      debugPrint('Cache service chưa được khởi tạo');
      return null;
    }

    if (_apiService == null) {
      debugPrint('API service chưa được cung cấp');
      return null;
    }

    final effectiveConfig = config ?? const CacheConfig();
    final cacheKey = _createCacheKey(endpoint, params: queryParams);

    // Quyết định chiến lược tải dữ liệu
    switch (effectiveConfig.strategy) {
      case CacheStrategy.cacheFirst:
        return await _cacheThenNetworkStrategy<T>(
          cacheKey,
          endpoint,
          queryParams,
          effectiveConfig,
        );

      case CacheStrategy.networkFirst:
        return await _networkThenCacheStrategy<T>(
          cacheKey,
          endpoint,
          queryParams,
          effectiveConfig,
        );

      case CacheStrategy.cacheThenNetwork:
        // Đối với chiến lược này, chúng ta trả về cache ngay lập tức và
        // khởi chạy một tác vụ riêng biệt để cập nhật cache
        final cachedData = await getFromCache<T>(
          cacheKey,
          decrypt: effectiveConfig.encrypt,
          decompress: effectiveConfig.compress,
        );

        // Khởi chạy tác vụ cập nhật cache trong nền
        _fetchAndUpdateCache<T>(
          cacheKey,
          endpoint,
          queryParams,
          effectiveConfig,
        );

        return cachedData;

      case CacheStrategy.cacheIfRecent:
        return await _cacheIfRecentStrategy<T>(
          cacheKey,
          endpoint,
          queryParams,
          effectiveConfig,
        );

      case CacheStrategy.noCache:
        // Không sử dụng cache, luôn tải dữ liệu mới
        try {
          final data = await _apiService!.get(
            endpoint,
            queryParameters: queryParams,
          );
          return data as T;
        } catch (e) {
          debugPrint('Lỗi khi tải dữ liệu: $e');
          return null;
        }
    }
  }

  /// Chiến lược: Ưu tiên cache, dùng mạng khi không có cache
  Future<T?> _cacheThenNetworkStrategy<T>(
    String cacheKey,
    String endpoint,
    Map<String, dynamic>? queryParams,
    CacheConfig config,
  ) async {
    final cachedData = await getFromCache<T>(
      cacheKey,
      decrypt: config.encrypt,
      decompress: config.compress,
    );

    if (cachedData != null) {
      return cachedData;
    }

    // Nếu không có cache hoặc đã hết hạn, tải từ mạng
    if (_isOnline) {
      try {
        final data = await _apiService!.get(
          endpoint,
          queryParameters: queryParams,
        );

        // Lưu vào cache
        await saveToCache<T>(
          cacheKey,
          data as T,
          expiration: config.expiration,
          encrypt: config.encrypt,
          compress: config.compress,
        );

        return data;
      } catch (e) {
        debugPrint('Lỗi khi tải dữ liệu: $e');
        return null;
      }
    }

    return null;
  }

  /// Chiến lược: Ưu tiên mạng, dùng cache khi offline
  Future<T?> _networkThenCacheStrategy<T>(
    String cacheKey,
    String endpoint,
    Map<String, dynamic>? queryParams,
    CacheConfig config,
  ) async {
    if (_isOnline) {
      try {
        final data = await _apiService!.get(
          endpoint,
          queryParameters: queryParams,
        );

        // Lưu vào cache
        await saveToCache<T>(
          cacheKey,
          data as T,
          expiration: config.expiration,
          encrypt: config.encrypt,
          compress: config.compress,
        );

        return data;
      } catch (e) {
        debugPrint('Lỗi khi tải dữ liệu: $e');
      }
    }

    // Nếu không có mạng hoặc có lỗi khi tải, thử dùng cache
    return await getFromCache<T>(
      cacheKey,
      decrypt: config.encrypt,
      decompress: config.compress,
    );
  }

  /// Chiến lược: Dùng cache nếu còn mới, nếu không thì tải dữ liệu mới
  Future<T?> _cacheIfRecentStrategy<T>(
    String cacheKey,
    String endpoint,
    Map<String, dynamic>? queryParams,
    CacheConfig config,
  ) async {
    final cachedData = await getFromCache<T>(
      cacheKey,
      decrypt: config.encrypt,
      decompress: config.compress,
    );

    // Kiểm tra tuổi của cache
    if (cachedData != null) {
      final cacheInfo = _cacheBox.get(cacheKey);
      try {
        final jsonData = jsonDecode(cacheInfo as String);
        final timestampStr = jsonData['timestamp'];

        if (timestampStr != null) {
          final timestamp = DateTime.parse(timestampStr);
          final age = DateTime.now().difference(timestamp);

          // Nếu cache còn mới, trả về
          if (age < config.expiration) {
            return cachedData;
          }
        }
      } catch (e) {
        // Bỏ qua
      }
    }

    // Nếu không có cache hoặc cache đã cũ, tải dữ liệu mới
    if (_isOnline) {
      try {
        final data = await _apiService!.get(
          endpoint,
          queryParameters: queryParams,
        );

        // Lưu vào cache
        await saveToCache<T>(
          cacheKey,
          data as T,
          expiration: config.expiration,
          encrypt: config.encrypt,
          compress: config.compress,
        );

        return data;
      } catch (e) {
        debugPrint('Lỗi khi tải dữ liệu: $e');
        // Nếu có lỗi khi tải và có cache (dù đã cũ), dùng cache
        return cachedData;
      }
    }

    // Nếu không có mạng, dùng cache (dù đã cũ)
    return cachedData;
  }

  /// Tải dữ liệu và cập nhật cache trong nền
  Future<void> _fetchAndUpdateCache<T>(
    String cacheKey,
    String endpoint,
    Map<String, dynamic>? queryParams,
    CacheConfig config,
  ) async {
    if (!_isOnline || _apiService == null) return;

    try {
      final data = await _apiService!.get(
        endpoint,
        queryParameters: queryParams,
      );

      // Lưu vào cache
      await saveToCache<T>(
        cacheKey,
        data as T,
        expiration: config.expiration,
        encrypt: config.encrypt,
        compress: config.compress,
      );
    } catch (e) {
      debugPrint('Lỗi khi cập nhật cache trong nền: $e');
    }
  }

  /// Kiểm tra xem dữ liệu có cần làm mới không
  Future<bool> needsRefresh(String key, {Duration? maxAge}) async {
    if (!_initialized) return true;

    final effectiveMaxAge = maxAge ?? _defaultExpiration;
    final value = _cacheBox.get(key);
    if (value == null) return true;

    try {
      final jsonData = jsonDecode(value as String);
      final timestampStr = jsonData['timestamp'];

      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final age = DateTime.now().difference(timestamp);

        return age > effectiveMaxAge;
      }
    } catch (e) {
      // Bỏ qua
    }

    return true;
  }

  /// Hủy đăng ký và giải phóng tài nguyên
  void dispose() {
    _cleanupTimer?.cancel();
    _cacheSizeSubject.close();
    _connectivityService.removeListener(_onConnectivityChanged);
  }
}
