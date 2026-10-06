// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloaded_file_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DownloadedFileEntity _$DownloadedFileEntityFromJson(
  Map<String, dynamic> json,
) => _DownloadedFileEntity(
  fileId: (json['fileId'] as num).toInt(),
  fileName: json['fileName'] as String,
  originalName: json['originalName'] as String,
  localPath: json['localPath'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  downloadedAt: (json['downloadedAt'] as num).toInt(),
  fileType: json['fileType'] as String?,
);

Map<String, dynamic> _$DownloadedFileEntityToJson(
  _DownloadedFileEntity instance,
) => <String, dynamic>{
  'fileId': instance.fileId,
  'fileName': instance.fileName,
  'originalName': instance.originalName,
  'localPath': instance.localPath,
  'fileSize': instance.fileSize,
  'downloadedAt': instance.downloadedAt,
  'fileType': instance.fileType,
};
