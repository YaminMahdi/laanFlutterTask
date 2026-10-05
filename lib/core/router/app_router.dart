import 'package:auto_route/auto_route.dart';
import '../../features/transfer/presentation/screens/dashboard_screen.dart';
import '../../features/transfer/presentation/screens/download_screen.dart';
import '../../features/transfer/presentation/screens/transfer_queue_screen.dart';
import '../../features/transfer/presentation/screens/upload_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: DashboardRoute.page, initial: true),
        AutoRoute(page: UploadRoute.page),
        AutoRoute(page: DownloadRoute.page),
        AutoRoute(page: TransferQueueRoute.page),
      ];
}
