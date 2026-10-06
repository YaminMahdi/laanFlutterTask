import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'core/database/app_database.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/public_download_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/transfer/presentation/providers/transfer_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system UI styling
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Initialize SQLite database
  final database = await AppDatabase.create();

  // Initialize system tray notification service
  await NotificationService.instance.initialize(
    onNotificationTapped: (payload) async {
      // Tapping notification opens file with system chooser if payload is a file path
      if (payload != null && payload.isNotEmpty) {
        var path = payload;
        if (!await File(path).exists() && Platform.isAndroid) {
          final resolved = await PublicDownloadStorage.resolveLocalPath(uriOrPath: path);
          if (resolved != null && await File(resolved).exists()) {
            path = resolved;
          }
        }
        final file = File(path);
        if (await file.exists()) {
          await OpenFilex.open(path);
        }
      }
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
      routerConfig: _appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),
    );
  }
}
