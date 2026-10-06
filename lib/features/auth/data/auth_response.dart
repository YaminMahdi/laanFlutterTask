import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response.freezed.dart';

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    String? token,
    @JsonKey(name: 'token_type') String? tokenType,
    String? username,
    @JsonKey(name: 'user_id') int? userId,
    String? errorMessage,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final user = json['user'] as Map<String, dynamic>?;
      return AuthResponse(
        success: true,
        token: json['token'] as String?,
        tokenType: json['token_type'] as String?,
        username: user?['username'] as String?,
        userId: user?['id'] as int?,
      );
    } else {
      return AuthResponse(
        success: false,
        errorMessage: json['error'] as String? ?? 'Authentication failed',
      );
    }
  }
}
