import 'dart:async'; // Import needed for StreamSubscription

import 'package:blood_donation/feathers/authentication/presentation/screens/lib/feathers/user_managment/presentation/screens/account_screen.dart';
import 'package:blood_donation/feathers/authentication/presentation/screens/registration_screen.dart';
import 'package:blood_donation/feathers/authentication/presentation/screens/sign_in_screen.dart';
import 'package:blood_donation/feathers/user_managment/presentation/screens/blood_group_selected_screen.dart';
// Assuming RegisterScreen exists or you'll add it
// import 'package:blood_donation/feathers/authentication/presentation/screens/register_screen.dart';
import 'package:blood_donation/feathers/user_managment/presentation/screens/main_screen.dart';
// Removed GoRouterRefreshStream import, will define it below or assume it exists correctly
// import 'package:blood_donation/routes/go_router_refresh_stream.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import needed for ChangeNotifier
import 'package:flutter/material.dart'; // Import needed for Placeholder Screen
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../splash/splash_screen.dart'; // Assuming splash_screen.dart exists

part 'routes.g.dart';

// --- Define AppRoutes Enum ---
// Using enum values as route paths directly can sometimes be convenient,
// but using them for names and defining paths separately is often clearer.
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

// --- Placeholder for RegisterScreen (if you haven't created it) ---
// Remove this if you have your actual RegisterScreen
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Register')),
        body: const Center(child: Text('Register Screen Placeholder')),
      );
}

// --- Firebase Auth Provider ---
// Keep this as it is
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// --- GoRouterRefreshStream (Standard Implementation) ---
// Include this class in your project if 'go_router_refresh_stream.dart' doesn't exist
// Or ensure your existing implementation is similar.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Initial check
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(), // Notify listeners on stream events
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// --- GoRouter Configuration ---
@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  // Define path constants for clarity and consistency
  const splashPath = '/splash';
  const signInPath = '/signIn'; // Standardized path
  const registerPath = '/register';
  const mainPath = '/main';
  const accountpath = '/account';
  const bloodGroupSelectedPath = '/bloodGroupSelected';
  const emailedUsersPath = '/emailedUsers';
  const notificationsPath = '/notifications';

  return GoRouter(
    initialLocation: splashPath,
    debugLogDiagnostics: !kReleaseMode, // Only log in debug mode
    redirect: (BuildContext context, GoRouterState state) {
      // Get the current login status from Firebase Auth
      final isLoggedIn = firebaseAuth.currentUser != null;

      // Get the location the user is trying to access using matchedLocation
      final goingToLocation = state.matchedLocation;

      // Define which routes are part of the authentication flow (accessible when logged out)
      final isGoingToAuthFlow =
          goingToLocation == signInPath || goingToLocation == registerPath;

      // Define the splash route
      final isGoingToSplash = goingToLocation == splashPath;

      // --- Redirection Logic ---

      // 1. If the app is still showing the splash screen, do nothing here.
      //    The splash screen itself should handle navigation after loading/initialization.
      if (isGoingToSplash) {
        return null; // Allow navigation to splash screen
      }

      // 2. If the user is logged in:
      if (isLoggedIn) {
        // If they are trying to access SignIn or Register, redirect them to Main.
        if (isGoingToAuthFlow) {
          return mainPath;
        }
        // Otherwise, allow navigation (they are accessing Main or other authenticated routes).
        return null;
      }
      // 3. If the user is logged out:
      else {
        // If they are trying to access a route other than SignIn, Register, or Splash,
        // redirect them to the SignIn screen.
        if (!isGoingToAuthFlow) {
          return signInPath;
        }
        // Otherwise, allow navigation (they are going to SignIn or Register).
        return null;
      }
    },
    // Listen to Firebase auth state changes to trigger redirection checks
    refreshListenable: GoRouterRefreshStream(firebaseAuth.authStateChanges()),
    routes: [
      GoRoute(
        name: AppRoutes.splash.name, // Use enum for name
        path: splashPath, // Use constant
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.signIn.name, // Use enum for name
        path: signInPath, // Use constant and CORRECTED path
        builder: (context, state) => const SignInScreen(),
      ),
      // Add the Register route
      GoRoute(
        name: AppRoutes.register.name, // Use enum for name
        path: registerPath, // Use constant
        builder: (context, state) {
          final type = state.extra as String;
          return RegistrationScreen(type);
        }, // Use placeholder or your actual screen
      ),
      GoRoute(
        name: AppRoutes.main.name, // Use enum for name
        path: mainPath, // Use constant
        builder: (context, state) => const MainScreen(),
        // Define nested routes for '/main/...' if needed
        routes: [
          GoRoute(
            name: AppRoutes.bloodGroupSelected.name,
            path: 'bloodGroupSelected', // Relative path: /main/account
            builder: (context, state) {
              final bloodGroup = state.extra as String;
              return BloodGroupSelectedScreen(bloodGroup);
            },
          ),
           GoRoute(
        name: AppRoutes.account.name, // Use enum for name
        path: accountpath, // Use constant and CORRECTED path
        builder: (context, state) => const AccountScreen(),
      ),
        ],
      ),
    ],
    // Optional: Error handler page
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
