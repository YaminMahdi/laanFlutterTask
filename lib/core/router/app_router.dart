import 'package:auto_route/auto_route.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/transfer/presentation/screens/dashboard_screen.dart';
import '../../features/transfer/presentation/screens/download_screen.dart';
import '../../features/transfer/presentation/screens/transfer_queue_screen.dart';
import '../../features/transfer/presentation/screens/upload_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SignInRoute.page, initial: true),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(page: DashboardRoute.page),
        AutoRoute(page: UploadRoute.page),
        AutoRoute(page: DownloadRoute.page),
        AutoRoute(page: TransferQueueRoute.page),
      ];
}
