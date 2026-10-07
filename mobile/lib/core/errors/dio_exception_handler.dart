import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Dio Exception Handler
///
/// Responsible for converting Dio-specific exceptions
/// into application-specific [AppException] objects.
///
/// This keeps Dio implementation details inside the Core layer
/// and prevents DioException from spreading throughout the application.
class DioExceptionHandler {
  /// Handles a [DioException] and converts it into
  /// the appropriate [AppException].
  static AppException handle(DioException error) {
    // -------------------------------------------------------------------------
    // The request did not receive a response from the server.
    //
    // This usually happens because of:
    // - No internet connection
    // - Connection timeout
    // - Send timeout
    // - Receive timeout
    // - Connection error
    // -------------------------------------------------------------------------

    if (error.response == null) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException();

        case DioExceptionType.connectionError:
          return NetworkException();

        default:
          return NetworkException(
            message: error.message ?? 'Network error occurred.',
          );
      }
    }

    // -------------------------------------------------------------------------
    // The server returned an HTTP response.
    // -------------------------------------------------------------------------

    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      // -----------------------------------------------------------------------
      // 401 - Unauthorized
      // -----------------------------------------------------------------------
      case 401:
        return UnauthorizedException(message: _extractMessage(error));

      // -----------------------------------------------------------------------
      // 403 - Forbidden
      // -----------------------------------------------------------------------
      case 403:
        return ForbiddenException(message: _extractMessage(error));

      // -----------------------------------------------------------------------
      // 404 - Not Found
      // -----------------------------------------------------------------------
      case 404:
        return NotFoundException(message: _extractMessage(error));

      // -----------------------------------------------------------------------
      // 422 - Validation Error
      // -----------------------------------------------------------------------
      case 422:
        return ValidationException(
          message: _extractMessage(error),
          errors: _extractValidationErrors(error),
        );

      // -----------------------------------------------------------------------
      // 5xx - Server Errors
      // -----------------------------------------------------------------------
      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: _extractMessage(error),
          statusCode: statusCode,
        );

      // -----------------------------------------------------------------------
      // Any other HTTP error
      // -----------------------------------------------------------------------
      default:
        return ServerException(
          message: _extractMessage(error),
          statusCode: statusCode,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // EXTRACT ERROR MESSAGE
  // ---------------------------------------------------------------------------

  /// Extracts an error message from the server response.
  ///
  /// Supports common API response formats such as:
  ///
  /// {
  ///   "message": "Invalid email or password"
  /// }
  ///
  /// or:
  ///
  /// {
  ///   "error": "Something went wrong"
  /// }
  static String _extractMessage(DioException error) {
    final data = error.response?.data;

    // No response data.
    if (data == null) {
      return error.message ?? 'Something went wrong.';
    }

    // JSON object response.
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errorMessage = data['error'];

      if (errorMessage is String && errorMessage.isNotEmpty) {
        return errorMessage;
      }
    }

    // String response.
    if (data is String && data.isNotEmpty) {
      return data;
    }

    return error.message ?? 'Something went wrong.';
  }

  // ---------------------------------------------------------------------------
  // EXTRACT VALIDATION ERRORS
  // ---------------------------------------------------------------------------

  /// Extracts field-level validation errors from the response.
  ///
  /// Example:
  ///
  /// {
  ///   "message": "Validation failed",
  ///   "errors": {
  ///     "email": [
  ///       "The email field is required."
  ///     ],
  ///     "password": [
  ///       "The password is too short."
  ///     ]
  ///   }
  /// }
  static Map<String, dynamic>? _extractValidationErrors(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is Map<String, dynamic>) {
        return errors;
      }
    }

    return null;
  }
}
