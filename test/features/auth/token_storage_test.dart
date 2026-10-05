import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/auth/data/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureTokenStorage Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('saves and retrieves token and username correctly', () async {
      final storage = SecureTokenStorage();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUsername(), isNull);

      await storage.saveToken('jwt-access-token-12345', username: 'pos_admin');

      expect(await storage.getToken(), equals('jwt-access-token-12345'));
      expect(await storage.getUsername(), equals('pos_admin'));
    });

    test('loads pre-existing stored token and username', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'persisted-token-999',
        'auth_username': 'cashier_1',
      });

      final storage = SecureTokenStorage();

      expect(await storage.getToken(), equals('persisted-token-999'));
      expect(await storage.getUsername(), equals('cashier_1'));
    });

    test('clears token and username on logout', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-to-delete',
        'auth_username': 'user-to-delete',
      });

      final storage = SecureTokenStorage();
      expect(await storage.getToken(), equals('token-to-delete'));

      await storage.clear();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUsername(), isNull);
    });

    test('saveToken without username updates only token', () async {
      final storage = SecureTokenStorage();
      await storage.saveToken('first-token', username: 'operator');
      await storage.saveToken('second-token');

      expect(await storage.getToken(), equals('second-token'));
      expect(await storage.getUsername(), equals('operator'));
    });
  });

  group('InMemoryTokenStorage Tests', () {
    test('in-memory storage saves, retrieves, and clears', () async {
      final storage = InMemoryTokenStorage();

      expect(await storage.getToken(), isNull);
      expect(await storage.getUsername(), isNull);

      await storage.saveToken('mem-token-123', username: 'mem_user');
      expect(await storage.getToken(), equals('mem-token-123'));
      expect(await storage.getUsername(), equals('mem_user'));

      await storage.clear();
      expect(await storage.getToken(), isNull);
      expect(await storage.getUsername(), isNull);
    });
  });
}
