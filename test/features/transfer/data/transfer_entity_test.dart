import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/core/database/transfer_entity.dart';

void main() {
  group('TransferEntity SQLite Mapping Tests', () {
    test('converts to map and from map accurately', () {
      const entity = TransferEntity(
        id: 'db_task_1',
        fileName: 'products.csv',
        originalName: 'products_v1.csv',
        fileUrl: 'http://15.232.228.139/api/get?file=products.csv',
        localPath: '/storage/downloads/products.csv',
        transferType: 'download',
        status: 'completed',
        bytesTransferred: 5242880,
        totalBytes: 5242880,
        speedBytesPerSecond: 1048576,
        createdAt: 1770000000000,
        completedAt: 1770000005000,
      );

      final map = entity.toMap();
      final recreated = TransferEntity.fromMap(map);

      expect(recreated.id, entity.id);
      expect(recreated.fileName, entity.fileName);
      expect(recreated.originalName, entity.originalName);
      expect(recreated.fileUrl, entity.fileUrl);
      expect(recreated.localPath, entity.localPath);
      expect(recreated.transferType, entity.transferType);
      expect(recreated.status, entity.status);
      expect(recreated.bytesTransferred, entity.bytesTransferred);
      expect(recreated.totalBytes, entity.totalBytes);
      expect(recreated.speedBytesPerSecond, entity.speedBytesPerSecond);
      expect(recreated.createdAt, entity.createdAt);
      expect(recreated.completedAt, entity.completedAt);
    });
  });
}
