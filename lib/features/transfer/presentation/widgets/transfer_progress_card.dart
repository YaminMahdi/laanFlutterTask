import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/entities/transfer_status.dart';
import '../../domain/entities/transfer_task.dart';
import '../../domain/entities/transfer_type.dart';

class TransferProgressCard extends StatelessWidget {
  const TransferProgressCard({
    super.key,
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRetry,
  });

  final TransferTask task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  Color _getStatusColor(BuildContext context) {
    switch (task.status) {
      case TransferStatus.running:
        return Theme.of(context).colorScheme.primary;
      case TransferStatus.queued:
        return Colors.orange;
      case TransferStatus.paused:
        return Colors.amber.shade700;
      case TransferStatus.completed:
        return Colors.green.shade600;
      case TransferStatus.failed:
        return Theme.of(context).colorScheme.error;
      case TransferStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  IconData _getTypeIcon() {
    return task.type == TransferType.upload
        ? Icons.cloud_upload_outlined
        : Icons.cloud_download_outlined;
  }

  void _openFile(BuildContext context) async {
    if (task.localPath != null && await File(task.localPath!).exists()) {
      final result = await OpenFilex.open(task.localPath!);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getTypeIcon(), color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.originalName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.status.displayName,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (task.formattedSpeed.isNotEmpty)
                            Text(
                              task.formattedSpeed,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.status.isCompleted
                    ? 1.0
                    : (task.status.isFailed ? 0.0 : task.progress),
                backgroundColor: Colors.grey.shade200,
                color: statusColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.formattedProgressDetail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${task.progressPercentage}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            if (task.errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                task.errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (task.status.isCompleted) {
      if (task.type == TransferType.download && task.localPath != null) {
        return IconButton(
          icon: const Icon(Icons.folder_open_outlined),
          tooltip: 'Open Downloaded File',
          onPressed: () => _openFile(context),
        );
      }
      return const SizedBox.shrink();
    }

    if (task.status.isFailed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              tooltip: 'Retry Transfer',
              onPressed: onRetry,
            ),
          if (onCancel != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              tooltip: 'Dismiss',
              onPressed: onCancel,
            ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.status == TransferStatus.running && onPause != null)
          IconButton(
            icon: const Icon(Icons.pause_circle_outline, color: Colors.amber),
            tooltip: 'Pause Transfer',
            onPressed: onPause,
          ),
        if (task.status == TransferStatus.paused && onResume != null)
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: Colors.blue),
            tooltip: 'Resume Transfer',
            onPressed: onResume,
          ),
        if (onCancel != null)
          IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
            tooltip: 'Cancel Transfer',
            onPressed: onCancel,
          ),
      ],
    );
  }
}

@Preview(name: 'Transfer Progress Card Preview')
Widget transferProgressCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: TransferProgressCard(
          task: TransferTask(
            id: 'demo_1',
            fileName: 'pos_catalog_2026.csv',
            originalName: 'pos_catalog_2026.csv',
            type: TransferType.upload,
            status: TransferStatus.running,
            bytesTransferred: 32000000,
            totalBytes: 64000000,
            speedBytesPerSecond: 2400000,
            createdAt: DateTime.now(),
          ),
        ),
      ),
    ),
  );
}
