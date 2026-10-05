import 'dart:io';
import '../../../../core/database/downloaded_file_entity.dart';
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
    int? fileId,
    String? originalName,
  });

  Future<void> pauseTransfer(String id);
  Future<void> resumeTransfer(String id);
  Future<void> cancelTransfer(String id);
  Future<void> retryTransfer(String id);
  Future<void> clearCompletedTransfers();

  Future<List<RemoteFileItem>> getRemoteFiles();
  Future<bool> deleteRemoteFile(String fileName);

  Stream<List<DownloadedFileEntity>> watchDownloadedFiles();
  Future<List<DownloadedFileEntity>> getDownloadedFiles();
  Future<DownloadedFileEntity?> getDownloadedFile(int fileId);
  Future<void> deleteDownloadedFile(int fileId);
}
