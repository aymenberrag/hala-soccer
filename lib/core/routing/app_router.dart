import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/fixture.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/competitions/screens/league_details_screen.dart';
import '../../features/home/screens/home_shell.dart';
import '../../features/matches/screens/fixture_details_screen.dart';
import '../../features/onboarding/screens/favorite_leagues_screen.dart';
import '../../features/onboarding/screens/favorite_teams_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/user_info_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const splash = "/";
  static const onboarding = "/onboarding";
  static const login = "/login";
  static const signup = "/signup";
  static const forgotPassword = "/forgot-password";
  static const preferencesInfo = "/preferences/info";
  static const preferencesTeams = "/preferences/teams";
  static const preferencesLeagues = "/preferences/leagues";
  static const home = "/home";
  static const fixtureDetails = "/fixture";
  static const leagueDetails = "/league";
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

      // Spec section 3's startup routing:
      //   intro not seen        -> onboarding (intro carousel)
      //   not authenticated     -> login/signup/forgot-password
      //   authenticated, prefs
      //     not yet collected   -> user info -> favorite teams -> favorite leagues
      //   authenticated, prefs
      //     already collected   -> home
      if (!authState.onboardingComplete) {
        return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      final atAuthGate = loc == AppRoutes.login ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.forgotPassword;

      if (authState.status != AuthStatus.authenticated) {
        return atAuthGate ? null : AppRoutes.login;
      }

      final atPreferencesGate = loc == AppRoutes.preferencesInfo ||
          loc == AppRoutes.preferencesTeams ||
          loc == AppRoutes.preferencesLeagues;

      if (authState.user?.preferencesComplete != true) {
        return atPreferencesGate ? null : AppRoutes.preferencesInfo;
      }

      // Fully onboarded — keep auth/preferences screens out of reach, but
      // let any /home, /fixture/*, /league/* route through untouched.
      if (loc == AppRoutes.splash || atAuthGate || atPreferencesGate) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (c, s) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (c, s) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (c, s) => const SignupScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.preferencesInfo, builder: (c, s) => const UserInfoScreen()),
      GoRoute(path: AppRoutes.preferencesTeams, builder: (c, s) => const FavoriteTeamsScreen()),
      GoRoute(path: AppRoutes.preferencesLeagues, builder: (c, s) => const FavoriteLeaguesScreen()),
      GoRoute(path: AppRoutes.home, builder: (c, s) => const HomeShell()),
      GoRoute(
        path: "${AppRoutes.fixtureDetails}/:id",
        builder: (c, s) {
          final fixture = s.extra as Fixture?;
          final id = int.tryParse(s.pathParameters["id"] ?? "") ?? fixture?.id ?? 0;
          return FixtureDetailsScreen(fixtureId: id, initialFixture: fixture);
        },
      ),
      GoRoute(
        path: "${AppRoutes.leagueDetails}/:id",
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>?;
          final id = int.tryParse(s.pathParameters["id"] ?? "") ?? (extra?["id"] as int? ?? 0);
          return LeagueDetailsScreen(
            leagueId: id,
            leagueName: extra?["name"] as String? ?? "League",
            leagueLogo: extra?["logo"] as String? ?? "",
            leagueCountry: extra?["country"] as String?,
          );
        },
      ),
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
