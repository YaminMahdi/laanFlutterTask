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

  /// Allowed upload file extensions matching backend validation:
  /// (allowed: jpg, jpeg, png, gif, webp, pdf, txt, csv, doc, docx, xls, xlsx, zip, json, mp4, mov, mkv, webm, avi, mp3, wav)
  static const List<String> allowedUploadExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp',
    'pdf', 'txt', 'csv', 'doc', 'docx', 'xls', 'xlsx', 'zip', 'json',
    'mp4', 'mov', 'mkv', 'webm', 'avi', 'mp3', 'wav'
  ];

  static const String fileTypeNotAllowedMessage =
      'File type not allowed (allowed: jpg, jpeg, png, gif, webp, pdf, txt, csv, doc, docx, xls, xlsx, zip, json, mp4, mov, mkv, webm, avi, mp3, wav)';

  static bool isAllowedUploadExtension(String filePathOrExtension) {
    var ext = filePathOrExtension.trim().toLowerCase();
    if (ext.contains('.')) {
      ext = ext.split('.').last;
    }
    return allowedUploadExtensions.contains(ext);
  }
}

