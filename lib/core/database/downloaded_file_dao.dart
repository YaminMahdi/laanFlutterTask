import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'downloaded_file_entity.dart';

abstract class DownloadedFileDao {
  Future<void> insertDownloadedFile(DownloadedFileEntity entity);
  Future<DownloadedFileEntity?> getDownloadedFileById(int fileId);
  Future<DownloadedFileEntity?> getDownloadedFileByName(String fileName);
  Future<List<DownloadedFileEntity>> getAllDownloadedFiles();
  Future<void> deleteDownloadedFile(int fileId);
  Future<void> deleteAllDownloadedFiles();
  Stream<List<DownloadedFileEntity>> watchAllDownloadedFiles();
}

class DownloadedFileDaoImpl implements DownloadedFileDao {
  DownloadedFileDaoImpl(this._db) {
    _streamController = StreamController<List<DownloadedFileEntity>>.broadcast();
  }

  final Database _db;
  late final StreamController<List<DownloadedFileEntity>> _streamController;

  static const String tableName = 'downloaded_files';

  void _notifyChange() async {
    if (_streamController.hasListener) {
      final list = await getAllDownloadedFiles();
      if (!_streamController.isClosed) {
        _streamController.add(list);
      }
    }
  }

  @override
  Future<void> insertDownloadedFile(DownloadedFileEntity entity) async {
    await _db.insert(
      tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyChange();
  }

  @override
  Future<DownloadedFileEntity?> getDownloadedFileById(int fileId) async {
    final maps = await _db.query(
      tableName,
      where: 'fileId = ?',
      whereArgs: [fileId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DownloadedFileEntity.fromMap(maps.first);
  }

  @override
  Future<DownloadedFileEntity?> getDownloadedFileByName(String fileName) async {
    final maps = await _db.query(
      tableName,
      where: 'fileName = ?',
      whereArgs: [fileName],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DownloadedFileEntity.fromMap(maps.first);
  }

  @override
  Future<List<DownloadedFileEntity>> getAllDownloadedFiles() async {
    final maps = await _db.query(
      tableName,
      orderBy: 'downloadedAt DESC',
    );
    return maps.map(DownloadedFileEntity.fromMap).toList();
  }

  @override
  Future<void> deleteDownloadedFile(int fileId) async {
    await _db.delete(
      tableName,
      where: 'fileId = ?',
      whereArgs: [fileId],
    );
    _notifyChange();
  }

  @override
  Future<void> deleteAllDownloadedFiles() async {
    await _db.delete(tableName);
    _notifyChange();
  }

  @override
  Stream<List<DownloadedFileEntity>> watchAllDownloadedFiles() {
    late StreamController<List<DownloadedFileEntity>> controller;
    StreamSubscription<List<DownloadedFileEntity>>? sub;

    controller = StreamController<List<DownloadedFileEntity>>.broadcast(
      onListen: () async {
        final current = await getAllDownloadedFiles();
        if (!controller.isClosed) {
          controller.add(current);
        }
        sub = _streamController.stream.listen((data) {
          if (!controller.isClosed) {
            controller.add(data);
          }
        });
      },
      onCancel: () {
        sub?.cancel();
      },
    );

    return controller.stream;
  }
}
