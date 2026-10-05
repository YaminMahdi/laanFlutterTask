import 'dart:async';

abstract class TokenStorage {
  Future<String?> getToken();
  Future<void> saveToken(String token, {String? username});
  Future<String?> getUsername();
  Future<void> clear();
}

class InMemoryTokenStorage implements TokenStorage {
  // Pre-seed with the provided assessment token / credentials
  String? _token =
      'eyJ1aWQiOjksInVzZXIiOiJtYWhkaSIsImV4cCI6MTc5MTI0NzM0OX0.MjzgE_6ghBDHAXRyrj_yoFZ6G_fU08OPbmL0wlcja2M';
  String? _username = 'mahdi';

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
