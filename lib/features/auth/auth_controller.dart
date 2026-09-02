import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final bool onboardingComplete;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.onboardingComplete = false,
  });

  AuthState copyWith({AuthStatus? status, AppUser? user, bool? onboardingComplete}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthState()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final onboardingComplete = await LocalPrefs.getBool(StorageKeys.onboardingComplete);
    final user = await _repo.currentSession();
    state = AuthState(
      status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: user,
      onboardingComplete: onboardingComplete,
    );
  }

  Future<void> completeOnboarding() async {
    await LocalPrefs.setBool(StorageKeys.onboardingComplete, true);
    state = state.copyWith(onboardingComplete: true);
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> login({required String email, required String password}) async {
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final user = await _repo.signup(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);
