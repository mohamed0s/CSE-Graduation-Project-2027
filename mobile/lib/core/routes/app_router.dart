import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
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
