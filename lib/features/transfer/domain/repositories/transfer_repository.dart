import 'dart:io';
import '../entities/remote_file_item.dart';
import '../entities/transfer_task.dart';

abstract class TransferRepository {
  Stream<List<TransferTask>> watchAllTransfers();
  Future<List<TransferTask>> getAllTransfers();
  Future<TransferTask?> getTransfer(String id);

  Future<String> startUpload(File file);
  Future<String> startDownload({
    required String fileUrl,
    required String fileName,
    int? totalSize,
  });

  Future<void> pauseTransfer(String id);
  Future<void> resumeTransfer(String id);
  Future<void> cancelTransfer(String id);
  Future<void> retryTransfer(String id);
  Future<void> clearCompletedTransfers();

  Future<List<RemoteFileItem>> getRemoteFiles();
  Future<bool> deleteRemoteFile(String fileName);
}
