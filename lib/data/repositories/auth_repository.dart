import '../../core/constants/api_constants.dart';
import '../../core/storage/app_storage.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;
  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _service.signup(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    await _persist(result);
    return result.user;
  }

  Future<AppUser> login({required String email, required String password}) async {
    final result = await _service.login(email: email, password: password);
    await _persist(result);
    return result.user;
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {
      // Even if the server call fails (e.g. offline), clear local session.
    }
    await SecureStorage.delete(StorageKeys.accessToken);
    await SecureStorage.delete(StorageKeys.refreshToken);
    await SecureStorage.delete(StorageKeys.cachedUser);
  }

  /// Returns the current user if a session exists, or null. Validates the
  /// stored token against the server rather than trusting local state.
  Future<AppUser?> currentSession() async {
    final token = await SecureStorage.read(StorageKeys.accessToken);
    if (token == null) return null;

    try {
      return await _service.me();
    } catch (_) {
      // Token invalid/expired and refresh (handled inside the client)
      // also failed — no valid session.
      return null;
    }
  }

  Future<void> _persist(AuthResult result) async {
    await SecureStorage.write(StorageKeys.accessToken, result.accessToken);
    await SecureStorage.write(StorageKeys.refreshToken, result.refreshToken);
  }
}
