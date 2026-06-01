import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_user.dart';
import '../../data/models/country.dart';
import '../../data/models/requests.dart';
import '../../core/errors/app_exception.dart';
import 'core_providers.dart';

// ── Auth State ────────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final AppUser? user;
  final bool isLoading;
  final AppException? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    AppException? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      state = AuthState(user: user);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: const UnknownException());
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).register(request);
      state = AuthState(user: user);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: const UnknownException());
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  void logout() => state = const AuthState();
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ── Countries Provider ─────────────────────────────────────────────────────────

final countriesProvider = FutureProvider<List<Country>>((ref) async {
  return ref.read(authRepositoryProvider).getCountries()
      as Future<List<Country>>;
});
