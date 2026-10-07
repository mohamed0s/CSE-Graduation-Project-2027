import 'package:dio/dio.dart';
import '../errors/dio_exception_handler.dart';
import 'api_consumer.dart';

/// Dio API Consumer
///
/// Concrete implementation of [ApiConsumer] using Dio.
///
/// This class is responsible for:
/// - Sending HTTP requests through Dio.
/// - Passing request data, query parameters, and headers.
/// - Returning the response data.
/// - Converting Dio exceptions into application-specific exceptions.
///
/// The rest of the application does not need to know that Dio is being used.
/// It only depends on the [ApiConsumer] interface.
class DioApiConsumer implements ApiConsumer {
  /// Dio instance used to perform HTTP requests.
  final Dio dio;

  /// [dio] is injected through Dependency Injection.
  DioApiConsumer(this.dio);

  /// Performs a GET request.
  ///
  /// [path] is the API endpoint.
  /// [queryParameters] contains optional URL query parameters.
  /// [headers] contains optional request-specific headers.
  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      );

      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  /// Performs a POST request.
  ///
  /// [path] is the API endpoint.
  /// [body] contains the data that will be sent to the server.
  /// [queryParameters] contains optional URL query parameters.
  /// [headers] contains optional request-specific headers.
  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      );

      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  /// Performs a PUT request.
  ///
  /// [path] is the API endpoint.
  /// [body] contains the data that will be sent to the server.
  /// [queryParameters] contains optional URL query parameters.
  /// [headers] contains optional request-specific headers.
  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      );

      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  /// Performs a DELETE request.
  ///
  /// [path] is the API endpoint.
  /// [queryParameters] contains optional URL query parameters.
  /// [headers] contains optional request-specific headers.
  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await dio.delete(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      );

      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  /// Performs a PATCH request.
  ///
  /// [path] is the API endpoint.
  /// [body] contains the data that will be sent to the server.
  /// [queryParameters] contains optional URL query parameters.
  /// [headers] contains optional request-specific headers.
  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: body,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      );

      return response.data;
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  /// Builds request-specific Dio options.
  ///
  /// The global headers are already configured in [Dio] inside
  /// the Dependency Injection container.
  ///
  /// This method is only used when a specific request needs
  /// additional or different headers.
  Options? _buildOptions(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) {
      return null;
    }

    return Options(headers: headers);
  }
}
