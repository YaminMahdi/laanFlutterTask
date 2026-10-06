import 'dart:async';
import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/transfer_task.dart';
import '../providers/transfer_providers.dart';

class TransferQueueNotifier extends Notifier<List<TransferTask>> {
  StreamSubscription<List<TransferTask>>? _subscription;

  @override
  List<TransferTask> build() {
    final repo = ref.watch(transferRepositoryProvider);
    _subscription?.cancel();
    _subscription = repo.watchAllTransfers().listen((transfers) {
      state = transfers;
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [];
  }

  Future<String> upload(File file) async {
    final useCase = ref.read(startUploadUseCaseProvider);
    return useCase(file);
  }

  Future<String> download({
    required String fileUrl,
    required String fileName,
    int? totalSize,
    int? fileId,
    String? originalName,
  }) async {
    final useCase = ref.read(startDownloadUseCaseProvider);
    return useCase(
      fileUrl: fileUrl,
      fileName: fileName,
      totalSize: totalSize,
      fileId: fileId,
      originalName: originalName,
    );
  }

  Future<void> pause(String id) async {
    final useCase = ref.read(pauseTransferUseCaseProvider);
    await useCase(id);
  }

  Future<void> resume(String id) async {
    final useCase = ref.read(resumeTransferUseCaseProvider);
    await useCase(id);
  }

  Future<void> cancel(String id) async {
    final useCase = ref.read(cancelTransferUseCaseProvider);
    await useCase(id);
  }

  Future<void> retry(String id) async {
    final repo = ref.read(transferRepositoryProvider);
    await repo.retryTransfer(id);
  }

  Future<void> clearCompleted() async {
    final repo = ref.read(transferRepositoryProvider);
    await repo.clearCompletedTransfers();
  }

  Future<void> pauseAll() async {
    final active = state.where((t) => t.status.isActive).toList();
    for (final task in active) {
      await pause(task.id);
    }
  }

  Future<void> resumeAll() async {
    final paused = state.where((t) => t.status.isPaused).toList();
    for (final task in paused) {
      await resume(task.id);
    }
  }
}

final transferQueueProvider =
    NotifierProvider<TransferQueueNotifier, List<TransferTask>>(
  TransferQueueNotifier.new,
);

// Derived providers
final activeTransfersProvider = Provider<List<TransferTask>>((ref) {
  final transfers = ref.watch(transferQueueProvider);
  return transfers.where((t) => t.status.isActive).toList();
});

final hasActiveTransfersProvider = Provider<bool>((ref) {
  final active = ref.watch(activeTransfersProvider);
  return active.isNotEmpty;
});

final aggregateTransferProgressProvider = Provider<double>((ref) {
  final active = ref.watch(activeTransfersProvider);
  if (active.isEmpty) return 0.0;
  final totalBytes = active.fold<int>(0, (sum, t) => sum + t.totalBytes);
  final transferredBytes =
      active.fold<int>(0, (sum, t) => sum + t.bytesTransferred);
  if (totalBytes <= 0) return 0.0;
  return (transferredBytes / totalBytes).clamp(0.0, 1.0);
});
