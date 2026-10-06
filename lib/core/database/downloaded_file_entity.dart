import 'package:freezed_annotation/freezed_annotation.dart';

part 'downloaded_file_entity.freezed.dart';
part 'downloaded_file_entity.g.dart';

@freezed
abstract class DownloadedFileEntity with _$DownloadedFileEntity {
  const DownloadedFileEntity._();

  const factory DownloadedFileEntity({
    required int fileId,
    required String fileName,
    required String originalName,
    required String localPath,
    required int fileSize,
    required int downloadedAt,
    String? fileType,
  }) = _DownloadedFileEntity;

  factory DownloadedFileEntity.fromJson(Map<String, dynamic> json) =>
      _$DownloadedFileEntityFromJson(json);

  Map<String, dynamic> toMap() => toJson();

  factory DownloadedFileEntity.fromMap(Map<String, dynamic> map) =>
      DownloadedFileEntity.fromJson(map);
}
