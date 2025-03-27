import 'package:blood_donation/feathers/authentication/presentation/screens/sign_in_screen.dart';
import 'package:blood_donation/feathers/user_managment/presentation/screens/main_screen.dart';
import 'package:blood_donation/routes/go_router_refresh_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../splash/splash_screen.dart';
part 'routes.g.dart';

enum AppRoutes {
  splash,
  main,
  signIn,
  register,
  account,
  bloodGroupSelected,
  emailedUsers,
  notifications,
}

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (ctx, state) {
      final isLoggedIn = firebaseAuth.currentUser != null;
      if (isLoggedIn && state.uri.toString() == '/sign in' ||
          state.uri.toString() == '/register') {
        return '/main';
      } else if (!isLoggedIn && state.uri.toString().startsWith('/main')) {
        return '/sign in';
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(firebaseAuth.authStateChanges()),
    routes: [
      GoRoute(
        name: 'splash',
        path: AppRoutes.splash.name,
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'signIn',
        path: AppRoutes.signIn.name,
        builder: (ctx, state) => const SignInScreen(),
      ),
      GoRoute(
        name: 'main',
        path: AppRoutes.main.name,
        builder: (ctx, state) => const MainScreen(),
      ),
    ],
  );
}
