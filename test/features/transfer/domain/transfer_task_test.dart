import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_status.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_task.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_type.dart';

void main() {
  group('TransferTask Domain Entity Tests', () {
    test('calculates correct progress ratio and percentage', () {
      final task = TransferTask(
        id: 'task_1',
        fileName: 'catalog.csv',
        originalName: 'catalog.csv',
        type: TransferType.upload,
        status: TransferStatus.running,
        bytesTransferred: 50 * 1024 * 1024,
        totalBytes: 100 * 1024 * 1024,
        speedBytesPerSecond: 2 * 1024 * 1024,
        createdAt: DateTime.now(),
      );

      expect(task.progress, 0.5);
      expect(task.progressPercentage, 50);
      expect(task.formattedSpeed, '2.0 MB/s');
      expect(task.formattedTotalSize, '100 MB');
      expect(task.formattedTransferredSize, '50 MB');
      expect(task.formattedProgressDetail, '50 MB of 100 MB');
    });

    test('handles zero totalBytes gracefully without division by zero', () {
      final task = TransferTask(
        id: 'task_2',
        fileName: 'unknown.bin',
        originalName: 'unknown.bin',
        type: TransferType.download,
        status: TransferStatus.queued,
        bytesTransferred: 0,
        totalBytes: 0,
        createdAt: DateTime.now(),
      );

      expect(task.progress, 0.0);
      expect(task.progressPercentage, 0);
      expect(task.formattedSpeed, '');
    });

    test('clamps progress to 1.0 if transferred exceeds total', () {
      final task = TransferTask(
        id: 'task_3',
        fileName: 'audit.csv',
        originalName: 'audit.csv',
        type: TransferType.download,
        status: TransferStatus.completed,
        bytesTransferred: 120,
        totalBytes: 100,
        createdAt: DateTime.now(),
      );

      expect(task.progress, 1.0);
      expect(task.progressPercentage, 100);
      expect(task.status.isCompleted, isTrue);
    });

    test('copyWith updates specified fields immutably', () {
      final task = TransferTask(
        id: 'task_4',
        fileName: 'image.jpg',
        originalName: 'image.jpg',
        type: TransferType.upload,
        status: TransferStatus.running,
        bytesTransferred: 100,
        totalBytes: 1000,
        createdAt: DateTime.now(),
      );

      final updated = task.copyWith(
        status: TransferStatus.paused,
        bytesTransferred: 500,
      );

      expect(updated.status, TransferStatus.paused);
      expect(updated.bytesTransferred, 500);
      expect(task.status, TransferStatus.running); // Original unchanged
      expect(task.bytesTransferred, 100);
    });
  });
}
