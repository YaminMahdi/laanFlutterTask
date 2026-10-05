import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/remote_file_item.dart';
import '../../domain/entities/transfer_type.dart';
import '../notifiers/file_list_notifier.dart';
import '../notifiers/transfer_queue_notifier.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
            // Catalog Files header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Server File Catalog',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // File list state handling
            fileListAsync.when(
              data: (files) {
                final filtered = files.where((f) {
                  if (_searchQuery.isEmpty) return true;
                  return f.originalName
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

                      return FileItemCard(
                        file: file,
                        isDownloading: matchingTask != null,
                        downloadProgress: matchingTask?.progress ?? 0.0,
                        onDownload: () async {
                          await queueNotifier.download(
                            fileUrl: file.url,
                            fileName: file.name,
                            totalSize: file.size,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Downloading ${file.originalName} in background'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
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
