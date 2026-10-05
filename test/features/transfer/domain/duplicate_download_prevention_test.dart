import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/core/database/downloaded_file_dao.dart';
import 'package:laan_task/core/database/downloaded_file_entity.dart';
import 'package:laan_task/features/transfer/data/api/transfer_api_service.dart';
import 'package:laan_task/features/transfer/data/local/transfer_local_data_source.dart';
import 'package:laan_task/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:laan_task/features/transfer/data/workers/transfer_worker.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_task.dart';

class InMemoryDownloadedFileDao implements DownloadedFileDao {
  final Map<int, DownloadedFileEntity> _storage = {};
  final _streamController = StreamController<List<DownloadedFileEntity>>.broadcast();

  @override
  Future<void> insertDownloadedFile(DownloadedFileEntity entity) async {
    _storage[entity.fileId] = entity;
    _streamController.add(_storage.values.toList());
  }

  @override
  Future<DownloadedFileEntity?> getDownloadedFileById(int fileId) async {
    return _storage[fileId];
  }

  @override
  Future<DownloadedFileEntity?> getDownloadedFileByName(String fileName) async {
    return _storage.values.where((e) => e.fileName == fileName).firstOrNull;
  }

  @override
  Future<List<DownloadedFileEntity>> getAllDownloadedFiles() async {
    return _storage.values.toList();
  }

  @override
  Future<void> deleteDownloadedFile(int fileId) async {
    _storage.remove(fileId);
    _streamController.add(_storage.values.toList());
  }

  @override
  Future<void> deleteAllDownloadedFiles() async {
    _storage.clear();
    _streamController.add([]);
  }

  @override
  Stream<List<DownloadedFileEntity>> watchAllDownloadedFiles() {
    return _streamController.stream;
  }
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
  final List<String> downloadedIds = [];

  @override
  Future<void> executeDownload(String id) async {
    downloadedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Duplicate Download Prevention & Download Tracking Tests', () {
    late InMemoryDownloadedFileDao dao;
    late FakeLocalDataSource localDataSource;
    late FakeWorker worker;
    late TransferRepositoryImpl repository;
    late Directory tempDir;

    setUp(() async {
      dao = InMemoryDownloadedFileDao();
      localDataSource = FakeLocalDataSource();
      worker = FakeWorker();
      repository = TransferRepositoryImpl(
        apiService: FakeApiService(),
        localDataSource: localDataSource,
        worker: worker,
        downloadedFileDao: dao,
      );
      tempDir = await Directory.systemTemp.createTemp('laan_download_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('allows download when file is not yet downloaded', () async {
      final taskId = await repository.startDownload(
        fileUrl: 'http://example.com/file1.pdf',
        fileName: 'file1.pdf',
        totalSize: 1024,
        fileId: 101,
        originalName: 'My Document.pdf',
      );

      expect(taskId, isNotEmpty);
      expect(localDataSource.tasks.length, equals(1));
      expect(localDataSource.tasks.first.fileId, equals(101));
      expect(localDataSource.tasks.first.fileName, equals('file1.pdf'));
      expect(localDataSource.tasks.first.originalName, equals('My Document.pdf'));
    });

    test('prevents re-download when file is already downloaded and exists on disk', () async {
      // Create a real file on disk
      final localFile = File('${tempDir.path}/downloaded_doc.pdf');
      await localFile.writeAsString('content');

      // Record in downloaded files table
      await dao.insertDownloadedFile(
        DownloadedFileEntity(
          fileId: 202,
          fileName: 'downloaded_doc.pdf',
          originalName: 'Downloaded Doc.pdf',
          localPath: localFile.path,
          fileSize: 7,
          downloadedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Attempting to download again must throw StateError
      expect(
        () => repository.startDownload(
          fileUrl: 'http://example.com/downloaded_doc.pdf',
          fileName: 'downloaded_doc.pdf',
          totalSize: 7,
          fileId: 202,
          originalName: 'Downloaded Doc.pdf',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('File is already downloaded'),
          ),
        ),
      );

      // No new transfer task should have been saved
      expect(localDataSource.tasks.isEmpty, isTrue);
    });

    test('allows re-download if file was previously downloaded but deleted from disk', () async {
      final missingPath = '${tempDir.path}/deleted_by_user.pdf';

      // Insert record in DAO pointing to a path that DOES NOT exist
      await dao.insertDownloadedFile(
        DownloadedFileEntity(
          fileId: 303,
          fileName: 'deleted_by_user.pdf',
          originalName: 'Deleted Doc.pdf',
          localPath: missingPath,
          fileSize: 100,
          downloadedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Attempt to download: should purge stale record and start download
      final taskId = await repository.startDownload(
        fileUrl: 'http://example.com/deleted_by_user.pdf',
        fileName: 'deleted_by_user.pdf',
        fileId: 303,
        originalName: 'Deleted Doc.pdf',
      );

      expect(taskId, isNotEmpty);
      expect(localDataSource.tasks.length, equals(1));
      // Stale record should be deleted from DAO
      final record = await dao.getDownloadedFileById(303);
      expect(record, isNull);
    });

    test('checks duplicate by fileName if fileId is omitted', () async {
      final localFile = File('${tempDir.path}/sales_q1.xlsx');
      await localFile.writeAsString('1,2,3');

      await dao.insertDownloadedFile(
        DownloadedFileEntity(
          fileId: 404,
          fileName: 'sales_q1.xlsx',
          originalName: 'Sales Q1.xlsx',
          localPath: localFile.path,
          fileSize: 5,
          downloadedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      expect(
        () => repository.startDownload(
          fileUrl: 'http://example.com/sales_q1.xlsx',
          fileName: 'sales_q1.xlsx',
          originalName: 'Sales Q1.xlsx',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
