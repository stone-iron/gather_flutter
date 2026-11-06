import 'package:go_router/go_router.dart';
import '../features/live/presentation/screens/live_watch_screen.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/group_buy/presentation/screens/group_buy_detail_screen.dart';
import '../features/navigation/presentation/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/live/:broadcastId',
      builder: (context, state) {
        final broadcastId = int.parse(
          state.pathParameters['broadcastId']!,
        );

        return LiveWatchScreen(
          broadcastId: broadcastId,
        );
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/products/:productId',
      builder: (context, state) {
        final productId = int.parse(
          state.pathParameters['productId']!,
        );

        return GroupBuyDetailScreen(
          productId: productId,
        );
      },
    ),
  ],
);