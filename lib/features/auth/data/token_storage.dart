import 'dart:async';

abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token, {String? username});
  Future<String?> getUsername();
  Future<void> clear();
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
