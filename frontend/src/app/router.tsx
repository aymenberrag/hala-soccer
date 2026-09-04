import { Outlet, Route, Routes } from "react-router-dom";

import RootGate from "./RootGate";
import AppShell from "@/components/navigation/AppShell";
import { PreferencesDraftProvider } from "@/context/PreferencesDraftContext";
import SplashPage from "@/features/splash/SplashPage";
import OnboardingPage from "@/features/onboarding/OnboardingPage";
import LoginPage from "@/features/auth/LoginPage";
import SignupPage from "@/features/auth/SignupPage";
import ForgotPasswordPage from "@/features/auth/ForgotPasswordPage";
import UserInfoPage from "@/features/onboarding/UserInfoPage";
import FavoriteTeamsPage from "@/features/onboarding/FavoriteTeamsPage";
import FavoriteLeaguesPage from "@/features/onboarding/FavoriteLeaguesPage";
import HomePage from "@/features/home/HomePage";
import MatchesPage from "@/features/matches/MatchesPage";
import FixtureDetailsPage from "@/features/matches/FixtureDetailsPage";
import CompetitionsPage from "@/features/competitions/CompetitionsPage";
import LeagueDetailsPage from "@/features/competitions/LeagueDetailsPage";
import FavoritesPage from "@/features/favorites/FavoritesPage";
import ProfilePage from "@/features/profile/ProfilePage";
import ManageFavoritesPage from "@/features/profile/ManageFavoritesPage";
import ChangePasswordPage from "@/features/profile/ChangePasswordPage";

export default function AppRouter() {
  return (
    <Routes>
      <Route element={<RootGate />}>
        <Route path="/" element={<SplashPage />} />
        <Route path="/onboarding" element={<OnboardingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/signup" element={<SignupPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />

        <Route element={<PreferencesDraftProvider><PreferencesOutlet /></PreferencesDraftProvider>}>
          <Route path="/preferences/info" element={<UserInfoPage />} />
          <Route path="/preferences/teams" element={<FavoriteTeamsPage />} />
          <Route path="/preferences/leagues" element={<FavoriteLeaguesPage />} />
        </Route>

        <Route element={<AppShell />}>
          <Route path="/home" element={<HomePage />} />
          <Route path="/matches" element={<MatchesPage />} />
          <Route path="/matches/:id" element={<FixtureDetailsPage />} />
          <Route path="/competitions" element={<CompetitionsPage />} />
          <Route path="/competitions/:id" element={<LeagueDetailsPage />} />
          <Route path="/favorites" element={<FavoritesPage />} />
          <Route path="/profile" element={<ProfilePage />} />
          <Route path="/profile/favorites/:kind" element={<ManageFavoritesPage />} />
          <Route path="/profile/change-password" element={<ChangePasswordPage />} />
        </Route>
      </Route>
    </Routes>
  );
}

// react-router v6 nested <Route> layouts need an element that renders
// <Outlet/>; the wrapping provider above doesn't do that itself.
function PreferencesOutlet() {
  return <Outlet />;
}
