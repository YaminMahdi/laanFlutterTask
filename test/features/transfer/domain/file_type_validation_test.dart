import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/core/constants/api_constants.dart';
import 'package:laan_task/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:laan_task/features/transfer/data/local/transfer_local_data_source.dart';
import 'package:laan_task/features/transfer/data/api/transfer_api_service.dart';
import 'package:laan_task/features/transfer/data/workers/transfer_worker.dart';
import 'package:laan_task/core/database/downloaded_file_dao.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_task.dart';

class FakeDownloadedFileDao implements DownloadedFileDao {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLocalDataSource implements TransferLocalDataSource {
  final List<TransferTask> tasks = [];

  @override
  Future<void> saveTransfer(TransferTask task) async {
    tasks.add(task);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeApiService implements TransferApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWorker implements TransferWorker {
  @override
  Future<void> executeUpload(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Upload File Type Validation Tests', () {
    const allowed = [
      'jpg', 'jpeg', 'png', 'gif', 'webp',
      'pdf', 'txt', 'csv', 'doc', 'docx', 'xls', 'xlsx', 'zip', 'json',
      'mp4', 'mov', 'mkv', 'webm', 'avi',
      'mp3', 'wav',
    ];

    test('validates all 21 allowed extensions correctly', () {
      expect(ApiConstants.allowedUploadExtensions, equals(allowed));

      for (final ext in allowed) {
        expect(ApiConstants.isAllowedUploadExtension(ext), isTrue,
            reason: 'Extension $ext should be allowed');
        expect(ApiConstants.isAllowedUploadExtension('sample.$ext'), isTrue,
            reason: 'Filename sample.$ext should be allowed');
        expect(ApiConstants.isAllowedUploadExtension('/path/to/my_file.$ext'), isTrue,
            reason: 'Full path /path/to/my_file.$ext should be allowed');
      }
    });

    test('is case-insensitive for file extensions', () {
      expect(ApiConstants.isAllowedUploadExtension('PRODUCT_IMAGE.JPG'), isTrue);
      expect(ApiConstants.isAllowedUploadExtension('REPORT.PDF'), isTrue);
      expect(ApiConstants.isAllowedUploadExtension('catalog.CSV'), isTrue);
      expect(ApiConstants.isAllowedUploadExtension('archive.ZIP'), isTrue);
      expect(ApiConstants.isAllowedUploadExtension('video.MP4'), isTrue);
    });

    test('rejects disallowed file extensions', () {
      const disallowed = [
        'exe', 'apk', 'bin', 'dmg', 'sh', 'php', 'js', 'html', 'iso', 'py', 'bat'
      ];

      for (final ext in disallowed) {
        expect(ApiConstants.isAllowedUploadExtension(ext), isFalse,
            reason: 'Extension $ext should be rejected');
        expect(ApiConstants.isAllowedUploadExtension('dangerous_file.$ext'), isFalse,
            reason: 'Filename dangerous_file.$ext should be rejected');
        expect(ApiConstants.isAllowedUploadExtension('/tmp/upload.$ext'), isFalse,
            reason: 'Full path /tmp/upload.$ext should be rejected');
      }
    });

    test('rejects files without extensions', () {
      expect(ApiConstants.isAllowedUploadExtension('file_without_ext'), isFalse);
      expect(ApiConstants.isAllowedUploadExtension(''), isFalse);
    });

    test('exact error message matches server specification', () {
      expect(
        ApiConstants.fileTypeNotAllowedMessage,
        equals(
          'File type not allowed (allowed: jpg, jpeg, png, gif, webp, pdf, txt, csv, doc, docx, xls, xlsx, zip, json, mp4, mov, mkv, webm, avi, mp3, wav)',
        ),
      );
    });

    test('startUpload throws ArgumentError when file type is not allowed', () async {
      final repo = TransferRepositoryImpl(
        apiService: FakeApiService(),
        localDataSource: FakeLocalDataSource(),
        worker: FakeWorker(),
        downloadedFileDao: FakeDownloadedFileDao(),
      );

      final unallowedFile = File('malicious.exe');
      expect(
        () => repo.startUpload(unallowedFile),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            ApiConstants.fileTypeNotAllowedMessage,
          ),
        ),
      );
    });

    test('startUpload succeeds when file type is allowed', () async {
      final local = FakeLocalDataSource();
      final repo = TransferRepositoryImpl(
        apiService: FakeApiService(),
        localDataSource: local,
        worker: FakeWorker(),
        downloadedFileDao: FakeDownloadedFileDao(),
      );

      // Create a temporary allowed file
      final tempFile = File('${Directory.systemTemp.path}/test_catalog.csv');
      await tempFile.writeAsString('sku,price\n123,9.99');
      addTearDown(() async {
        if (await tempFile.exists()) await tempFile.delete();
      });

      final taskId = await repo.startUpload(tempFile);
      expect(taskId, isNotEmpty);
      expect(local.tasks.length, equals(1));
      expect(local.tasks.first.originalName, equals('test_catalog.csv'));
    });
  });
}
