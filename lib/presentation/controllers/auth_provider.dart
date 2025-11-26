import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartone/data/repositories/auth_repository.dart';
import 'package:smartone/data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateProvider = StateNotifierProvider<AuthController, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

class AuthState {
  final bool isLoggedIn;
  final String? token;
  final String? userId;
  final String? userRole;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isLoggedIn,
    this.token,
    this.userId,
    this.userRole,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    String? userId,
    String? userRole,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(AuthState(isLoggedIn: false));

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _authRepository.login(email, password);
      if (token != null) {
        state = state.copyWith(
          isLoggedIn: true,
          token: token,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoggedIn: false,
          isLoading: false,
          error: 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoggedIn: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState(isLoggedIn: false);
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final token = await _authRepository.getCurrentUserToken();
      state = state.copyWith(isLoggedIn: true, token: token);
    } else {
      state = AuthState(isLoggedIn: false);
    }
  }
}
