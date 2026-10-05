import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'transfer_entity.dart';

abstract class TransferDao {
  Future<void> insertTransfer(TransferEntity entity);
  Future<void> updateTransfer(TransferEntity entity);
  Future<void> updateProgress(
    String id,
    int bytesTransferred,
    int totalBytes,
    int speedBytesPerSecond,
  );
  Future<void> updateStatus(
    String id,
    String status, {
    String? errorMessage,
    int? completedAt,
    String? localPath,
    String? fileUrl,
  });
  Future<TransferEntity?> getTransferById(String id);
  Future<List<TransferEntity>> getAllTransfers();
  Future<List<TransferEntity>> getActiveTransfers();
  Future<void> deleteTransfer(String id);
  Future<void> clearCompleted();
  Stream<List<TransferEntity>> watchAllTransfers();
}

class TransferDaoImpl implements TransferDao {
  TransferDaoImpl(this._db) {
    _streamController = StreamController<List<TransferEntity>>.broadcast();
  }

  final Database _db;
  late final StreamController<List<TransferEntity>> _streamController;

  static const String tableName = 'transfers';

  void _notifyChange() async {
    if (_streamController.hasListener) {
      final list = await getAllTransfers();
      _streamController.add(list);
    }
  }

  @override
  Future<void> insertTransfer(TransferEntity entity) async {
    await _db.insert(
      tableName,
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyChange();
  }

  @override
  Future<void> updateTransfer(TransferEntity entity) async {
    await _db.update(
      tableName,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
    _notifyChange();
  }

  @override
  Future<void> updateProgress(
    String id,
    int bytesTransferred,
    int totalBytes,
    int speedBytesPerSecond,
  ) async {
    await _db.update(
      tableName,
      {
        'bytesTransferred': bytesTransferred,
        'totalBytes': totalBytes,
        'speedBytesPerSecond': speedBytesPerSecond,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifyChange();
  }

  @override
  Future<void> updateStatus(
    String id,
    String status, {
    String? errorMessage,
    int? completedAt,
    String? localPath,
    String? fileUrl,
  }) async {
    final values = <String, dynamic>{
      'status': status,
      'errorMessage': errorMessage,
      'completedAt': ?completedAt,
      'localPath': ?localPath,
      'fileUrl': ?fileUrl,
    };

    await _db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifyChange();
  }

  @override
  Future<TransferEntity?> getTransferById(String id) async {
    final results = await _db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return TransferEntity.fromMap(results.first);
  }

  @override
  Future<List<TransferEntity>> getAllTransfers() async {
    final results = await _db.query(
      tableName,
      orderBy: 'createdAt DESC',
    );
    return results.map(TransferEntity.fromMap).toList();
  }

  @override
  Future<List<TransferEntity>> getActiveTransfers() async {
    final results = await _db.query(
      tableName,
      where: 'status IN (?, ?)',
      whereArgs: ['running', 'queued'],
      orderBy: 'createdAt DESC',
    );
    return results.map(TransferEntity.fromMap).toList();
  }

  @override
  Future<void> deleteTransfer(String id) async {
    await _db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifyChange();
  }

  @override
  Future<void> clearCompleted() async {
    await _db.delete(
      tableName,
      where: 'status IN (?, ?)',
      whereArgs: ['completed', 'cancelled'],
    );
    _notifyChange();
  }

  @override
  Stream<List<TransferEntity>> watchAllTransfers() {
    // Emit initial cached state immediately
    Timer.run(() async {
      final list = await getAllTransfers();
      if (!_streamController.isClosed) {
        _streamController.add(list);
      }
    });
    return _streamController.stream;
  }
}
