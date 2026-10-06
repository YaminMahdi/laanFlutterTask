import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/database/downloaded_file_entity.dart';
import '../../../../core/storage/public_download_storage.dart';
import '../../domain/entities/remote_file_item.dart';
import '../../domain/entities/transfer_type.dart';
import '../notifiers/file_list_notifier.dart';
import '../notifiers/transfer_queue_notifier.dart';
import '../providers/transfer_providers.dart';
import '../widgets/file_item_card.dart';
import '../widgets/transfer_progress_card.dart';

@RoutePage()
class DownloadScreen extends ConsumerStatefulWidget {
  const DownloadScreen({super.key});

  @override
  ConsumerState<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(fileListProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _checkIsDownloaded(DownloadedFileEntity entity) {
    if (File(entity.localPath).existsSync()) {
      return true;
    }
    if (Platform.isAndroid && entity.localPath.startsWith('content://')) {
      final fallbackPath = '/storage/emulated/0/Download/${entity.fileName}';
      return File(fallbackPath).existsSync();
    }
    return false;
  }

  Future<void> _openDownloadedFile(
    BuildContext context,
    String localPath, {
    String? fileName,
  }) async {
    var pathToOpen = localPath;
    if (!await File(pathToOpen).exists() && Platform.isAndroid) {
      final resolved = await PublicDownloadStorage.resolveLocalPath(
        uriOrPath: pathToOpen,
        fileName: fileName,
      );
      if (resolved != null && await File(resolved).exists()) {
        pathToOpen = resolved;
      }
    }

    final file = File(pathToOpen);
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found on device storage.')),
        );
      }
      return;
    }

    try {
      final result = await OpenFilex.open(pathToOpen);
      if (result.type != ResultType.done && context.mounted) {
        final message = result.type == ResultType.noAppToOpen
            ? 'No application found to open this file type.'
            : 'Could not open file: ${result.message}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: $e')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, RemoteFileItem file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.originalName}" from the server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final success = await ref
                  .read(fileListProvider.notifier)
                  .deleteFile(file.name);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'File deleted from server'
                        : 'Failed to delete file',
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileListAsync = ref.watch(fileListProvider);
    final allTransfers = ref.watch(transferQueueProvider);
    final queueNotifier = ref.read(transferQueueProvider.notifier);
    final downloadedFilesMap = ref.watch(downloadedFilesMapProvider);

    final activeDownloads = allTransfers
        .where((t) => t.type == TransferType.download && t.status.isActive)
        .toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(fileListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Search & stats header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search catalog files, reports...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ],
                ),
              ),
            ),
            // Active downloads section
            if (activeDownloads.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Text(
                        'Ongoing Downloads',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${activeDownloads.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = activeDownloads[index];
                    return TransferProgressCard(
                      task: task,
                      onPause: () => queueNotifier.pause(task.id),
                      onResume: () => queueNotifier.resume(task.id),
                      onCancel: () => queueNotifier.cancel(task.id),
                      onRetry: () => queueNotifier.retry(task.id),
                    );
                  },
                  childCount: activeDownloads.length,
                ),
              ),
              const SliverToBoxAdapter(child: Divider(height: 24)),
            ],
            // Remote files section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    const Text(
                      'Server Files',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh file list',
                      onPressed: () =>
                          ref.read(fileListProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),
            ),
            // Files list
            fileListAsync.when(
              data: (files) {
                final filtered = files.where((f) {
                  if (_searchQuery.isEmpty) return true;
                  return f.originalName
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      f.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No uploaded files found on server'
                                : 'No matching files found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final file = filtered[index];

                      // Check if downloading
                      final matchingTask = allTransfers.where((t) {
                        return t.fileName == file.name &&
                            t.type == TransferType.download &&
                            t.status.isActive;
                      }).firstOrNull;

                      // Check if already downloaded
                      final downloadedEntity = downloadedFilesMap[file.id];
                      final isDownloaded = downloadedEntity != null &&
                          _checkIsDownloaded(downloadedEntity);

                      return FileItemCard(
                        file: file,
                        isDownloading: matchingTask != null,
                        downloadProgress: matchingTask?.progress ?? 0.0,
                        isDownloaded: isDownloaded,
                        onOpen: isDownloaded
                            ? () => _openDownloadedFile(
                                  context,
                                  downloadedEntity.localPath,
                                  fileName: downloadedEntity.fileName,
                                )
                            : null,
                        onDownload: () async {
                          if (isDownloaded) {
                            await _openDownloadedFile(
                              context,
                              downloadedEntity.localPath,
                              fileName: downloadedEntity.fileName,
                            );
                            return;
                          }
                          try {
                            await queueNotifier.download(
                              fileUrl: file.url,
                              fileName: file.name,
                              totalSize: file.size,
                              fileId: file.id,
                              originalName: file.originalName,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Downloading ${file.originalName} in background',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        onDelete: () => _confirmDelete(context, file),
                      );
                    },
                    childCount: filtered.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 44,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load files: $err',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(fileListProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
