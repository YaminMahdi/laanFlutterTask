import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/features/transfer/domain/entities/remote_file_item.dart';
import 'package:laan_task/features/transfer/presentation/widgets/file_item_card.dart';

void main() {
  group('FileItemCard Widget Tests', () {
    final sampleFile = RemoteFileItem(
      id: 99,
      name: 'invoice_march.pdf',
      originalName: 'Invoice March 2026.pdf',
      size: 1048576, // 1 MB
      type: 'application/pdf',
      uploadedAt: DateTime(2026, 3, 15, 10, 30),
      url: 'http://example.com/invoice_march.pdf',
    );

    testWidgets('renders download button and does not show downloaded badge when not downloaded',
        (tester) async {
      bool downloadTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileItemCard(
              file: sampleFile,
              isDownloaded: false,
              onDownload: () => downloadTapped = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Invoice March 2026.pdf'), findsOneWidget);
      expect(find.text('Downloaded'), findsNothing);
      expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      expect(find.byIcon(Icons.file_open_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.download_outlined));
      await tester.pump();

      expect(downloadTapped, isTrue);
    });

    testWidgets('renders Downloaded badge and Open button when isDownloaded is true',
        (tester) async {
      bool openTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileItemCard(
              file: sampleFile,
              isDownloaded: true,
              onOpen: () => openTapped = true,
              onDownload: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Invoice March 2026.pdf'), findsOneWidget);
      expect(find.text('Downloaded'), findsOneWidget);
      expect(find.byIcon(Icons.file_open_outlined), findsOneWidget);
      expect(find.byIcon(Icons.download_outlined), findsNothing);

      // Tapping open button triggers onOpen
      await tester.tap(find.byIcon(Icons.file_open_outlined));
      await tester.pump();
      expect(openTapped, isTrue);
    });

    testWidgets('tapping card body triggers onOpen when isDownloaded is true',
        (tester) async {
      bool openTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileItemCard(
              file: sampleFile,
              isDownloaded: true,
              onOpen: () => openTapped = true,
              onDownload: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Invoice March 2026.pdf'));
      await tester.pump();
      expect(openTapped, isTrue);
    });

    testWidgets('shows progress indicator when isDownloading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileItemCard(
              file: sampleFile,
              isDownloading: true,
              downloadProgress: 0.45,
              onDownload: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show LinearProgressIndicator when downloadProgress is 1.0 (100%)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileItemCard(
              file: sampleFile,
              isDownloading: true,
              downloadProgress: 1.0,
              onDownload: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('does not show LinearProgressIndicator when isDownloaded is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileItemCard(
              file: sampleFile,
              isDownloading: false,
              isDownloaded: true,
              downloadProgress: 0.0,
              onDownload: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
