import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../notifiers/transfer_queue_notifier.dart';
import '../widgets/pos_transfer_drawer.dart';
import '../widgets/transfer_summary_banner.dart';
import 'download_screen.dart';
import 'transfer_queue_screen.dart';
import 'upload_screen.dart';

const double largeScreenMinWidth = 600.0;

@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    UploadScreen(),
    DownloadScreen(),
    TransferQueueScreen(),
  ];

  final List<String> _titles = const [
    'POS File Upload',
    'Catalog & Downloads',
    'Transfer Queue',
  ];

  @override
  Widget build(BuildContext context) {
    final activeTransfers = ref.watch(activeTransfersProvider);
    final authState = ref.watch(authNotifierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= largeScreenMinWidth;

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: const PosTransferDrawer(),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titles[_currentIndex],
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Text(
                  'Logged in as: ${authState.username ?? 'mahdi'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              // Transfer queue button with badge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sync_alt),
                    tooltip: 'Transfer Manager',
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                  if (activeTransfers.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${activeTransfers.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: isLargeScreen
                    ? _buildTabletLayout()
                    : _screens[_currentIndex],
              ),
              // Persistent floating summary banner accessible anywhere in the app
              TransferSummaryBanner(
                onTap: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
          bottomNavigationBar: isLargeScreen
              ? null
              : NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.cloud_upload_outlined),
                      selectedIcon: Icon(Icons.cloud_upload),
                      label: 'Upload',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.cloud_download_outlined),
                      selectedIcon: Icon(Icons.cloud_download),
                      label: 'Downloads',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: activeTransfers.isNotEmpty,
                        label: Text('${activeTransfers.length}'),
                        child: const Icon(Icons.list_alt_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: activeTransfers.isNotEmpty,
                        label: Text('${activeTransfers.length}'),
                        child: const Icon(Icons.list_alt),
                      ),
                      label: 'Queue',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          labelType: NavigationRailLabelType.all,
          leading: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Icon(Icons.point_of_sale, size: 36, color: Color(0xFF1E3A8A)),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.cloud_upload_outlined),
              selectedIcon: Icon(Icons.cloud_upload),
              label: Text('Upload'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.cloud_download_outlined),
              selectedIcon: Icon(Icons.cloud_download),
              label: Text('Catalog'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: Text('Queue'),
            ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _screens[_currentIndex],
        ),
      ],
    );
  }
}
