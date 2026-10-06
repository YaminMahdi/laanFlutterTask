import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/remote_file_item.dart';
import '../providers/transfer_providers.dart';

class FileListNotifier extends AsyncNotifier<List<RemoteFileItem>> {
  @override
  Future<List<RemoteFileItem>> build() async {
    return _fetchFiles();
  }

  Future<List<RemoteFileItem>> _fetchFiles() async {
    final useCase = ref.read(getRemoteFilesUseCaseProvider);
    return useCase();
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchFiles);
  }

  Future<bool> deleteFile(String fileName) async {
    final useCase = ref.read(deleteRemoteFileUseCaseProvider);
    final success = await useCase(fileName);
    if (success) {
      final currentList = state.value ?? [];
      state = AsyncValue.data(
        currentList.where((f) => f.name != fileName).toList(),
      );
    }
    return success;
  }
}

final fileListProvider =
    AsyncNotifierProvider<FileListNotifier, List<RemoteFileItem>>(
  FileListNotifier.new,
);
