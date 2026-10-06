// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_file_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteFileItem _$RemoteFileItemFromJson(Map<String, dynamic> json) =>
    _RemoteFileItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      originalName: _readOriginalName(json, 'original_name') as String,
      size: (json['size'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'application/octet-stream',
      uploadedAt: _parseDateTime(json['uploaded_at']),
      url: json['url'] as String,
    );

Map<String, dynamic> _$RemoteFileItemToJson(_RemoteFileItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'original_name': instance.originalName,
      'size': instance.size,
      'type': instance.type,
      'uploaded_at': instance.uploadedAt.toIso8601String(),
      'url': instance.url,
    };
