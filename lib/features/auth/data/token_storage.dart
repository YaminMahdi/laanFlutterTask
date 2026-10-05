import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token, {String? username});
  Future<String?> getUsername();
  Future<void> clear();
}

/// Secure token storage backed by [FlutterSecureStorage] for persistent
/// encrypted credential and token storage across app restarts.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
            );

  final FlutterSecureStorage _storage;
  String? _cachedToken;
  String? _cachedUsername;

  static const String _keyToken = 'auth_token';
  static const String _keyUsername = 'auth_username';

  @override
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      _cachedToken = await _storage.read(key: _keyToken);
      return _cachedToken;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token, {String? username}) async {
    _cachedToken = token;
    await _storage.write(key: _keyToken, value: token);
    if (username != null) {
      _cachedUsername = username;
      await _storage.write(key: _keyUsername, value: username);
    }
  }

  @override
  Future<String?> getUsername() async {
    if (_cachedUsername != null) return _cachedUsername;
    try {
      _cachedUsername = await _storage.read(key: _keyUsername);
      return _cachedUsername;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    _cachedToken = null;
    _cachedUsername = null;
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyUsername);
    } catch (_) {}
  }
}

class InMemoryTokenStorage implements TokenStorage {
  String? _token;
  String? _username;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token, {String? username}) async {
    _token = token;
    if (username != null) _username = username;
  }

  @override
  Future<String?> getUsername() async => _username;

  @override
  Future<void> clear() async {
    _token = null;
    _username = null;
  }
}
