import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import 'auth_response.dart';

export 'auth_response.dart';

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
