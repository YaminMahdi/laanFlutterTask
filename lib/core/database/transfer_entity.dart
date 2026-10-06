import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_entity.freezed.dart';
part 'transfer_entity.g.dart';

@freezed
abstract class TransferEntity with _$TransferEntity {
  const TransferEntity._();

  const factory TransferEntity({
    required String id,
    required String fileName,
    required String originalName,
    required String transferType,
    required String status,
    required int bytesTransferred,
    required int totalBytes,
    required int createdAt,
    String? fileUrl,
    String? localPath,
    @Default(0) int speedBytesPerSecond,
    String? errorMessage,
    int? completedAt,
    int? fileId,
  }) = _TransferEntity;

  factory TransferEntity.fromJson(Map<String, dynamic> json) =>
      _$TransferEntityFromJson(json);

  Map<String, dynamic> toMap() => toJson();

  factory TransferEntity.fromMap(Map<String, dynamic> map) =>
      TransferEntity.fromJson(map);
}
