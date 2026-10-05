import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/transfer_type.dart';
import '../notifiers/transfer_queue_notifier.dart';
import '../widgets/transfer_progress_card.dart';

@RoutePage()
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;
  int _selectedFileSize = 0;
  String? _currentTaskId;
  bool _isPicking = false;
  String? _fileValidationError;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ApiConstants.allowedUploadExtensions,
      );

      if (result.isNotEmpty && result.first.path != null) {
        final filePath = result.first.path!;
        final fileName = p.basename(filePath);

        if (!ApiConstants.isAllowedUploadExtension(fileName)) {
          setState(() {
            _selectedFile = null;
            _selectedFileSize = 0;
            _fileValidationError = ApiConstants.fileTypeNotAllowedMessage;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(ApiConstants.fileTypeNotAllowedMessage),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        final file = File(filePath);
        final size = await file.length();
        setState(() {
          _selectedFile = file;
          _selectedFileSize = size;
          _fileValidationError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _startUpload() async {
    if (_selectedFile == null) return;

    if (!ApiConstants.isAllowedUploadExtension(_selectedFile!.path)) {
      setState(() {
        _fileValidationError = ApiConstants.fileTypeNotAllowedMessage;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiConstants.fileTypeNotAllowedMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    try {
      final notifier = ref.read(transferQueueProvider.notifier);
      final taskId = await notifier.upload(_selectedFile!);
      setState(() {
        _currentTaskId = taskId;
        _fileValidationError = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload started. Will progress in background if minimized.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e is ArgumentError ? e.message.toString() : 'Upload failed: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTransfers = ref.watch(transferQueueProvider);
    final notifier = ref.read(transferQueueProvider.notifier);

    // Find the active or most recent upload task
    final currentUploadTask = _currentTaskId != null
        ? allTransfers.where((t) => t.id == _currentTaskId).firstOrNull
        : allTransfers
            .where((t) => t.type == TransferType.upload)
            .firstOrNull;

    final recentUploads = allTransfers
        .where((t) => t.type == TransferType.upload && t.id != currentUploadTask?.id)
        .take(5)
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.upload_file,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'POS Catalog & Report Upload',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Select large product files (>50MB images, videos, CSV catalogs)',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // File picker zone
                    InkWell(
                      onTap: _isPicking ? null : _pickFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue.shade50.withValues(alpha: 0.4),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isPicking
                                  ? const CircularProgressIndicator()
                                  : Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 44,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedFile != null
                                    ? p.basename(_selectedFile!.path)
                                    : 'Tap here to choose file from device',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFile != null
                                    ? 'Size: ${_formatBytes(_selectedFileSize)}'
                                    : 'Supported: JPG, PNG, PDF, CSV, DOC, XLS, ZIP, JSON, MP4, MP3',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_fileValidationError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _fileValidationError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Start Background Upload'),
                        onPressed: (_selectedFile == null || _fileValidationError != null)
                            ? null
                            : _startUpload,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Current Active Upload Card
            if (currentUploadTask != null) ...[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Current Upload Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TransferProgressCard(
                task: currentUploadTask,
                onPause: () => notifier.pause(currentUploadTask.id),
                onResume: () => notifier.resume(currentUploadTask.id),
                onCancel: () => notifier.cancel(currentUploadTask.id),
                onRetry: () => notifier.retry(currentUploadTask.id),
              ),
            ],
            // Recent Uploads
            if (recentUploads.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Recent Uploads',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...recentUploads.map(
                (task) => TransferProgressCard(
                  task: task,
                  onPause: () => notifier.pause(task.id),
                  onResume: () => notifier.resume(task.id),
                  onCancel: () => notifier.cancel(task.id),
                  onRetry: () => notifier.retry(task.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
