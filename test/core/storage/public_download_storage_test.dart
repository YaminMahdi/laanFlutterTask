import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laan_task/core/storage/public_download_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PublicDownloadedFile Tests', () {
    test('instantiates with path and size correctly', () {
      const file = PublicDownloadedFile(
        path: '/storage/emulated/0/Download/mahdi_4176decc.jpeg',
        uri: 'content://media/external/downloads/1000051408',
        size: 1024,
      );

      expect(file.path, equals('/storage/emulated/0/Download/mahdi_4176decc.jpeg'));
      expect(file.uri, equals('content://media/external/downloads/1000051408'));
      expect(file.size, equals(1024));
    });

    test('resolveLocalPath returns original path on non-Android platform', () async {
      final result = await PublicDownloadStorage.resolveLocalPath(
        uriOrPath: '/home/user/Downloads/file.pdf',
        fileName: 'file.pdf',
      );

      expect(result, equals('/home/user/Downloads/file.pdf'));
    });
  });
}
