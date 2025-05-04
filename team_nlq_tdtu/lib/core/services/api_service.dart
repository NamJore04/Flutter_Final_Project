import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service xử lý tất cả các yêu cầu API trong ứng dụng
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  String? _authToken;
  String? _refreshToken;
  final String _baseUrl = 'https://api.nlqtdtu.com/v1';
  final _storage = const FlutterSecureStorage();
  
  // Thời gian timeout cho mỗi request (mặc định 15 giây)
  final Duration _timeout = const Duration(seconds: 15);

  // Stream controller cho trạng thái đăng nhập
  final StreamController<bool> _authStreamController = StreamController<bool>.broadcast();
  Stream<bool> get authStream => _authStreamController.stream;

  ApiService._internal() {
    _initDio();
  }

  /// Khởi tạo client Dio
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Thêm interceptor để xử lý token authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Thêm Logging Interceptor nếu đang trong chế độ debug
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// Khởi tạo service với token đã lưu
  Future<void> init() async {
    await _loadTokens();
  }

  /// Tải các token từ bộ nhớ an toàn
  Future<void> _loadTokens() async {
    try {
      _authToken = await _storage.read(key: 'auth_token');
      _refreshToken = await _storage.read(key: 'refresh_token');
      _authStreamController.add(_authToken != null);
    } catch (e) {
      debugPrint('Lỗi khi tải tokens: $e');
    }
  }

  /// Lưu các token vào bộ nhớ an toàn
  Future<void> _saveTokens(String authToken, String refreshToken) async {
    try {
      await _storage.write(key: 'auth_token', value: authToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      _authToken = authToken;
      _refreshToken = refreshToken;
      _authStreamController.add(true);
    } catch (e) {
      debugPrint('Lỗi khi lưu tokens: $e');
    }
  }

  /// Xóa các token khi đăng xuất
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'refresh_token');
      _authToken = null;
      _refreshToken = null;
      _authStreamController.add(false);
    } catch (e) {
      debugPrint('Lỗi khi xóa tokens: $e');
    }
  }

  /// Xử lý request trước khi gửi đi
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Thêm Authorization header nếu có token
    if (_authToken != null) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }
    handler.next(options);
  }

  /// Xử lý response trước khi trả về
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Xử lý lỗi request
  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    // Xử lý lỗi token hết hạn
    if (error.response?.statusCode == 401 && _refreshToken != null) {
      try {
        final newTokens = await _refreshAuthToken();
        if (newTokens != null) {
          // Thử lại request với token mới
          final response = await _retryRequest(error.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        debugPrint('Lỗi khi làm mới token: $e');
        // Nếu không thể làm mới token, đăng xuất người dùng
        await clearTokens();
      }
    }
    handler.next(error);
  }

  /// Làm mới token xác thực
  Future<Map<String, String>?> _refreshAuthToken() async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.statusCode == 200) {
        final String newAuthToken = response.data['accessToken'];
        final String newRefreshToken = response.data['refreshToken'];
        await _saveTokens(newAuthToken, newRefreshToken);
        return {
          'accessToken': newAuthToken,
          'refreshToken': newRefreshToken,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi khi làm mới token: $e');
      return null;
    }
  }

  /// Thử lại request với token mới
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Đặt token xác thực mới
  Future<void> setTokens(String authToken, String refreshToken) async {
    await _saveTokens(authToken, refreshToken);
  }

  /// Thực hiện request API
  Future<dynamic> request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Options requestOptions = options ?? Options();
      requestOptions.method = method;
      
      final Response response = await _dio.request(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      // Đảm bảo luôn trả về dữ liệu dưới dạng Map
      if (response.data is! Map<String, dynamic>) {
        return {
          'data': response.data,
          'statusCode': response.statusCode,
        };
      }
      
      return response.data;
    } on DioException catch (e) {
      // Log lỗi để debug
      debugPrint('Dio lỗi ${e.type} - ${e.message} - ${e.error}');
      
      // Xử lý các loại lỗi kết nối và timeout
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return {
          'error': true, 
          'offline': true, 
          'message': 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại sau.'
        };
      }
      
      // Xử lý lỗi phản hồi từ server
      if (e.type == DioExceptionType.badResponse && e.response != null) {
        final statusCode = e.response?.statusCode;
        String message = 'Đã xảy ra lỗi';
        
        try {
          if (e.response?.data is Map) {
            message = e.response?.data['message'] ?? message;
          } else if (e.response?.data is String) {
            final jsonData = _tryParseJson(e.response?.data);
            if (jsonData != null) {
              message = jsonData['message'] ?? message;
            }
          }
        } catch (_) {
          // Ignore parsing errors
        }
        
        return {
          'error': true,
          'message': message,
          'statusCode': statusCode,
        };
      }
      
      // Các lỗi khác
      return {
        'error': true, 
        'message': e.message ?? 'Đã xảy ra lỗi khi gửi yêu cầu'
      };
    } catch (e) {
      debugPrint('Lỗi không xác định: $e');
      return {
        'error': true, 
        'message': 'Đã xảy ra lỗi không xác định: $e'
      };
    }
  }

  /// Xử lý lỗi từ Dio
  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        debugPrint('Lỗi timeout: ${e.message}');
        throw TimeoutException('Yêu cầu đã hết thời gian. Vui lòng thử lại sau.');
      
      case DioExceptionType.badResponse:
        _handleBadResponse(e.response);
        break;
      
      case DioExceptionType.cancel:
        debugPrint('Yêu cầu đã bị hủy: ${e.message}');
        throw Exception('Yêu cầu đã bị hủy.');
      
      case DioExceptionType.connectionError:
        debugPrint('Lỗi kết nối: ${e.message}');
        throw const SocketException('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.');
      
      default:
        debugPrint('Lỗi không xác định: ${e.message}');
        throw Exception('Đã xảy ra lỗi không xác định: ${e.message}');
    }
  }

  /// Xử lý phản hồi lỗi
  void _handleBadResponse(Response? response) {
    if (response == null) {
      throw Exception('Không nhận được phản hồi từ máy chủ.');
    }

    final int statusCode = response.statusCode ?? 0;
    String message = 'Đã xảy ra lỗi';

    try {
      if (response.data is Map) {
        message = response.data['message'] ?? message;
      } else if (response.data is String) {
        final Map<String, dynamic>? jsonData = _tryParseJson(response.data);
        if (jsonData != null) {
          message = jsonData['message'] ?? message;
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi phân tích dữ liệu phản hồi: $e');
    }

    switch (statusCode) {
      case 400:
        throw Exception('Yêu cầu không hợp lệ: $message');
      case 401:
        throw Exception('Không được phép: $message');
      case 403:
        throw Exception('Bị cấm: $message');
      case 404:
        throw Exception('Không tìm thấy: $message');
      case 409:
        throw Exception('Xung đột: $message');
      case 422:
        throw Exception('Dữ liệu không hợp lệ: $message');
      case 500:
      case 501:
      case 502:
      case 503:
        throw Exception('Lỗi máy chủ: $message');
      default:
        throw Exception('Lỗi không xác định ($statusCode): $message');
    }
  }

  /// Thử phân tích chuỗi JSON
  Map<String, dynamic>? _tryParseJson(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Phương thức GET
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      endpoint,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Phương thức POST
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      endpoint,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Phương thức PUT
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      endpoint,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Phương thức PATCH
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request(
      endpoint,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Phương thức DELETE
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return request(
      endpoint,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Phương thức tải lên tệp
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String paramName = 'file',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        paramName: await MultipartFile.fromFile(file.path, filename: fileName),
        if (data != null) ...data,
      });

      return _dio.post(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      debugPrint('Lỗi khi tải lên tệp: $e');
      throw Exception('Đã xảy ra lỗi khi tải lên tệp: $e');
    }
  }

  /// Phương thức tải xuống tệp
  Future<dynamic> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
      return {'success': true, 'path': savePath};
    } catch (e) {
      debugPrint('Lỗi khi tải xuống tệp: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Kiểm tra nếu người dùng đã xác thực
  bool get isAuthenticated => _authToken != null;

  /// Hủy các stream khi service bị hủy
  void dispose() {
    _authStreamController.close();
  }
} 