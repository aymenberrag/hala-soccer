import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_shell.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = "/";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const signup = "/signup";
  static const forgotPassword = "/forgot-password";
  static const home = "/home";
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    // refreshListenable re-runs `redirect` on auth/onboarding changes
    // without recreating the GoRouter itself (which would lose nav state).
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      // Still resolving session on cold start — stay on splash.
      if (authState.status == AuthStatus.unknown) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // Spec's startup routing:
      //   not onboarded -> onboarding
      //   onboarded + authenticated -> home
      //   onboarded + not authenticated -> login
      if (!authState.onboardingComplete) {
        return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      final atAuthGate = loc == AppRoutes.login ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.forgotPassword;
      if (authState.status == AuthStatus.authenticated) {
        return (loc == AppRoutes.home) ? null : AppRoutes.home;
      } else {
        return atAuthGate ? null : AppRoutes.login;
      }
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (c, s) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (c, s) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (c, s) => const SignupScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.home, builder: (c, s) => const HomeShell()),
    ],
  );
});

/// Bridges Riverpod state changes into something go_router's
/// `refreshListenable` (a plain Listenable) can react to.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}
