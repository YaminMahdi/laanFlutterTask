import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/remote_file_item.dart';

class TransferApiService {
  TransferApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required ProgressCallback onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final fileName = file.uri.pathSegments.last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      ApiConstants.uploadEndpoint,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  Future<ResponseBody> downloadFileStream({
    required String fileName,
    int startByte = 0,
    CancelToken? cancelToken,
  }) async {
    final headers = <String, dynamic>{};
    if (startByte > 0) {
      headers['Range'] = 'bytes=$startByte-';
    }

    final response = await _dio.get<ResponseBody>(
      ApiConstants.downloadEndpoint,
      queryParameters: {'file': fileName},
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
    );

    final body = response.data;
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response stream received from server',
      );
    }
    return body;
  }

  Future<List<RemoteFileItem>> getRemoteFiles() async {
    final response = await _dio.get(ApiConstants.listFilesEndpoint);
    final data = response.data as Map<String, dynamic>;

    if (data['success'] == true && data['files'] is List) {
      final fileList = data['files'] as List;
      return fileList
          .map((item) => RemoteFileItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> deleteFile(String fileName) async {
    final response = await _dio.delete(
      ApiConstants.deleteEndpoint,
      queryParameters: {'file': fileName},
    );
    final data = response.data as Map<String, dynamic>;
    return data['success'] == true;
  }
}
