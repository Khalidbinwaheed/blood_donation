import 'package:blood_donation/feathers/user_managment/presentation/screens/main_screen.dart';
import 'package:flutter/cupertino.dart';
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
        path: '/splash',
        name: AppRoutes.splash.name,
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/main',
        name: AppRoutes.splash.name,
        builder: (ctx, state) => const MainScreen(),
      ),
     
    ],
  );
}
