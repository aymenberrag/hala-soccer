import '../../core/network/backend_api_client.dart';
import '../models/app_user.dart';

class AuthService {
  final _client = BackendApiClient.instance;

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _client.post(
      "/api/auth/signup",
      auth: false,
      body: {
        "name": name,
        "email": email,
        "password": password,
        "confirm_password": confirmPassword,
      },
    );
    return AuthResult.fromJson(data);
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final data = await _client.post(
      "/api/auth/login",
      auth: false,
      body: {"email": email, "password": password},
    );
    return AuthResult.fromJson(data);
  }

  Future<void> logout() => _client.post("/api/auth/logout");

  Future<AppUser> me() async {
    final data = await _client.get("/api/auth/me");
    return AppUser.fromJson(data);
  }

  Future<void> forgotPassword(String email) =>
      _client.post("/api/auth/forgot-password", auth: false, body: {"email": email});
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  AuthResult({required this.accessToken, required this.refreshToken, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        accessToken: json["access_token"] as String,
        refreshToken: json["refresh_token"] as String,
        user: AppUser.fromJson(json["user"] as Map<String, dynamic>),
      );
}

