import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/remote_file_item.dart';

class FileItemCard extends StatelessWidget {
  const FileItemCard({
    super.key,
    required this.file,
    required this.onDownload,
    required this.onDelete,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
  });

  final RemoteFileItem file;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final bool isDownloading;
  final double downloadProgress;

  IconData _getFileIcon() {
    if (file.isImage) return Icons.image_outlined;
    if (file.isVideo) return Icons.video_file_outlined;
    if (file.isCsv) return Icons.table_chart_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final formattedDate = dateFormat.format(file.uploadedAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail / Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: file.isImage
                    ? CachedNetworkImage(
                        imageUrl: file.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(_getFileIcon(), color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        child: Icon(
                          _getFileIcon(),
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.originalName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${file.formattedSize} • $formattedDate',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  if (isDownloading) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: downloadProgress > 0 ? downloadProgress : null,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, color: Colors.blue),
              tooltip: 'Download File',
              onPressed: isDownloading ? null : onDownload,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete File',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'File Item Card Preview')
Widget fileItemCardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: FileItemCard(
          file: RemoteFileItem(
            id: 1,
            name: 'catalog_q3.csv',
            originalName: 'catalog_q3.csv',
            size: 15400000,
            type: 'text/csv',
            uploadedAt: DateTime.now(),
            url: 'http://15.232.228.139/api/get?file=catalog_q3.csv',
          ),
          onDownload: () {},
          onDelete: () {},
        ),
      ),
    ),
  );
}
