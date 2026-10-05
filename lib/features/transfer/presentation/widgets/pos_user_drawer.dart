import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/auth_notifier.dart';

class PosUserDrawer extends ConsumerWidget {
  const PosUserDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of LAAN POS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.router.replace(const SignInRoute());
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final username = authState.username ?? 'Operator';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              accountName: Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              accountEmail: const Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.greenAccent),
                  SizedBox(width: 4),
                  Text('Active POS Terminal Session'),
                ],
              ),
            ),
            // Navigation Links
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Upload Module'),
              selected: currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('Catalog & Downloads'),
              selected: currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Transfer Queue'),
              selected: currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(2);
              },
            ),
            const Divider(),
            // System info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connected Gateway',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'http://15.232.228.139',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Divider(),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onTap: () => _handleLogout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
