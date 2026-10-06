import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/core/database/downloaded_file_entity.dart';
import 'package:laan_task/features/transfer/domain/entities/remote_file_item.dart';
import 'package:laan_task/features/transfer/domain/entities/transfer_task.dart';
import 'package:laan_task/features/transfer/presentation/notifiers/file_list_notifier.dart';
import 'package:laan_task/features/transfer/presentation/notifiers/transfer_queue_notifier.dart';
import 'package:laan_task/features/transfer/presentation/providers/transfer_providers.dart';
import 'package:laan_task/features/transfer/presentation/screens/download_screen.dart';

void main() {
  group('DownloadScreen Widget Tests', () {
    late Directory tempDir;
    late File dummyFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('laan_download_screen_test_');
      dummyFile = File('${tempDir.path}/existing_file.pdf');
      await dummyFile.writeAsString('test content');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets('distinguishes downloaded files from un-downloaded files in file list',
        (tester) async {
      final downloadedItem = RemoteFileItem(
        id: 1,
        name: 'existing_file.pdf',
        originalName: 'Existing Document.pdf',
        size: 512,
        type: 'application/pdf',
        uploadedAt: DateTime.now(),
        url: 'http://example.com/existing_file.pdf',
      );

      final unDownloadedItem = RemoteFileItem(
        id: 2,
        name: 'new_catalog.csv',
        originalName: 'New Catalog.csv',
        size: 2048,
        type: 'text/csv',
        uploadedAt: DateTime.now(),
        url: 'http://example.com/new_catalog.csv',
      );

      final downloadedEntity = DownloadedFileEntity(
        fileId: 1,
        fileName: 'existing_file.pdf',
        originalName: 'Existing Document.pdf',
        localPath: dummyFile.path,
        fileSize: 512,
        downloadedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileListProvider.overrideWith(
              () => _FakeFileListNotifier([downloadedItem, unDownloadedItem]),
            ),
            transferQueueProvider.overrideWith(
              () => _FakeTransferQueueNotifier([]),
            ),
            downloadedFilesMapProvider.overrideWithValue({
              1: downloadedEntity,
            }),
          ],
          child: const MaterialApp(
            home: DownloadScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check both files are rendered
      expect(find.text('Existing Document.pdf'), findsOneWidget);
      expect(find.text('New Catalog.csv'), findsOneWidget);

      // Existing document is downloaded: shows "Downloaded" badge and Open button
      expect(find.text('Downloaded'), findsOneWidget);
      expect(find.byIcon(Icons.file_open_outlined), findsOneWidget);

      // New catalog is not downloaded: shows Download button
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
    });

    testWidgets('tapping download on an un-downloaded file initiates download with fileId',
        (tester) async {
      final unDownloadedItem = RemoteFileItem(
        id: 77,
        name: 'inventory.csv',
        originalName: 'Inventory 2026.csv',
        size: 4096,
        type: 'text/csv',
        uploadedAt: DateTime.now(),
        url: 'http://example.com/inventory.csv',
      );

      final fakeQueue = _FakeTransferQueueNotifier([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileListProvider.overrideWith(
              () => _FakeFileListNotifier([unDownloadedItem]),
            ),
            transferQueueProvider.overrideWith(
              () => fakeQueue,
            ),
            downloadedFilesMapProvider.overrideWithValue({}),
          ],
          child: const MaterialApp(
            home: DownloadScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.download_outlined));
      await tester.pump();

      expect(fakeQueue.downloadCalls.length, equals(1));
      expect(fakeQueue.downloadCalls.first['fileId'], equals(77));
      expect(fakeQueue.downloadCalls.first['fileName'], equals('inventory.csv'));
      expect(fakeQueue.downloadCalls.first['originalName'], equals('Inventory 2026.csv'));
    });

    testWidgets('automatically calls refresh on fileListProvider when navigating to DownloadScreen',
        (tester) async {
      final fakeNotifier = _FakeFileListNotifier([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fileListProvider.overrideWith(() => fakeNotifier),
            transferQueueProvider.overrideWith(
              () => _FakeTransferQueueNotifier([]),
            ),
            downloadedFilesMapProvider.overrideWithValue({}),
          ],
          child: const MaterialApp(
            home: DownloadScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(fakeNotifier.refreshCallCount, greaterThanOrEqualTo(1));
    });
  });
}

class _FakeFileListNotifier extends FileListNotifier {
  _FakeFileListNotifier(this._initial);
  final List<RemoteFileItem> _initial;
  int refreshCallCount = 0;

  @override
  Future<List<RemoteFileItem>> build() async => _initial;

  @override
  Future<void> refresh() async {
    refreshCallCount++;
    state = AsyncValue.data(_initial);
  }
}

class _FakeTransferQueueNotifier extends TransferQueueNotifier {
  _FakeTransferQueueNotifier(this._initial);
  final List<TransferTask> _initial;
  final List<Map<String, dynamic>> downloadCalls = [];

  @override
  List<TransferTask> build() => _initial;

  @override
  Future<String> download({
    required String fileUrl,
    required String fileName,
    int? totalSize,
    int? fileId,
    String? originalName,
  }) async {
    downloadCalls.add({
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileId': fileId,
      'originalName': originalName,
    });
    return 'task_1';
  }
}
