class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://15.232.228.139';
  static const String registerEndpoint = '/api/register';
  static const String tokenEndpoint = '/api/token';
  static const String listFilesEndpoint = '/api/get';
  static const String uploadEndpoint = '/api/upload';
  static const String downloadEndpoint = '/api/get';
  static const String deleteEndpoint = '/api/delete';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(minutes: 5);

  static const int defaultChunkSize = 1024 * 1024; // 1 MB buffer
}
