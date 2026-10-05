class TransferEntity {
  const TransferEntity({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.transferType,
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
  final String transferType; // 'upload' or 'download'
  final String status; // 'queued', 'running', 'paused', 'completed', 'failed', 'cancelled'
  final int bytesTransferred;
  final int totalBytes;
  final int speedBytesPerSecond;
  final String? errorMessage;
  final int createdAt; // epoch milliseconds
  final int? completedAt; // epoch milliseconds
  final int? fileId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'originalName': originalName,
      'fileUrl': fileUrl,
      'localPath': localPath,
      'transferType': transferType,
      'status': status,
      'bytesTransferred': bytesTransferred,
      'totalBytes': totalBytes,
      'speedBytesPerSecond': speedBytesPerSecond,
      'errorMessage': errorMessage,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'fileId': fileId,
    };
  }

  factory TransferEntity.fromMap(Map<String, dynamic> map) {
    return TransferEntity(
      id: map['id'] as String,
      fileName: map['fileName'] as String,
      originalName: map['originalName'] as String,
      fileUrl: map['fileUrl'] as String?,
      localPath: map['localPath'] as String?,
      transferType: map['transferType'] as String,
      status: map['status'] as String,
      bytesTransferred: (map['bytesTransferred'] as num?)?.toInt() ?? 0,
      totalBytes: (map['totalBytes'] as num?)?.toInt() ?? 0,
      speedBytesPerSecond: (map['speedBytesPerSecond'] as num?)?.toInt() ?? 0,
      errorMessage: map['errorMessage'] as String?,
      createdAt: (map['createdAt'] as num).toInt(),
      completedAt: (map['completedAt'] as num?)?.toInt(),
      fileId: (map['fileId'] as num?)?.toInt(),
    );
  }

  TransferEntity copyWith({
    String? id,
    String? fileName,
    String? originalName,
    String? fileUrl,
    String? localPath,
    String? transferType,
    String? status,
    int? bytesTransferred,
    int? totalBytes,
    int? speedBytesPerSecond,
    String? errorMessage,
    int? createdAt,
    int? completedAt,
    int? fileId,
  }) {
    return TransferEntity(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      originalName: originalName ?? this.originalName,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      transferType: transferType ?? this.transferType,
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
}
