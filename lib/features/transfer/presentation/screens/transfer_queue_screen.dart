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

    final filtered = allTransfers.where((t) {
      if (_selectedFilter == 'active') return t.status.isActive;
      if (_selectedFilter == 'completed') return t.status.isCompleted;
      if (_selectedFilter == 'paused') return t.status.isPaused;
      if (_selectedFilter == 'failed') return t.status.isFailed;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Queue & History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Clear Finished Transfers',
            onPressed: () => notifier.clearCompleted(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All (${allTransfers.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'active',
                    'Active (${allTransfers.where((t) => t.status.isActive).length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'paused',
                    'Paused (${allTransfers.where((t) => t.status.isPaused).length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'completed',
                    'Done (${allTransfers.where((t) => t.status.isCompleted).length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'failed',
                    'Failed (${allTransfers.where((t) => t.status.isFailed).length})',
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No transfers found in this filter',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = key),
    );
  }
}
