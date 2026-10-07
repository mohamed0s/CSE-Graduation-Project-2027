import 'package:dio/dio.dart';

/// API Interceptor for handling requests, responses, and errors
/// Provides centralized logging and error handling
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log request details
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 REQUEST[${options.method}] => PATH: ${options.path}');
    print('Headers: ${options.headers}');
    print('Query Parameters: ${options.queryParameters}');
    print('Body: ${options.data}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log response details
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(
      '📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    print('Data: ${response.data}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('Message: ${err.message}');
    print('Response: ${err.response?.data}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    super.onError(err, handler);
  }
}

/// Authentication Interceptor
/// Automatically adds authentication token to requests
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;

  AuthInterceptor({required this.getToken});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
