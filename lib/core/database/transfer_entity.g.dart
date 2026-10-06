// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransferEntity _$TransferEntityFromJson(Map<String, dynamic> json) =>
    _TransferEntity(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      originalName: json['originalName'] as String,
      transferType: json['transferType'] as String,
      status: json['status'] as String,
      bytesTransferred: (json['bytesTransferred'] as num).toInt(),
      totalBytes: (json['totalBytes'] as num).toInt(),
      createdAt: (json['createdAt'] as num).toInt(),
      fileUrl: json['fileUrl'] as String?,
      localPath: json['localPath'] as String?,
      speedBytesPerSecond: (json['speedBytesPerSecond'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      completedAt: (json['completedAt'] as num?)?.toInt(),
      fileId: (json['fileId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransferEntityToJson(_TransferEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'originalName': instance.originalName,
      'transferType': instance.transferType,
      'status': instance.status,
      'bytesTransferred': instance.bytesTransferred,
      'totalBytes': instance.totalBytes,
      'createdAt': instance.createdAt,
      'fileUrl': instance.fileUrl,
      'localPath': instance.localPath,
      'speedBytesPerSecond': instance.speedBytesPerSecond,
      'errorMessage': instance.errorMessage,
      'completedAt': instance.completedAt,
      'fileId': instance.fileId,
    };
