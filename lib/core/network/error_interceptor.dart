import 'package:dio/dio.dart';

sealed class TransferFailure implements Exception {
  const TransferFailure(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkFailure extends TransferFailure {
  const NetworkFailure([super.message = 'No network connection. Please check your network.']);
}

class TimeoutFailure extends TransferFailure {
  const TimeoutFailure([super.message = 'The transfer connection timed out.']);
}

class ServerFailure extends TransferFailure {
  const ServerFailure({required String message, int? statusCode})
      : super(message, statusCode);
}

class AuthenticationFailure extends TransferFailure {
  const AuthenticationFailure([super.message = 'Authentication failed. Please log in again.', super.statusCode = 401]);
}

class FileNotFoundFailure extends TransferFailure {
  const FileNotFoundFailure([super.message = 'The requested file was not found.', super.statusCode = 404]);
}

class StorageFailure extends TransferFailure {
  const StorageFailure({required String message}) : super(message);
}

class CancelledFailure extends TransferFailure {
  const CancelledFailure([super.message = 'Transfer cancelled by user.']);
}

class UnknownFailure extends TransferFailure {
  const UnknownFailure([super.message = 'An unexpected transfer error occurred.']);
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    TransferFailure failure;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        failure = const TimeoutFailure();
        break;

      case DioExceptionType.connectionError:
        failure = const NetworkFailure();
        break;

      case DioExceptionType.cancel:
        failure = const CancelledFailure();
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        String errorMessage = 'Server error occurred.';

        final responseData = err.response?.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['error'] != null) {
            errorMessage = responseData['error'].toString();
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          }
        }

        if (statusCode == 401) {
          failure = AuthenticationFailure(errorMessage, statusCode);
        } else if (statusCode == 404) {
          failure = FileNotFoundFailure(errorMessage, statusCode);
        } else {
          failure = ServerFailure(message: errorMessage, statusCode: statusCode);
        }
        break;

      default:
        failure = UnknownFailure(err.message ?? 'Unknown network error.');
        break;
    }

    final modifiedException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: failure,
      message: failure.message,
    );

    handler.next(modifiedException);
  }
}
