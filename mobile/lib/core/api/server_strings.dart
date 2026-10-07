/// API Endpoint Strings
class ServerStrings {
  ServerStrings._();

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';

  // Add your custom endpoints here
}
