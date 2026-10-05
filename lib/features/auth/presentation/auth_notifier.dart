import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transfer/presentation/providers/transfer_providers.dart';

class AuthState {
  const AuthState({
    required this.isLoggedIn,
    this.username,
    this.token,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoggedIn;
  final String? username;
  final String? token;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoggedIn,
    String? username,
    String? token,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check pre-seeded / stored credentials
    final storage = ref.watch(tokenStorageProvider);
    _initializeAuth(storage);
    return const AuthState(isLoggedIn: false);
  }

  Future<void> _initializeAuth(dynamic storage) async {
    final token = await storage.getToken();
    final username = await storage.getUsername();
    if (token != null) {
      state = state.copyWith(isLoggedIn: true, username: username ?? 'mahdi', token: token);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final authService = ref.read(authApiServiceProvider);
    final storage = ref.read(tokenStorageProvider);

    final response = await authService.login(username: username, password: password);
    if (response.success && response.token != null) {
      await storage.saveToken(response.token!, username: response.username ?? username);
      state = AuthState(
        isLoggedIn: true,
        username: response.username ?? username,
        token: response.token,
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    final authService = ref.read(authApiServiceProvider);
    final storage = ref.read(tokenStorageProvider);

    final response = await authService.register(username: username, password: password);
    if (response.success && response.token != null) {
      await storage.saveToken(response.token!, username: response.username ?? username);
      state = AuthState(
        isLoggedIn: true,
        username: response.username ?? username,
        token: response.token,
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
    state = const AuthState(isLoggedIn: false);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
