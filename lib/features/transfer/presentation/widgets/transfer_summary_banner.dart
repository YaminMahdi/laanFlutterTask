import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../notifiers/transfer_queue_notifier.dart';

class TransferSummaryBanner extends ConsumerWidget {
  const TransferSummaryBanner({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTransfers = ref.watch(activeTransfersProvider);
    final aggregateProgress = ref.watch(aggregateProgressProvider);

    if (activeTransfers.isEmpty) {
      return const SizedBox.shrink();
    }

    final count = activeTransfers.length;
    final pct = (aggregateProgress * 100).round();

    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.primary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$count active ${count == 1 ? 'transfer' : 'transfers'} in background',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
              if (aggregateProgress < 1.0) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: aggregateProgress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

final aggregateProgressProvider = Provider<double>((ref) {
  final active = ref.watch(activeTransfersProvider);
  if (active.isEmpty) return 0.0;
  final totalBytes = active.fold<int>(0, (sum, t) => sum + t.totalBytes);
  final transferredBytes =
      active.fold<int>(0, (sum, t) => sum + t.bytesTransferred);
  if (totalBytes <= 0) return 0.0;
  return (transferredBytes / totalBytes).clamp(0.0, 1.0);
});

@Preview(name: 'Transfer Summary Banner Preview')
Widget transferSummaryBannerPreview() {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: Material(
        color: const Color(0xFF1E3A8A),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '2 active transfers in background',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '68%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const LinearProgressIndicator(
                value: 0.68,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 3,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
