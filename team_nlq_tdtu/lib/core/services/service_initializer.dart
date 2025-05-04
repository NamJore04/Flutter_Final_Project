import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'offline_sync_service.dart';
import 'service_provider.dart';

/// Lớp tiện ích để khởi tạo và quản lý các dịch vụ trong toàn bộ ứng dụng
class ServiceInitializer extends StatelessWidget {
  final Widget child;
  final Widget? loadingScreen;
  final VoidCallback? onInitialized;

  const ServiceInitializer({
    super.key,
    required this.child,
    this.loadingScreen,
    this.onInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ServiceProvider.providers(),
      child: _ServiceInitializerContent(
        loadingScreen: loadingScreen,
        onInitialized: onInitialized,
        child: child,
      ),
    );
  }
}

/// Widget nội dung để quản lý việc khởi tạo các dịch vụ
class _ServiceInitializerContent extends StatefulWidget {
  final Widget child;
  final Widget? loadingScreen;
  final VoidCallback? onInitialized;

  const _ServiceInitializerContent({
    required this.child,
    this.loadingScreen,
    this.onInitialized,
  });

  @override
  _ServiceInitializerContentState createState() =>
      _ServiceInitializerContentState();
}

class _ServiceInitializerContentState
    extends State<_ServiceInitializerContent> {
  late ServiceProvider _serviceProvider;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    _serviceProvider = context.read<ServiceProvider>();
    _initializeServices();
  }

  /// Khởi tạo tất cả các dịch vụ
  Future<void> _initializeServices() async {
    if (_serviceProvider.isInitialized || _initializing) {
      return;
    }

    setState(() {
      _initializing = true;
    });

    await _serviceProvider.initialize();

    if (mounted) {
      setState(() {
        _initializing = false;
      });

      if (widget.onInitialized != null) {
        widget.onInitialized!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu các dịch vụ đã được khởi tạo, hiển thị nội dung chính
    if (_serviceProvider.isInitialized) {
      return widget.child;
    }

    // Nếu đang khởi tạo và có màn hình loading, hiển thị nó
    if (_initializing && widget.loadingScreen != null) {
      return widget.loadingScreen!;
    }

    // Màn hình loading mặc định
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang khởi tạo dịch vụ...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mở rộng BuildContext để truy cập dễ dàng các dịch vụ
extension ServiceExtension on BuildContext {
  /// Truy cập ServiceProvider một cách nhanh chóng
  ServiceProvider get services => ServiceProvider.of(this);

  /// API Service
  ApiService get api => services.api;

  /// Cache Service
  CacheService get cache => services.cache;

  /// Connectivity Service
  ConnectivityService get connectivity => services.connectivity;

  /// Offline Sync Service
  OfflineSyncService get offlineSync => services.offlineSync;
}
