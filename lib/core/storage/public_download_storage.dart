import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PublicDownloadedFile {
  const PublicDownloadedFile({
    required this.path,
    required this.size,
  });

  /// Android:
  ///   content://media/external/downloads/...
  ///
  /// Windows/Linux/macOS:
  ///   /home/user/Downloads/file.ext
  ///
  /// iOS:
  ///   /.../Documents/file.ext
  final String path;

  final int size;
}

class PublicDownloadStorage {
  static const MethodChannel _channel =
  MethodChannel('public_download_storage');

  static Future<PublicDownloadedFile> moveToPublicDownloads({
    required String sourcePath,
    required String fileName,
  }) async {
    if (Platform.isAndroid) {
      final result =
      await _channel.invokeMapMethod<String, dynamic>(
        'moveToDownloads',
        <String, dynamic>{
          'sourcePath': sourcePath,
          'fileName': fileName,
        },
      );

      if (result == null) {
        throw Exception(
          'Android failed to save file to Downloads.',
        );
      }

      return PublicDownloadedFile(
        path: result['uri'] as String,
        size: (result['size'] as num).toInt(),
      );
    }

    // ---------------------------------------------------------------
    // Windows / macOS / Linux
    // ---------------------------------------------------------------

    if (Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux) {
      final downloads = await getDownloadsDirectory();

      if (downloads == null) {
        throw Exception(
          'Could not locate the Downloads directory.',
        );
      }

      if (!await downloads.exists()) {
        await downloads.create(recursive: true);
      }

      final safeFileName =
      p.basename(fileName);

      final destination =
      File(p.join(
        downloads.path,
        safeFileName,
      ));

      if (await destination.exists()) {
        await destination.delete();
      }

      await File(sourcePath).rename(
        destination.path,
      );

      return PublicDownloadedFile(
        path: destination.path,
        size: await destination.length(),
      );
    }

    // ---------------------------------------------------------------
    // iOS
    // ---------------------------------------------------------------
    //
    // iOS does not expose a global public Downloads directory.
    // Documents is the correct user-accessible location.
    // ---------------------------------------------------------------

    if (Platform.isIOS) {
      final documents =
      await getApplicationDocumentsDirectory();

      final safeFileName =
      p.basename(fileName);

      final destination =
      File(p.join(
        documents.path,
        safeFileName,
      ));

      if (await destination.exists()) {
        await destination.delete();
      }

      await File(sourcePath).rename(
        destination.path,
      );

      return PublicDownloadedFile(
        path: destination.path,
        size: await destination.length(),
      );
    }

    throw UnsupportedError(
      'Public Downloads are not supported on this platform.',
    );
  }
}