class RemoteFileItem {
  const RemoteFileItem({
    required this.id,
    required this.name,
    required this.originalName,
    required this.size,
    required this.type,
    required this.uploadedAt,
    required this.url,
  });

  final int id;
  final String name;
  final String originalName;
  final int size;
  final String type;
  final DateTime uploadedAt;
  final String url;

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

  factory RemoteFileItem.fromJson(Map<String, dynamic> json) {
    return RemoteFileItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      originalName: json['original_name'] as String? ?? json['name'] as String,
      size: (json['size'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'application/octet-stream',
      uploadedAt: DateTime.tryParse(json['uploaded_at'] as String? ?? '') ??
          DateTime.now(),
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'size': size,
      'type': type,
      'uploaded_at': uploadedAt.toIso8601String(),
      'url': url,
    };
  }
}
