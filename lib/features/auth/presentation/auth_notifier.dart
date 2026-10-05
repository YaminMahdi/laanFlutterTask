import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transfer/presentation/providers/transfer_providers.dart';
import '../data/token_storage.dart';

class AuthState {
  const AuthState({
    required this.isLoggedIn,
    this.username,
    this.token,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  final bool isLoggedIn;
  final String? username;
  final String? token;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoggedIn,
    String? username,
    String? token,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  @override
  AuthState build() {
    // Check pre-seeded / stored credentials
    final storage = ref.watch(tokenStorageProvider);
    _initializeAuth(storage);
    return const AuthState(isLoggedIn: false, isInitialized: false);
  }

  Future<void> _initializeAuth(TokenStorage storage) async {
    try {
      final token = await storage.getToken();
      final username = await storage.getUsername();
      if (token != null && token.isNotEmpty) {
        state = AuthState(
          isLoggedIn: true,
          username: (username != null && username.isNotEmpty) ? username : 'Operator',
          token: token,
          isInitialized: true,
          isLoading: false,
        );
        return;
      }
    } catch (_) {}
    state = const AuthState(isLoggedIn: false, isInitialized: true, isLoading: false);
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final authService = ref.read(authApiServiceProvider);
    final storage = ref.read(tokenStorageProvider);

    final response = await authService.login(username: username, password: password);
    if (response.success && response.token != null) {
      final resolvedUsername = (response.username != null && response.username!.isNotEmpty)
          ? response.username!
          : username;
      await storage.saveToken(response.token!, username: resolvedUsername);
      state = AuthState(
        isLoggedIn: true,
        username: resolvedUsername,
        token: response.token,
        isInitialized: true,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.errorMessage ?? 'Invalid login credentials',
      );
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final authService = ref.read(authApiServiceProvider);
    final storage = ref.read(tokenStorageProvider);

    final response = await authService.register(username: username, password: password);
    if (response.success && response.token != null) {
      final resolvedUsername = (response.username != null && response.username!.isNotEmpty)
          ? response.username!
          : username;
      await storage.saveToken(response.token!, username: resolvedUsername);
      state = AuthState(
        isLoggedIn: true,
        username: resolvedUsername,
        token: response.token,
        isInitialized: true,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.errorMessage ?? 'Registration failed',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    await storage.clear();
    state = const AuthState(isLoggedIn: false, isInitialized: true, isLoading: false);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
