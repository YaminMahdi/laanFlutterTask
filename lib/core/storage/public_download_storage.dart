import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PublicDownloadedFile {
  const PublicDownloadedFile({
    required this.path,
    required this.size,
    this.uri,
  });

  /// Android:
  ///   /storage/emulated/0/Download/file.ext
  ///
  /// Windows/Linux/macOS:
  ///   /home/user/Downloads/file.ext
  ///
  /// iOS:
  ///   /.../Documents/file.ext
  final String path;

  /// Optional Android content URI (e.g. content://media/external/downloads/...)
  final String? uri;

  final int size;
}

class PublicDownloadStorage {
  static const MethodChannel _channel =
  MethodChannel('public_download_storage');

  /// Resolves a content URI or raw path to an actual filesystem path on Android.
  static Future<String?> resolveLocalPath({
    required String uriOrPath,
    String? fileName,
  }) async {
    if (!Platform.isAndroid) {
      return uriOrPath;
    }

    if (!uriOrPath.startsWith('content://')) {
      if (File(uriOrPath).existsSync()) {
        return uriOrPath;
      }
    }

    try {
      final resolved = await _channel.invokeMethod<String>(
        'resolveContentUri',
        <String, dynamic>{
          'uri': uriOrPath,
          'fileName': ?fileName,
        },
      );
      if (resolved != null &&
          resolved.isNotEmpty &&
          !resolved.startsWith('content://')) {
        return resolved;
      }
    } catch (_) {}

    // Fallback: check standard Android Download directory
    if (fileName != null && fileName.isNotEmpty) {
      final fallbackPath = '/storage/emulated/0/Download/$fileName';
      return fallbackPath;
    }

    return uriOrPath;
  }

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

      var resolvedPath = (result['path'] as String?)?.isNotEmpty == true
          ? (result['path'] as String)
          : (result['uri'] as String);

      if (resolvedPath.startsWith('content://')) {
        final fallback = '/storage/emulated/0/Download/$fileName';
        if (File(fallback).existsSync()) {
          resolvedPath = fallback;
        } else {
          final fromChannel = await resolveLocalPath(
            uriOrPath: resolvedPath,
            fileName: fileName,
          );
          if (fromChannel != null &&
              fromChannel.isNotEmpty &&
              !fromChannel.startsWith('content://')) {
            resolvedPath = fromChannel;
          } else {
            resolvedPath = fallback;
          }
        }
      }

      return PublicDownloadedFile(
        path: resolvedPath,
        uri: result['uri'] as String?,
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