import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/views/home_screen.dart';

abstract class AppRouter {
  AppRouter._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: AppRouter.splash,
    routes: [
      GoRoute(
        path: AppRouter.splash,
        builder: (context, state) => const SplashScreen(),
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
