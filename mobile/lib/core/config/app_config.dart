/// Application Configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'Flutter Forge App';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;

  // API Configuration
  static String get baseUrl {
    return isProduction
        ? 'https://api.production.com' //will be replaced with the actual production URL
        : 'https://api.development.com'; //will be replaced with the actual development URL
  }
}
