import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/storage/public_download_storage.dart';
import '../../domain/entities/transfer_status.dart';
import '../api/transfer_api_service.dart';
import '../../../../core/database/downloaded_file_dao.dart';
import '../../../../core/database/downloaded_file_entity.dart';
import '../local/transfer_local_data_source.dart';

class TransferWorker {
  TransferWorker({
    required this.apiService,
    required this.localDataSource,
    required this.downloadedFileDao,
  });

  final TransferApiService apiService;
  final TransferLocalDataSource localDataSource;
  final DownloadedFileDao downloadedFileDao;

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, bool> _pauseRequested = {};
  final Map<String, int> _lastSpeedUpdateTimes = {};
  final Map<String, int> _lastSpeedUpdateBytes = {};
  final Map<String, int> _lastNotificationTimes = {};

  /// Temporary directory used while downloading.
  ///
  /// We deliberately do NOT download directly into the public Downloads
  /// directory. This makes pause/resume and partial downloads reliable.
  Future<Directory> _getTemporaryDownloadDirectory() async {
    Directory? dir;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    }

    dir ??= await getApplicationSupportDirectory();

    final downloadsDir = Directory(p.join(dir.path, 'downloads'));

    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    return downloadsDir;
  }

  void _calculateSpeed(
    String id,
    int currentBytes,
    Function(int speed) onSpeedCalculated,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final lastTime = _lastSpeedUpdateTimes[id] ?? now;
    final lastBytes = _lastSpeedUpdateBytes[id] ?? currentBytes;

    final timeDelta = now - lastTime;

    if (timeDelta >= 500) {
      final bytesDelta = currentBytes - lastBytes;

      final speed = (bytesDelta / (timeDelta / 1000.0)).round();

      _lastSpeedUpdateTimes[id] = now;
      _lastSpeedUpdateBytes[id] = currentBytes;

      onSpeedCalculated(speed > 0 ? speed : 0);
    }
  }

  void _throttleNotification(String id, String title, int progress, int total) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastNotificationTimes[id] ?? 0;

    if (now - lastTime > 600 || progress == total) {
      _lastNotificationTimes[id] = now;

      final pct = total > 0 ? ((progress / total) * 100).round() : 0;

      NotificationService.instance.showProgressNotification(
        id: id,
        title: title,
        body: '$pct% completed',
        progress: progress,
        maxProgress: total > 0 ? total : 100,
      );
    }
  }

  Future<bool> ensureDownloadPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }
    if (await Permission.storage.isGranted) {
      return true;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> executeDownload(String id) async {
    ensureDownloadPermission();
    final task = await localDataSource.getTransfer(id);

    if (task == null) return;

    final cancelToken = CancelToken();

    _cancelTokens[id] = cancelToken;
    _pauseRequested[id] = false;

    IOSink? sink;

    try {
      final storageDir = await _getTemporaryDownloadDirectory();

      final tempFinalPath = p.join(storageDir.path, task.fileName);

      final partFilePath = '$tempFinalPath.part';
      final partFile = File(partFilePath);

      int startByte = 0;

      if (await partFile.exists()) {
        startByte = await partFile.length();
      }

      await localDataSource.updateStatus(id, TransferStatus.running);

      final responseBody = await apiService.downloadFileStream(
        fileName: task.fileName,
        startByte: startByte,
        cancelToken: cancelToken,
      );

      // ---------------------------------------------------------------
      // Determine total file size
      // ---------------------------------------------------------------

      int totalBytes = task.totalBytes;

      if (totalBytes <= 0) {
        final contentLengthHeader =
            responseBody.headers['content-length']?.firstOrNull;

        if (contentLengthHeader != null) {
          final streamLength = int.tryParse(contentLengthHeader) ?? 0;

          totalBytes = startByte + streamLength;
        }
      }

      // ---------------------------------------------------------------
      // Continue writing the .part file
      // ---------------------------------------------------------------

      sink = partFile.openWrite(mode: FileMode.append);

      int downloadedBytes = startByte;
      int currentSpeed = 0;

      await for (final chunk in responseBody.stream) {
        if (_pauseRequested[id] == true || cancelToken.isCancelled) {
          break;
        }

        sink.add(chunk);

        downloadedBytes += chunk.length;

        _calculateSpeed(id, downloadedBytes, (speed) {
          currentSpeed = speed;
        });

        await localDataSource.updateProgress(
          id,
          downloadedBytes,
          totalBytes,
          currentSpeed,
        );

        _throttleNotification(
          id,
          'Downloading ${task.originalName}',
          downloadedBytes,
          totalBytes,
        );
      }

      await sink.flush();
      await sink.close();
      sink = null;

      // ---------------------------------------------------------------
      // Paused
      // ---------------------------------------------------------------

      if (_pauseRequested[id] == true) {
        await localDataSource.updateStatus(id, TransferStatus.paused);

        await NotificationService.instance.cancelNotification(id);

        return;
      }

      // ---------------------------------------------------------------
      // Cancelled
      // ---------------------------------------------------------------

      if (cancelToken.isCancelled) {
        await localDataSource.updateStatus(id, TransferStatus.cancelled);

        await NotificationService.instance.cancelNotification(id);

        return;
      }

      // ---------------------------------------------------------------
      // Make sure download is complete
      // ---------------------------------------------------------------

      final actualFileSize = await partFile.length();

      if (totalBytes > 0 && actualFileSize < totalBytes) {
        throw Exception(
          'Download incomplete. '
          'Expected $totalBytes bytes but received $actualFileSize bytes.',
        );
      }

      // ---------------------------------------------------------------
      // Move/copy to PUBLIC Downloads
      // ---------------------------------------------------------------

      final publicFile = await PublicDownloadStorage.moveToPublicDownloads(
        sourcePath: partFile.path,
        fileName: task.fileName,
      );

      // ---------------------------------------------------------------
      // Database
      // ---------------------------------------------------------------

      await localDataSource.updateStatus(
        id,
        TransferStatus.completed,
        completedAt: DateTime.now(),
        localPath: publicFile.path,
      );

      // ---------------------------------------------------------------
      // Resolve remote file ID
      // ---------------------------------------------------------------

      int? fileId = task.fileId;

      if (fileId == null) {
        try {
          final remoteFiles = await apiService.getRemoteFiles();

          fileId = remoteFiles
              .where((f) => f.name == task.fileName)
              .firstOrNull
              ?.id;
        } catch (_) {}
      }

      final resolvedId = fileId ?? task.fileName.hashCode.abs();

      final finalFileSize = publicFile.size;

      await downloadedFileDao.insertDownloadedFile(
        DownloadedFileEntity(
          fileId: resolvedId,
          fileName: task.fileName,
          originalName: task.originalName,
          localPath: publicFile.path,
          fileSize: finalFileSize,
          downloadedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // ---------------------------------------------------------------
      // Completion notification
      // ---------------------------------------------------------------

      await NotificationService.instance.showCompletionNotification(
        id: id,
        title: 'Download Complete',
        body: '${task.originalName} saved to Downloads. Tap to open.',
        payload: publicFile.path,
      );
    } on DioException catch (e) {
      await sink?.flush();
      await sink?.close();

      if (CancelToken.isCancel(e)) {
        if (_pauseRequested[id] == true) {
          await localDataSource.updateStatus(id, TransferStatus.paused);
        } else {
          await localDataSource.updateStatus(id, TransferStatus.cancelled);
        }

        await NotificationService.instance.cancelNotification(id);
      } else {
        final message = e.message ?? 'Download failed due to network error.';

        await localDataSource.updateStatus(
          id,
          TransferStatus.failed,
          errorMessage: message,
        );

        await NotificationService.instance.showErrorNotification(
          id: id,
          title: 'Download Failed',
          body: message,
        );
      }
    } catch (e) {
      await sink?.flush();
      await sink?.close();

      final message = e.toString();

      await localDataSource.updateStatus(
        id,
        TransferStatus.failed,
        errorMessage: message,
      );

      await NotificationService.instance.showErrorNotification(
        id: id,
        title: 'Download Failed',
        body: message,
      );
    } finally {
      _cancelTokens.remove(id);
      _pauseRequested.remove(id);
      _lastSpeedUpdateTimes.remove(id);
      _lastSpeedUpdateBytes.remove(id);
      _lastNotificationTimes.remove(id);
    }
  }

  Future<void> executeUpload(String id) async {
    final task = await localDataSource.getTransfer(id);

    if (task == null || task.localPath == null) {
      return;
    }

    final file = File(task.localPath!);

    if (!await file.exists()) {
      await localDataSource.updateStatus(
        id,
        TransferStatus.failed,
        errorMessage: 'Local file no longer exists at ${task.localPath}',
      );

      return;
    }

    if (!ApiConstants.isAllowedUploadExtension(task.fileName)) {
      await localDataSource.updateStatus(
        id,
        TransferStatus.failed,
        errorMessage: ApiConstants.fileTypeNotAllowedMessage,
      );

      await NotificationService.instance.showErrorNotification(
        id: id,
        title: 'Upload Failed',
        body: ApiConstants.fileTypeNotAllowedMessage,
      );

      return;
    }

    final cancelToken = CancelToken();

    _cancelTokens[id] = cancelToken;
    _pauseRequested[id] = false;

    await localDataSource.updateStatus(id, TransferStatus.running);

    int currentSpeed = 0;

    try {
      final response = await apiService.uploadFile(
        file: file,
        cancelToken: cancelToken,
        onSendProgress: (sent, total) async {
          _calculateSpeed(id, sent, (speed) {
            currentSpeed = speed;
          });

          await localDataSource.updateProgress(id, sent, total, currentSpeed);

          _throttleNotification(
            id,
            'Uploading ${task.originalName}',
            sent,
            total,
          );
        },
      );

      if (response['success'] == false) {
        final serverError =
            response['error']?.toString() ?? 'Upload rejected by server';

        await localDataSource.updateStatus(
          id,
          TransferStatus.failed,
          errorMessage: serverError,
        );

        await NotificationService.instance.showErrorNotification(
          id: id,
          title: 'Upload Failed',
          body: serverError,
        );

        return;
      }

      String? uploadedUrl;

      if (response['file'] is Map<String, dynamic>) {
        final fileData = response['file'] as Map<String, dynamic>;

        uploadedUrl = fileData['url'] as String?;
      }

      await localDataSource.updateStatus(
        id,
        TransferStatus.completed,
        completedAt: DateTime.now(),
        fileUrl: uploadedUrl,
      );

      await NotificationService.instance.showCompletionNotification(
        id: id,
        title: 'Upload Complete',
        body: '${task.originalName} uploaded successfully.',
        payload: id,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (_pauseRequested[id] == true) {
          await localDataSource.updateStatus(id, TransferStatus.paused);
        } else {
          await localDataSource.updateStatus(id, TransferStatus.cancelled);
        }

        await NotificationService.instance.cancelNotification(id);
      } else {
        final data = e.response?.data;

        final message = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : (e.message ?? 'Upload failed due to network error.');

        await localDataSource.updateStatus(
          id,
          TransferStatus.failed,
          errorMessage: message,
        );

        await NotificationService.instance.showErrorNotification(
          id: id,
          title: 'Upload Failed',
          body: message,
        );
      }
    } catch (e) {
      final message = e.toString();

      await localDataSource.updateStatus(
        id,
        TransferStatus.failed,
        errorMessage: message,
      );

      await NotificationService.instance.showErrorNotification(
        id: id,
        title: 'Upload Failed',
        body: message,
      );
    } finally {
      _cancelTokens.remove(id);
      _pauseRequested.remove(id);
      _lastSpeedUpdateTimes.remove(id);
      _lastSpeedUpdateBytes.remove(id);
      _lastNotificationTimes.remove(id);
    }
  }

  Future<void> pause(String id) async {
    _pauseRequested[id] = true;

    _cancelTokens[id]?.cancel('Paused by user');
  }

  Future<void> cancel(String id) async {
    _pauseRequested[id] = false;

    _cancelTokens[id]?.cancel('Cancelled by user');

    await localDataSource.updateStatus(id, TransferStatus.cancelled);

    await NotificationService.instance.cancelNotification(id);
  }

  bool isTransferActive(String id) {
    return _cancelTokens.containsKey(id);
  }
}
