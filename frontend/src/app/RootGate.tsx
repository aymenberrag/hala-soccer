import { Navigate, Outlet, useLocation } from "react-router-dom";

import { AppRoutes } from "./routes";
import { useAuth } from "@/context/AuthContext";
import SplashPage from "@/features/splash/SplashPage";

const AUTH_GATE_PATHS: string[] = [AppRoutes.login, AppRoutes.signup, AppRoutes.forgotPassword];
const PREFERENCES_GATE_PATHS: string[] = [
  AppRoutes.preferencesInfo,
  AppRoutes.preferencesTeams,
  AppRoutes.preferencesLeagues,
];

/**
 * Same decision tree as app_router.dart's `redirect`:
 *   intro not seen        -> onboarding
 *   not authenticated     -> login/signup/forgot-password
 *   authenticated, prefs
 *     not yet collected   -> user info -> favorite teams -> favorite leagues
 *   authenticated, prefs
 *     already collected   -> home (any other path is left alone)
 */
function computeRedirect(pathname: string, auth: ReturnType<typeof useAuth>): string | null {
  if (!auth.onboardingComplete) {
    return pathname === AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }

  const atAuthGate = AUTH_GATE_PATHS.includes(pathname);
  if (auth.status !== "authenticated") {
    return atAuthGate ? null : AppRoutes.login;
  }

  const atPreferencesGate = PREFERENCES_GATE_PATHS.includes(pathname);
  if (auth.user?.preferencesComplete !== true) {
    return atPreferencesGate ? null : AppRoutes.preferencesInfo;
  }

  if (pathname === AppRoutes.splash || atAuthGate || atPreferencesGate) {
    return AppRoutes.home;
  }
  return null;
}

export default function RootGate() {
  const auth = useAuth();
  const location = useLocation();

  // Session restore is still in flight — same moment the Flutter app
  // shows Splash while AuthController._bootstrap() resolves.
  if (auth.status === "unknown") {
    return <SplashPage />;
  }

  const target = computeRedirect(location.pathname, auth);
  if (target && target !== location.pathname) {
    return <Navigate to={target} replace />;
  }

  return <Outlet />;
}
