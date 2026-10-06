import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/auth/data/token_storage.dart';
import 'package:laan_task/features/auth/presentation/auth_notifier.dart';
import 'package:laan_task/features/transfer/presentation/providers/transfer_providers.dart';

void main() {
  group('AuthNotifier Tests', () {
    test('initializes as logged out when token storage is empty', () async {
      final storage = InMemoryTokenStorage();

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      // Trigger build
      final state = container.read(authNotifierProvider);
      expect(state.isLoggedIn, isFalse);

      // Wait for any async initialization
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final updatedState = container.read(authNotifierProvider);
      expect(updatedState.isLoggedIn, isFalse);
      expect(updatedState.isInitialized, isTrue);
    });

    test('restores saved session on initialization when token exists in storage', () async {
      final storage = InMemoryTokenStorage();
      await storage.saveToken('saved-session-token-456', username: 'pos_cashier');

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      container.read(authNotifierProvider);

      // Wait for async credential initialization
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(authNotifierProvider);
      expect(state.isLoggedIn, isTrue);
      expect(state.token, equals('saved-session-token-456'));
      expect(state.username, equals('pos_cashier'));
      expect(state.isInitialized, isTrue);
    });

    test('logout clears storage and resets auth state', () async {
      final storage = InMemoryTokenStorage();
      await storage.saveToken('active-token', username: 'active_user');

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      container.read(authNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(authNotifierProvider).isLoggedIn, isTrue);

      await container.read(authNotifierProvider.notifier).logout();

      final state = container.read(authNotifierProvider);
      expect(state.isLoggedIn, isFalse);
      expect(await storage.getToken(), isNull);
      expect(await storage.getUsername(), isNull);
    });

    test('clearError resets error message on demand', () async {
      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authNotifierProvider.notifier);
      // Set an initial state with an error
      notifier.state = notifier.state.copyWith(errorMessage: 'Invalid credentials');
      expect(container.read(authNotifierProvider).errorMessage, equals('Invalid credentials'));

      notifier.clearError();
      expect(container.read(authNotifierProvider).errorMessage, isNull);
    });
  });
}
