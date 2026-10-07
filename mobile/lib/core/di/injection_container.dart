import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile/core/api/api_consumer.dart';
import 'package:mobile/core/api/dio_api_consumer.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../network/network_info.dart';
import '../api/api_interceptors.dart';
import '../config/app_config.dart';

final getIt = GetIt.instance;

/// Initialize Dependency Injection
Future<void> init() async {
  //! Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  //! External
  getIt.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  getIt.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(ApiInterceptor());

    // Add pretty logger in debug mode
    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  });

  /// Register API consumer.
  ///
  /// DioApiConsumer depends on the Dio instance registered above.
  getIt.registerLazySingleton<ApiConsumer>(() => DioApiConsumer(getIt()));

  // Register your dependencies here
  // Example:
  // getIt.registerFactory(() => LoginUseCase(getIt()));
  // getIt.registerFactory(() => AuthRepository(getIt()));
}
