import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/transfer/presentation/providers/transfer_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database
  final database = await AppDatabase.create();

  // Initialize system tray notification service
  await NotificationService.instance.initialize(
    onNotificationTapped: (payload) {
      // Tapping notification brings app to foreground and can navigate
    },
  );

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const LaanPosApp(),
    ),
  );
}

class LaanPosApp extends ConsumerStatefulWidget {
  const LaanPosApp({super.key});

  @override
  ConsumerState<LaanPosApp> createState() => _LaanPosAppState();
}

class _LaanPosAppState extends ConsumerState<LaanPosApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LAAN POS Transfer Module',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _appRouter.config(),
    );
  }
}
