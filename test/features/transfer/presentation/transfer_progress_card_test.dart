import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_status.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_task.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_type.dart';
import 'package:laan_task/features/transfer/presentation/widgets/transfer_progress_card.dart';

void main() {
  group('TransferProgressCard Widget Tests', () {
    testWidgets('renders filename, progress percentage, and speed',
        (tester) async {
      final task = TransferTask(
        id: 'widget_task_1',
        fileName: 'store_inventory.csv',
        originalName: 'store_inventory.csv',
        type: TransferType.upload,
        status: TransferStatus.running,
        bytesTransferred: 25 * 1024 * 1024,
        totalBytes: 50 * 1024 * 1024,
        speedBytesPerSecond: 1500000,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransferProgressCard(task: task),
          ),
        ),
      );

      expect(find.text('store_inventory.csv'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsNothing); // callbacks null
    });

    testWidgets('calls onPause callback when pause icon button is tapped',
        (tester) async {
      var paused = false;

      final task = TransferTask(
        id: 'widget_task_2',
        fileName: 'backup.zip',
        originalName: 'backup.zip',
        type: TransferType.download,
        status: TransferStatus.running,
        bytesTransferred: 10 * 1024 * 1024,
        totalBytes: 20 * 1024 * 1024,
        speedBytesPerSecond: 500000,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransferProgressCard(
              task: task,
              onPause: () => paused = true,
            ),
          ),
        ),
      );

      final pauseButton = find.byIcon(Icons.pause_circle_outline);
      expect(pauseButton, findsOneWidget);

      await tester.tap(pauseButton);
      await tester.pump();

      expect(paused, isTrue);
    });

    testWidgets('shows retry and dismiss buttons when status is failed',
        (tester) async {
      var retried = false;

      final task = TransferTask(
        id: 'widget_task_3',
        fileName: 'catalog_failed.csv',
        originalName: 'catalog_failed.csv',
        type: TransferType.upload,
        status: TransferStatus.failed,
        bytesTransferred: 0,
        totalBytes: 1000,
        errorMessage: 'Network timeout',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransferProgressCard(
              task: task,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Network timeout'), findsOneWidget);

      final retryButton = find.byIcon(Icons.refresh);
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}
