import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../notifiers/file_list_notifier.dart';
import '../notifiers/transfer_queue_notifier.dart';
import '../widgets/pos_user_drawer.dart';
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
  DateTime? _lastBackPressTime;

  final List<Widget> _screens = const [
    UploadScreen(),
    DownloadScreen(),
    TransferQueueScreen(),
  ];

  final List<String> _titles = const [
    'POS File Upload',
    'Catalog & Downloads',
    'Transfer Manager'
  ];

  void _onDestinationSelected(int index) {
    if (index == 1) {
      ref.read(fileListProvider.notifier).refresh();
    }
    setState(() => _currentIndex = index);
  }

  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    if (didPop) return;

    // 1. If left drawer (User Profile) is open, close it
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }

    // 2. If on secondary tab, return to primary Upload tab
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    // 4. Double-tap back within 2 seconds to exit POS app
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit POS'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final activeTransfers = ref.watch(activeTransfersProvider);
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!next.isLoggedIn && (previous?.isLoggedIn ?? false)) {
        context.router.replace(const SignInRoute());
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= largeScreenMinWidth;

          return Scaffold(
            key: _scaffoldKey,
            drawer: const PosUserDrawer(),
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open POS Menu',
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[_currentIndex],
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  Text(
                    'Operator: ${authState.username ?? 'Operator'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              actions: [
                if (_currentIndex == 2)
                  IconButton(
                    icon: const Icon(Icons.cleaning_services_outlined),
                    tooltip: 'Clear Finished Transfers',
                    onPressed: () =>
                        ref.read(transferQueueProvider.notifier).clearCompleted(),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: isLargeScreen
                        ? _buildTabletLayout()
                        : _screens[_currentIndex],
                  ),
                  // Persistent floating summary banner accessible on other tabs
                  if (_currentIndex != 2)
                    TransferSummaryBanner(
                      onTap: () {
                        setState(() => _currentIndex = 2);
                      },
                    ),
                ],
              ),
            ),
            bottomNavigationBar: isLargeScreen
                ? null
                : SafeArea(
                    top: false,
                    child: NavigationBar(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _onDestinationSelected,
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
                          label: 'Transfers',
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
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
              label: Text('Transfers'),
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
