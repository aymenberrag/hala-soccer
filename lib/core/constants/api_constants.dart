/// Central place for every base URL / static config the app needs.
/// Real secrets (API keys) stay out of source — see core/network/env.dart.
class ApiConstants {
  ApiConstants._();

  // Existing third-party football data API (unchanged from v1).
  static const String footballApiBaseUrl = "https://v3.football.api-sports.io";

  // New: our own Flask backend, auth + user data only.
  // Override at build time with:
  //   flutter run --dart-define=BACKEND_BASE_URL=https://api.halasoccer.app
  static const String backendBaseUrl = String.fromEnvironment(
    "BACKEND_BASE_URL",
    defaultValue: "http://10.0.2.2:5050", // Android emulator -> host localhost
  );

  static const Duration requestTimeout = Duration(seconds: 15);
}

class StorageKeys {
  StorageKeys._();

  static const String onboardingComplete = "onboarding_complete";
  static const String accessToken = "access_token";
  static const String refreshToken = "refresh_token";
  static const String cachedUser = "cached_user";
}
