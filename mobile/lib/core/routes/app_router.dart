import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:mobile/features/auth/presentation/pages/signup_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/views/home_screen.dart';

abstract class AppRouter {
  AppRouter._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';

  static final GoRouter router = GoRouter(
    initialLocation: AppRouter.splash,
    routes: [
      GoRoute(
        path: AppRouter.splash,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRouter.otpVerification,
        builder: (context, state) => const OTPVerificationScreen(),
      ),
      GoRoute(
        path: AppRouter.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRouter.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRouter.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
