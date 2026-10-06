import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_file_item.freezed.dart';
part 'remote_file_item.g.dart';

Object? _readOriginalName(Map json, String key) =>
    json['original_name'] ?? json['name'];

DateTime _parseDateTime(dynamic val) {
  if (val is String) {
    return DateTime.tryParse(val) ?? DateTime.now();
  }
  return DateTime.now();
}

@freezed
abstract class RemoteFileItem with _$RemoteFileItem {
  const RemoteFileItem._();

  const factory RemoteFileItem({
    required int id,
    required String name,
    @JsonKey(name: 'original_name', readValue: _readOriginalName)
    required String originalName,
    @Default(0) int size,
    @Default('application/octet-stream') String type,
    @JsonKey(name: 'uploaded_at', fromJson: _parseDateTime)
    required DateTime uploadedAt,
    required String url,
  }) = _RemoteFileItem;

  factory RemoteFileItem.fromJson(Map<String, dynamic> json) =>
      _$RemoteFileItemFromJson(json);

  bool get isImage =>
      type.startsWith('image/') ||
      originalName.endsWith('.jpg') ||
      originalName.endsWith('.jpeg') ||
      originalName.endsWith('.png') ||
      originalName.endsWith('.webp');

  bool get isVideo =>
      type.startsWith('video/') ||
      originalName.endsWith('.mp4') ||
      originalName.endsWith('.mkv') ||
      originalName.endsWith('.mov');

  bool get isCsv =>
      type.contains('csv') || originalName.toLowerCase().endsWith('.csv');

  String get formattedSize {
    if (size <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double s = size.toDouble();
    while (s >= 1024 && i < suffixes.length - 1) {
      s /= 1024;
      i++;
    }
    return '${s.toStringAsFixed(s < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }
}
