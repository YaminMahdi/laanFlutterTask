import 'transfer_status.dart';
import 'transfer_type.dart';

class TransferTask {
  const TransferTask({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.type,
    required this.status,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.createdAt,
    this.fileUrl,
    this.localPath,
    this.speedBytesPerSecond = 0,
    this.errorMessage,
    this.completedAt,
    this.fileId,
  });

  final String id;
  final String fileName;
  final String originalName;
  final String? fileUrl;
  final String? localPath;
  final TransferType type;
  final TransferStatus status;
  final int bytesTransferred;
  final int totalBytes;
  final int speedBytesPerSecond;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? fileId;

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

  TransferTask copyWith({
    String? id,
    String? fileName,
    String? originalName,
    String? fileUrl,
    String? localPath,
    TransferType? type,
    TransferStatus? status,
    int? bytesTransferred,
    int? totalBytes,
    int? speedBytesPerSecond,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
    int? fileId,
  }) {
    return TransferTask(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      originalName: originalName ?? this.originalName,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      type: type ?? this.type,
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      speedBytesPerSecond: speedBytesPerSecond ?? this.speedBytesPerSecond,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      fileId: fileId ?? this.fileId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          bytesTransferred == other.bytesTransferred &&
          totalBytes == other.totalBytes &&
          speedBytesPerSecond == other.speedBytesPerSecond;

  @override
  int get hashCode =>
      id.hashCode ^
      status.hashCode ^
      bytesTransferred.hashCode ^
      totalBytes.hashCode ^
      speedBytesPerSecond.hashCode;
}
