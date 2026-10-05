import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/core/database/downloaded_file_entity.dart';

void main() {
  group('DownloadedFileEntity Tests', () {
    test('toMap and fromMap preserves all fields accurately', () {
      const entity = DownloadedFileEntity(
        fileId: 42,
        fileName: 'report_2026.pdf',
        originalName: 'Annual Report 2026.pdf',
        localPath: '/data/user/0/com.laantech.pos/downloads/report_2026.pdf',
        fileSize: 2048576,
        downloadedAt: 1775432100000,
        fileType: 'application/pdf',
      );

      final map = entity.toMap();
      expect(map['fileId'], equals(42));
      expect(map['fileName'], equals('report_2026.pdf'));
      expect(map['originalName'], equals('Annual Report 2026.pdf'));
      expect(map['localPath'], equals('/data/user/0/com.laantech.pos/downloads/report_2026.pdf'));
      expect(map['fileSize'], equals(2048576));
      expect(map['downloadedAt'], equals(1775432100000));
      expect(map['fileType'], equals('application/pdf'));

      final reconstructed = DownloadedFileEntity.fromMap(map);
      expect(reconstructed.fileId, equals(entity.fileId));
      expect(reconstructed.fileName, equals(entity.fileName));
      expect(reconstructed.originalName, equals(entity.originalName));
      expect(reconstructed.localPath, equals(entity.localPath));
      expect(reconstructed.fileSize, equals(entity.fileSize));
      expect(reconstructed.downloadedAt, equals(entity.downloadedAt));
      expect(reconstructed.fileType, equals(entity.fileType));
      expect(reconstructed, equals(entity));
    });

    test('copyWith updates specified fields only', () {
      const entity = DownloadedFileEntity(
        fileId: 10,
        fileName: 'img.jpg',
        originalName: 'img.jpg',
        localPath: '/downloads/img.jpg',
        fileSize: 500,
        downloadedAt: 1000,
      );

      final updated = entity.copyWith(
        localPath: '/new_path/img.jpg',
        fileSize: 600,
      );

      expect(updated.fileId, equals(10));
      expect(updated.fileName, equals('img.jpg'));
      expect(updated.localPath, equals('/new_path/img.jpg'));
      expect(updated.fileSize, equals(600));
      expect(updated.downloadedAt, equals(1000));
    });
  });
}
