import 'package:blood_donation/feathers/user_managment/presentation/screens/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../splash/splash_screen.dart';
part 'routes.g.dart';

enum AppRoutes {
  splash,
  main,
  signin,
  register,
  account,
  bloodGroupSelected,
  emailedUsers,
  notifications,
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'main',
        path: '/main',
        builder: (ctx, state) => const MainScreen(),
      ),
    ],
  );
}
