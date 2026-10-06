import 'package:freezed_annotation/freezed_annotation.dart';
import 'transfer_status.dart';
import 'transfer_type.dart';

part 'transfer_task.freezed.dart';

@freezed
abstract class TransferTask with _$TransferTask {
  const TransferTask._();

  const factory TransferTask({
    required String id,
    required String fileName,
    required String originalName,
    required TransferType type,
    required TransferStatus status,
    required int bytesTransferred,
    required int totalBytes,
    required DateTime createdAt,
    String? fileUrl,
    String? localPath,
    @Default(0) int speedBytesPerSecond,
    String? errorMessage,
    DateTime? completedAt,
    int? fileId,
  }) = _TransferTask;

  double get progress {
    if (totalBytes <= 0) return 0.0;
    final value = bytesTransferred / totalBytes;
    if (value.isNaN || value.isInfinite) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  int get progressPercentage => (progress * 100).round();

  String get formattedTransferredSize => _formatBytes(bytesTransferred);
  String get formattedTotalSize => _formatBytes(totalBytes);

  String get formattedProgressDetail {
    if (totalBytes <= 0) return formattedTransferredSize;
    return '$formattedTransferredSize of $formattedTotalSize';
  }

  String get formattedSpeed {
    if (speedBytesPerSecond <= 0 || !status.isActive) return '';
    return '${_formatBytes(speedBytesPerSecond)}/s';
  }

  static String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }
}
