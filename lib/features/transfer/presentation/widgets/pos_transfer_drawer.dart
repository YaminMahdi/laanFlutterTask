import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/transfer_queue_notifier.dart';
import 'transfer_progress_card.dart';

class PosTransferDrawer extends ConsumerStatefulWidget {
  const PosTransferDrawer({super.key});

  @override
  ConsumerState<PosTransferDrawer> createState() => _PosTransferDrawerState();
}

class _PosTransferDrawerState extends ConsumerState<PosTransferDrawer> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final allTransfers = ref.watch(transferQueueProvider);
    final notifier = ref.read(transferQueueProvider.notifier);

    final filteredTransfers = allTransfers.where((t) {
      if (_selectedFilter == 'active') return t.status.isActive;
      if (_selectedFilter == 'completed') return t.status.isCompleted;
      if (_selectedFilter == 'failed') return t.status.isFailed;
      return true;
    }).toList();

    return Drawer(
      width: 420,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                children: [
                  const Icon(Icons.sync_alt, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Transfer Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    icon: const Icon(Icons.cleaning_services, size: 16),
                    label: const Text('Clear', style: TextStyle(fontSize: 12)),
                    onPressed: () => notifier.clearCompleted(),
                  ),
                ],
              ),
            ),
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All (${allTransfers.length})'),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      'active',
                      'Active (${allTransfers.where((t) => t.status.isActive).length})',
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      'completed',
                      'Done (${allTransfers.where((t) => t.status.isCompleted).length})',
                    ),
                    const SizedBox(width: 6),
                    _buildFilterChip(
                      'failed',
                      'Failed (${allTransfers.where((t) => t.status.isFailed).length})',
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Transfers list
            Expanded(
              child: filteredTransfers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No transfers in this view',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTransfers.length,
                      itemBuilder: (context, index) {
                        final task = filteredTransfers[index];
                        return TransferProgressCard(
                          task: task,
                          onPause: () => notifier.pause(task.id),
                          onResume: () => notifier.resume(task.id),
                          onCancel: () => notifier.cancel(task.id),
                          onRetry: () => notifier.retry(task.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade700,
      ),
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }
}
