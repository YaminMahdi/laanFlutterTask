import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/entities/remote_file_item.dart';
import '../../domain/entities/transfer_status.dart';
import '../../domain/entities/transfer_task.dart';
import '../../domain/entities/transfer_type.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../api/transfer_api_service.dart';
import '../local/transfer_local_data_source.dart';
import '../workers/transfer_worker.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl({
    required this.apiService,
    required this.localDataSource,
    required this.worker,
  });

  final TransferApiService apiService;
  final TransferLocalDataSource localDataSource;
  final TransferWorker worker;

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 9000)}';
  }

  @override
  Stream<List<TransferTask>> watchAllTransfers() =>
      localDataSource.watchAllTransfers();

  @override
  Future<List<TransferTask>> getAllTransfers() =>
      localDataSource.getAllTransfers();

  @override
  Future<TransferTask?> getTransfer(String id) =>
      localDataSource.getTransfer(id);

  @override
  Future<String> startUpload(File file) async {
    final id = _generateId();
    final originalName = p.basename(file.path);
    final totalBytes = await file.length();

    final task = TransferTask(
      id: id,
      fileName: originalName,
      originalName: originalName,
      localPath: file.path,
      type: TransferType.upload,
      status: TransferStatus.queued,
      bytesTransferred: 0,
      totalBytes: totalBytes,
      createdAt: DateTime.now(),
    );

    await localDataSource.saveTransfer(task);

    // Run upload asynchronously in background
    unawaited(worker.executeUpload(id));

    return id;
  }

  @override
  Future<String> startDownload({
    required String fileUrl,
    required String fileName,
    int? totalSize,
  }) async {
    final id = _generateId();

    final task = TransferTask(
      id: id,
      fileName: fileName,
      originalName: fileName,
      fileUrl: fileUrl,
      type: TransferType.download,
      status: TransferStatus.queued,
      bytesTransferred: 0,
      totalBytes: totalSize ?? 0,
      createdAt: DateTime.now(),
    );

    await localDataSource.saveTransfer(task);

    // Run download asynchronously in background
    unawaited(worker.executeDownload(id));

    return id;
  }

  @override
  Future<void> pauseTransfer(String id) async {
    await worker.pause(id);
  }

  @override
  Future<void> resumeTransfer(String id) async {
    final task = await localDataSource.getTransfer(id);
    if (task == null) return;

    if (task.type == TransferType.download) {
      unawaited(worker.executeDownload(id));
    } else {
      unawaited(worker.executeUpload(id));
    }
  }

  @override
  Future<void> cancelTransfer(String id) async {
    await worker.cancel(id);
  }

  @override
  Future<void> retryTransfer(String id) async {
    final task = await localDataSource.getTransfer(id);
    if (task == null) return;

    await localDataSource.updateStatus(id, TransferStatus.queued, errorMessage: null);

    if (task.type == TransferType.download) {
      unawaited(worker.executeDownload(id));
    } else {
      unawaited(worker.executeUpload(id));
    }
  }

  @override
  Future<void> clearCompletedTransfers() =>
      localDataSource.clearCompleted();

  @override
  Future<List<RemoteFileItem>> getRemoteFiles() =>
      apiService.getRemoteFiles();

  @override
  Future<bool> deleteRemoteFile(String fileName) =>
      apiService.deleteFile(fileName);
}

void unawaited(Future<void> future) {}
