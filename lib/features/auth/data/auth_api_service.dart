import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class AuthResponse {
  const AuthResponse({
    required this.success,
    this.token,
    this.tokenType,
    this.username,
    this.userId,
    this.errorMessage,
  });

  final bool success;
  final String? token;
  final String? tokenType;
  final String? username;
  final int? userId;
  final String? errorMessage;

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

class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });

      final response = await _dio.post(
        ApiConstants.tokenEndpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        return AuthResponse(success: false, errorMessage: data['error'].toString());
      }
      return AuthResponse(
        success: false,
        errorMessage: e.message ?? 'Login failed. Check your network.',
      );
    }
  }

  Future<AuthResponse> register({
    required String username,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });

      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return AuthResponse.fromJson(data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        return AuthResponse(success: false, errorMessage: data['error'].toString());
      }
      return AuthResponse(
        success: false,
        errorMessage: e.message ?? 'Registration failed.',
      );
    }
  }
}
