import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/transfer_queue_notifier.dart';
import '../widgets/transfer_progress_card.dart';

@RoutePage()
class TransferQueueScreen extends ConsumerStatefulWidget {
  const TransferQueueScreen({super.key});

  @override
  ConsumerState<TransferQueueScreen> createState() => _TransferQueueScreenState();
}

class _TransferQueueScreenState extends ConsumerState<TransferQueueScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final allTransfers = ref.watch(transferQueueProvider);
    final notifier = ref.read(transferQueueProvider.notifier);
    final aggregateProgress = ref.watch(aggregateTransferProgressProvider);

    final activeCount = allTransfers.where((t) => t.status.isActive).length;
    final pausedCount = allTransfers.where((t) => t.status.isPaused).length;
    final completedCount = allTransfers.where((t) => t.status.isCompleted).length;
    final failedCount = allTransfers.where((t) => t.status.isFailed).length;

    final filtered = allTransfers.where((t) {
      if (_selectedFilter == 'active') return t.status.isActive;
      if (_selectedFilter == 'paused') return t.status.isPaused;
      if (_selectedFilter == 'completed') return t.status.isCompleted;
      if (_selectedFilter == 'failed') return t.status.isFailed;
      return true;
    }).toList();

    final canPop = ModalRoute.of(context)?.canPop ?? false;

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          children: [
            // Status overview & quick batch action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    children: [
                      // Stat counters row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context: context,
                            label: 'Active',
                            count: activeCount,
                            color: Colors.blueAccent,
                            icon: Icons.sync,
                            isSelected: _selectedFilter == 'active',
                            onTap: () => setState(() => _selectedFilter = 'active'),
                          ),
                          _buildStatItem(
                            context: context,
                            label: 'Paused',
                            count: pausedCount,
                            color: Colors.amber.shade700,
                            icon: Icons.pause_circle_outline,
                            isSelected: _selectedFilter == 'paused',
                            onTap: () => setState(() => _selectedFilter = 'paused'),
                          ),
                          _buildStatItem(
                            context: context,
                            label: 'Done',
                            count: completedCount,
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                            isSelected: _selectedFilter == 'completed',
                            onTap: () => setState(() => _selectedFilter = 'completed'),
                          ),
                          _buildStatItem(
                            context: context,
                            label: 'Failed',
                            count: failedCount,
                            color: Colors.redAccent,
                            icon: Icons.error_outline,
                            isSelected: _selectedFilter == 'failed',
                            onTap: () => setState(() => _selectedFilter = 'failed'),
                          ),
                        ],
                      ),
                      // Batch operations row (Pause All / Resume All / Clear Done)
                      if (activeCount > 0 || pausedCount > 0 || completedCount > 0) ...[
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (activeCount > 0)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: Colors.amber.shade800,
                                ),
                                icon: const Icon(Icons.pause, size: 16),
                                label: const Text('Pause All', style: TextStyle(fontSize: 12)),
                                onPressed: () => notifier.pauseAll(),
                              ),
                            if (pausedCount > 0)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: Colors.blueAccent,
                                ),
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Resume All', style: TextStyle(fontSize: 12)),
                                onPressed: () => notifier.resumeAll(),
                              ),
                            if (completedCount > 0)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: Colors.grey.shade700,
                                ),
                                icon: const Icon(Icons.cleaning_services_outlined, size: 16),
                                label: const Text('Clear Done', style: TextStyle(fontSize: 12)),
                                onPressed: () => notifier.clearCompleted(),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Active aggregate progress bar
            if (activeCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$activeCount active transfer${activeCount > 1 ? 's' : ''} in progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(aggregateProgress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (aggregateProgress < 1.0) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: aggregateProgress > 0 ? aggregateProgress : null,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All (${allTransfers.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('active', 'Active ($activeCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('paused', 'Paused ($pausedCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('completed', 'Done ($completedCount)'),
                    const SizedBox(width: 8),
                    _buildFilterChip('failed', 'Failed ($failedCount)'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Transfers List or Empty State
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(allTransfers.isEmpty)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
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

    if (canPop) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Transfer Manager'),
          actions: [
            if (completedCount > 0)
              IconButton(
                icon: const Icon(Icons.cleaning_services_outlined),
                tooltip: 'Clear Finished Transfers',
                onPressed: () => notifier.clearCompleted(),
              ),
          ],
        ),
        body: content,
      );
    }

    return Scaffold(
      body: content,
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade600,
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
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
      ),
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }

  Widget _buildEmptyState(bool isQueueEmpty) {
    if (isQueueEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horizontal_circle_outlined,
                  size: 52,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Transfers in Queue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start a catalog upload or file download to track real-time transfer progress here.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No $_selectedFilter transfers',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Switch filter or tap below to view all items.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() => _selectedFilter = 'all'),
              child: const Text('View All Transfers'),
            ),
          ],
        ),
      ),
    );
  }
}
