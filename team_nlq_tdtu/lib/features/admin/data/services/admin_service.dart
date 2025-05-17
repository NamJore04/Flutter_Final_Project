import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../../core/services/api_service.dart';
import '../../domain/repositories/admin_repository.dart';
import '../repositories/admin_repository_impl.dart';
import '../../presentation/providers/admin_provider.dart';

class AdminService {
  static List<SingleChildWidget> providers() {
    return [
      ChangeNotifierProvider(
        create: (context) => AdminProvider(
          repository: GetIt.instance<AdminRepository>(),
        ),
      ),
    ];
  }

  static void register() {
    final getIt = GetIt.instance;

    // Đăng ký repository
    if (!getIt.isRegistered<AdminRepository>()) {
      getIt.registerLazySingleton<AdminRepository>(
        () => AdminRepositoryImpl(
          apiService: getIt<ApiService>(),
        ),
      );
    }
  }

  static void dispose() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AdminRepository>()) {
      getIt.unregister<AdminRepository>();
    }
  }
} 