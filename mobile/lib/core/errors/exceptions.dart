/// Base Exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Server Exception
/// Thrown when there's an error from the server
class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

/// Cache Exception
/// Thrown when there's an error with local cache/storage
class CacheException extends AppException {
  CacheException({required super.message});
}

/// Network Exception
/// Thrown when there's no internet connection
class NetworkException extends AppException {
  NetworkException({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Unauthorized Exception
/// Thrown when user is not authenticated
class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Unauthorized access. Please login again.',
    super.statusCode = 401,
  });
}

/// Forbidden Exception
/// Thrown when user doesn't have permission
class ForbiddenException extends AppException {
  ForbiddenException({
    super.message = 'Access forbidden. You don\'t have permission.',
    super.statusCode = 403,
  });
}

/// Not Found Exception
/// Thrown when resource is not found
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Resource not found.',
    super.statusCode = 404,
  });
}

/// Timeout Exception
/// Thrown when request times out
class TimeoutException extends AppException {
  TimeoutException({super.message = 'Request timeout. Please try again.'});
}

/// Validation Exception
/// Thrown when data validation fails
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({
    super.message = 'Validation failed.',
    this.errors,
    super.statusCode = 422,
  });
}

/// Parse Exception
/// Thrown when JSON parsing fails
class ParseException extends AppException {
  ParseException({super.message = 'Failed to parse response data.'});
}
