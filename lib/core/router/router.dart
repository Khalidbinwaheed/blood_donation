import 'package:blood_donation/features/authentication/presentation/screens/registration_screen.dart';
import 'package:blood_donation/features/authentication/presentation/screens/sign_in_screen.dart'; // Placeholder
import 'package:blood_donation/features/home/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:blood_donation/features/donor/presentation/donor_home_screen.dart';
import 'package:blood_donation/features/home/presentation/home_screen.dart';
import 'package:blood_donation/features/user_managment/presentation/screens/account_screen.dart';
import 'package:blood_donation/features/user_managment/presentation/screens/add_donor_screen.dart';
import 'package:blood_donation/features/user_managment/presentation/screens/blood_group_selected_screen.dart';
import 'package:blood_donation/features/user_managment/presentation/screens/donor_details_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/notifications_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/donors_emailed_screen.dart';
import 'package:blood_donation/features/settings/presentation/screens/settings_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/about_us_screen.dart';
import 'package:blood_donation/features/appointments/presentation/screens/doctor_dashboard_screen.dart';
import 'package:blood_donation/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/map/presentation/centers_map_screen.dart';
import 'package:blood_donation/features/recipient/presentation/recipient_home_screen.dart';
import 'package:blood_donation/features/recipient/presentation/screens/request_blood_screen.dart';
import 'package:blood_donation/features/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:blood_donation/features/user_managment/presentation/screens/digital_id_screen.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.uri.path == '/auth/sign-in' ||
          state.uri.path == '/auth/register';

      if (!isLoggedIn && !isLoggingIn) return '/auth/sign-in';
      if (!isLoggedIn && !isLoggingIn) return '/auth/sign-in';

      if (isLoggedIn) {
        final user = authState.value;
        if (state.uri.path == '/auth/sign-in' ||
            state.uri.path == '/auth/register') {
          if (user?.role == 'admin') return '/admin-dashboard';
          if (user?.role == 'doctor') return '/doctor-dashboard';
          return '/home';
        }
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                builder: (context, state) => const CentersMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                name: 'account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) {
          return const RegistrationScreen();
        },
      ),
      GoRoute(
        path: '/donor',
        name: 'donorHub',
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/recipient',
        name: 'recipientHub',
        builder: (context, state) => const RecipientHomeScreen(),
      ),
      // User Management Routes
      GoRoute(
        path: '/add-donor',
        name: 'addDonor',
        builder: (context, state) => const AddDonorScreen(),
      ),
      GoRoute(
        path: '/blood-group/:group',
        name: 'bloodGroupSelected',
        builder: (context, state) {
          final group = state.pathParameters['group']!;
          return BloodGroupSelectedScreen(group);
        },
      ),
      GoRoute(
        path: '/donor-details',
        name: 'donorDetails',
        builder: (context, state) {
          final donor = state.extra as AppUser;
          return DonorDetailsScreen(donor: donor);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/emailed-users',
        name: 'emailedUsers',
        builder: (context, state) => const DonorsEmailedScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/request-blood',
        name: 'requestBlood',
        builder: (context, state) => const RequestBloodScreen(),
      ),
      GoRoute(
        path: '/book-appointment',
        name: 'appointments',
        builder: (context, state) => const BookAppointmentScreen(),
      ),
      GoRoute(
        path: '/digital-id',
        name: 'digitalId',
        builder: (context, state) => const DigitalIdScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        name: 'doctorDashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
