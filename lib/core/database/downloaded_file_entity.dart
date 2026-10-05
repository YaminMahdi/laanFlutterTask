class DownloadedFileEntity {
  const DownloadedFileEntity({
    required this.fileId,
    required this.fileName,
    required this.originalName,
    required this.localPath,
    required this.fileSize,
    required this.downloadedAt,
    this.fileType,
  });

  final int fileId;
  final String fileName;
  final String originalName;
  final String localPath;
  final int fileSize;
  final int downloadedAt; // epoch milliseconds
  final String? fileType;

  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'originalName': originalName,
      'localPath': localPath,
      'fileSize': fileSize,
      'fileType': fileType,
      'downloadedAt': downloadedAt,
    };
  }

  factory DownloadedFileEntity.fromMap(Map<String, dynamic> map) {
    return DownloadedFileEntity(
      fileId: (map['fileId'] as num).toInt(),
      fileName: map['fileName'] as String,
      originalName: map['originalName'] as String,
      localPath: map['localPath'] as String,
      fileSize: (map['fileSize'] as num).toInt(),
      fileType: map['fileType'] as String?,
      downloadedAt: (map['downloadedAt'] as num).toInt(),
    );
  }

  DownloadedFileEntity copyWith({
    int? fileId,
    String? fileName,
    String? originalName,
    String? localPath,
    int? fileSize,
    String? fileType,
    int? downloadedAt,
  }) {
    return DownloadedFileEntity(
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      originalName: originalName ?? this.originalName,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedFileEntity &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId &&
          fileName == other.fileName &&
          localPath == other.localPath &&
          fileSize == other.fileSize;

  @override
  int get hashCode =>
      fileId.hashCode ^
      fileName.hashCode ^
      localPath.hashCode ^
      fileSize.hashCode;
}
