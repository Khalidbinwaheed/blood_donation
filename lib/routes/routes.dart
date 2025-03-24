import 'package:go_router/go_router.dart';

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

GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash.name,
        builder: (ctx, state) => const SplashScreen(),
      ),
    ],
  );
}
