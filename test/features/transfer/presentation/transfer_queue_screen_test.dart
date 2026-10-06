import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_status.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_task.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_type.dart';
import 'package:laan_task/features/transfer/presentation/notifiers/transfer_queue_notifier.dart';
import 'package:laan_task/features/transfer/presentation/screens/transfer_queue_screen.dart';

void main() {
  group('TransferQueueScreen (Merged Transfer Manager) Tests', () {
    testWidgets('renders empty state when queue is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transferQueueProvider.overrideWith(() => _TestEmptyQueueNotifier()),
          ],
          child: const MaterialApp(
            home: TransferQueueScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('No Transfers in Queue'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('All (0)'), findsOneWidget);
    });

    testWidgets('renders stat counters, filter chips, and transfer cards',
        (tester) async {
      final sampleTasks = [
        TransferTask(
          id: 'test_1',
          fileName: 'catalog_q1.csv',
          originalName: 'catalog_q1.csv',
          type: TransferType.upload,
          status: TransferStatus.running,
          bytesTransferred: 5000,
          totalBytes: 10000,
          createdAt: DateTime.now(),
        ),
        TransferTask(
          id: 'test_2',
          fileName: 'products.zip',
          originalName: 'products.zip',
          type: TransferType.download,
          status: TransferStatus.completed,
          bytesTransferred: 20000,
          totalBytes: 20000,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transferQueueProvider
                .overrideWith(() => _TestPopulatedQueueNotifier(sampleTasks)),
          ],
          child: const MaterialApp(
            home: TransferQueueScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify files rendered
      expect(find.text('catalog_q1.csv'), findsOneWidget);
      expect(find.text('products.zip'), findsOneWidget);

      // Verify counters
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Active (1)'), findsOneWidget);
      expect(find.text('Done (1)'), findsOneWidget);

      // Filter by Active
      await tester.tap(find.text('Active (1)'));
      await tester.pump();

      expect(find.text('catalog_q1.csv'), findsOneWidget);
      expect(find.text('products.zip'), findsNothing);

      // Filter by Done
      await tester.tap(find.text('Done (1)'));
      await tester.pump();

      expect(find.text('catalog_q1.csv'), findsNothing);
      expect(find.text('products.zip'), findsOneWidget);
    });
  });
}

class _TestEmptyQueueNotifier extends TransferQueueNotifier {
  @override
  List<TransferTask> build() => [];
}

class _TestPopulatedQueueNotifier extends TransferQueueNotifier {
  _TestPopulatedQueueNotifier(this._initial);
  final List<TransferTask> _initial;

  @override
  List<TransferTask> build() => _initial;
}
