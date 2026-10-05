import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/transfer_status.dart';
import '../api/transfer_api_service.dart';
import '../local/transfer_local_data_source.dart';

class TransferWorker {
  TransferWorker({
    required this.apiService,
    required this.localDataSource,
  });

  final TransferApiService apiService;
  final TransferLocalDataSource localDataSource;

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, bool> _pauseRequested = {};
  final Map<String, int> _lastSpeedUpdateTimes = {};
  final Map<String, int> _lastSpeedUpdateBytes = {};
  final Map<String, int> _lastNotificationTimes = {};

  Future<Directory> _getStorageDirectory() async {
    Directory? dir;
    if (Platform.isAndroid) {
      try {
        dir = await getExternalStorageDirectory();
      } catch (_) {}
    }
    dir ??= await getApplicationDocumentsDirectory();
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

  void _throttleNotification(
    String id,
    String title,
    int progress,
    int total,
  ) {
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

  Future<void> executeDownload(String id) async {
    final task = await localDataSource.getTransfer(id);
    if (task == null) return;

    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;
    _pauseRequested[id] = false;

    final storageDir = await _getStorageDirectory();
    final finalFilePath = p.join(storageDir.path, task.fileName);
    final partFilePath = '$finalFilePath.part';
    final partFile = File(partFilePath);

    int startByte = 0;
    if (await partFile.exists()) {
      startByte = await partFile.length();
    }

    await localDataSource.updateStatus(id, TransferStatus.running);

    IOSink? sink;
    try {
      final responseBody = await apiService.downloadFileStream(
        fileName: task.fileName,
        startByte: startByte,
        cancelToken: cancelToken,
      );

      // Determine total bytes
      int totalBytes = task.totalBytes;
      if (totalBytes <= 0) {
        final contentLengthHeader =
            responseBody.headers['content-length']?.firstOrNull;
        if (contentLengthHeader != null) {
          final streamLength = int.tryParse(contentLengthHeader) ?? 0;
          totalBytes = startByte + streamLength;
        }
      }

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

      if (_pauseRequested[id] == true) {
        await localDataSource.updateStatus(id, TransferStatus.paused);
        await NotificationService.instance.cancelNotification(id);
        return;
      }

      // Transfer completed: atomically rename .part to final
      if (await File(finalFilePath).exists()) {
        await File(finalFilePath).delete();
      }
      await partFile.rename(finalFilePath);

      await localDataSource.updateStatus(
        id,
        TransferStatus.completed,
        completedAt: DateTime.now(),
        localPath: finalFilePath,
      );

      await NotificationService.instance.showCompletionNotification(
        id: id,
        title: 'Download Complete',
        body: '${task.originalName} saved to storage.',
        payload: finalFilePath,
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
    if (task == null || task.localPath == null) return;

    final file = File(task.localPath!);
    if (!await file.exists()) {
      await localDataSource.updateStatus(
        id,
        TransferStatus.failed,
        errorMessage: 'Local file no longer exists at ${task.localPath}',
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
        final message = e.message ?? 'Upload failed due to network error.';
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

  bool isTransferActive(String id) => _cancelTokens.containsKey(id);
}
