/// API Consumer Interface
/// Defines the contract for all API operations
/// Supports RESTful operations: GET, POST, PUT, DELETE, PATCH
abstract class ApiConsumer {
  /// Performs a GET request
  ///
  /// [path] - API endpoint path
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Performs a POST request
  ///
  /// [path] - API endpoint path
  /// [body] - Request body data
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Performs a PUT request
  ///
  /// [path] - API endpoint path
  /// [body] - Request body data
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Performs a DELETE request
  ///
  /// [path] - API endpoint path
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Performs a PATCH request
  ///
  /// [path] - API endpoint path
  /// [body] - Request body data
  /// [queryParameters] - Optional query parameters
  /// Returns dynamic response data
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}
