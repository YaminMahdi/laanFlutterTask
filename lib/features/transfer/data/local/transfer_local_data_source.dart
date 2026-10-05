import '../../../../core/database/transfer_dao.dart';
import '../../../../core/database/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart';
import '../../domain/entities/transfer_task.dart';
import '../../domain/entities/transfer_type.dart';

abstract class TransferLocalDataSource {
  Future<void> saveTransfer(TransferTask task);
  Future<void> updateTransfer(TransferTask task);
  Future<void> updateProgress(
    String id,
    int bytesTransferred,
    int totalBytes,
    int speed,
  );
  Future<void> updateStatus(
    String id,
    TransferStatus status, {
    String? errorMessage,
    DateTime? completedAt,
    String? localPath,
    String? fileUrl,
  });
  Future<TransferTask?> getTransfer(String id);
  Future<List<TransferTask>> getAllTransfers();
  Future<void> deleteTransfer(String id);
  Future<void> clearCompleted();
  Stream<List<TransferTask>> watchAllTransfers();
}

class TransferLocalDataSourceImpl implements TransferLocalDataSource {
  TransferLocalDataSourceImpl(this._dao);

  final TransferDao _dao;

  TransferTask _toDomain(TransferEntity entity) {
    return TransferTask(
      id: entity.id,
      fileName: entity.fileName,
      originalName: entity.originalName,
      fileUrl: entity.fileUrl,
      localPath: entity.localPath,
      type: TransferType.fromString(entity.transferType),
      status: TransferStatus.fromString(entity.status),
      bytesTransferred: entity.bytesTransferred,
      totalBytes: entity.totalBytes,
      speedBytesPerSecond: entity.speedBytesPerSecond,
      errorMessage: entity.errorMessage,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      completedAt: entity.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.completedAt!)
          : null,
    );
  }

  TransferEntity _toEntity(TransferTask task) {
    return TransferEntity(
      id: task.id,
      fileName: task.fileName,
      originalName: task.originalName,
      fileUrl: task.fileUrl,
      localPath: task.localPath,
      transferType: task.type.name,
      status: task.status.name,
      bytesTransferred: task.bytesTransferred,
      totalBytes: task.totalBytes,
      speedBytesPerSecond: task.speedBytesPerSecond,
      errorMessage: task.errorMessage,
      createdAt: task.createdAt.millisecondsSinceEpoch,
      completedAt: task.completedAt?.millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> saveTransfer(TransferTask task) =>
      _dao.insertTransfer(_toEntity(task));

  @override
  Future<void> updateTransfer(TransferTask task) =>
      _dao.updateTransfer(_toEntity(task));

  @override
  Future<void> updateProgress(
    String id,
    int bytesTransferred,
    int totalBytes,
    int speed,
  ) =>
      _dao.updateProgress(id, bytesTransferred, totalBytes, speed);

  @override
  Future<void> updateStatus(
    String id,
    TransferStatus status, {
    String? errorMessage,
    DateTime? completedAt,
    String? localPath,
    String? fileUrl,
  }) =>
      _dao.updateStatus(
        id,
        status.name,
        errorMessage: errorMessage,
        completedAt: completedAt?.millisecondsSinceEpoch,
        localPath: localPath,
        fileUrl: fileUrl,
      );

  @override
  Future<TransferTask?> getTransfer(String id) async {
    final entity = await _dao.getTransferById(id);
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<List<TransferTask>> getAllTransfers() async {
    final list = await _dao.getAllTransfers();
    return list.map(_toDomain).toList();
  }

  @override
  Future<void> deleteTransfer(String id) => _dao.deleteTransfer(id);

  @override
  Future<void> clearCompleted() => _dao.clearCompleted();

  @override
  Stream<List<TransferTask>> watchAllTransfers() {
    return _dao.watchAllTransfers().map((list) => list.map(_toDomain).toList());
  }
}
