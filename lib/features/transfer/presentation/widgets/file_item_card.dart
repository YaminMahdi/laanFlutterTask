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
    this.isDownloaded = false,
    this.onOpen,
  });

  final RemoteFileItem file;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final bool isDownloading;
  final double downloadProgress;
  final bool isDownloaded;
  final VoidCallback? onOpen;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isDownloaded ? onOpen : null,
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${file.formattedSize} • $formattedDate',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        if (isDownloaded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.green.shade300,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Downloaded',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (isDownloading && !isDownloaded && downloadProgress < 1.0) ...[
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
                    : isDownloaded
                        ? const Icon(Icons.file_open_outlined, color: Colors.teal)
                        : const Icon(Icons.download_outlined, color: Colors.blue),
                tooltip: isDownloaded ? 'Open File' : 'Download File',
                onPressed: isDownloading
                    ? null
                    : isDownloaded
                        ? onOpen
                        : onDownload,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete File',
                onPressed: onDelete,
              ),
            ],
          ),
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
