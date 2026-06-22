import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:blood_donation/features/authentication/presentation/screens/registration_screen.dart';
import 'package:blood_donation/features/authentication/presentation/screens/sign_in_screen.dart'; // Placeholder
import 'package:blood_donation/features/authentication/presentation/screens/verification_code_screen.dart';
import 'package:blood_donation/features/home/presentation/widgets/scaffold_with_nav_bar.dart';
import 'package:blood_donation/features/chat/presentation/chat_screen.dart';
import 'package:blood_donation/features/chat/presentation/conversation_screen.dart';
import 'package:blood_donation/features/chat/presentation/inbox_screen.dart';
import 'package:blood_donation/features/appointments/presentation/screens/appointments_overview_screen.dart';
import 'package:blood_donation/features/donor/presentation/donor_home_screen.dart';
import 'package:blood_donation/features/donor/presentation/find_donor_screen.dart';
import 'package:blood_donation/features/donation/presentation/screens/blood_requests_screen.dart';
import 'package:blood_donation/features/donation/presentation/screens/request_post_details_screen.dart';
import 'package:blood_donation/features/home/presentation/home_screen.dart';
import 'package:blood_donation/features/user_management/presentation/screens/account_screen.dart';
import 'package:blood_donation/features/records/presentation/records_screen.dart';
import 'package:blood_donation/features/profile/presentation/profile_screen.dart';
import 'package:blood_donation/features/profile/presentation/profile_setup_screen.dart';
import 'package:blood_donation/features/user_management/presentation/screens/add_donor_screen.dart';
import 'package:blood_donation/features/user_management/presentation/screens/blood_group_selected_screen.dart';
import 'package:blood_donation/features/user_management/presentation/screens/donor_details_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/notifications_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/donors_emailed_screen.dart';
import 'package:blood_donation/features/settings/presentation/settings_screen.dart';
import 'package:blood_donation/features/home/presentation/screens/about_us_screen.dart';
import 'package:blood_donation/features/appointments/presentation/screens/doctor_dashboard_screen.dart';
import 'package:blood_donation/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/map/presentation/centers_map_screen.dart';
import 'package:blood_donation/features/recipient/presentation/recipient_home_screen.dart';
import 'package:blood_donation/features/recipient/presentation/screens/request_blood_screen.dart';
import 'package:blood_donation/features/appointments/presentation/screens/book_appointment_screen.dart';
import 'package:blood_donation/features/user_management/presentation/screens/digital_id_screen.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:blood_donation/features/onboarding/presentation/donate_blood_intro_screen.dart';
import 'package:blood_donation/features/emergency/presentation/emergency_contacts_screen.dart';
import 'package:blood_donation/features/emergency/presentation/emergency_sos_screen.dart';
import 'package:blood_donation/features/doctors/presentation/doctor_profile_screen.dart';
import 'package:blood_donation/features/doctors/presentation/doctors_screen.dart';
import 'package:blood_donation/features/ambulance/presentation/ambulance_request_screen.dart';
import 'package:blood_donation/features/ambulance/presentation/ambulance_tracking_screen.dart';
import 'package:blood_donation/features/iot_health/presentation/bp_monitor_screen.dart';
import 'package:blood_donation/features/iot_health/presentation/heart_monitor_screen.dart';
import 'package:blood_donation/features/community/presentation/articles_screen.dart';
import 'package:blood_donation/features/community/presentation/events_screen.dart';
import 'package:blood_donation/splash/splash_screen.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final role = user?.role.trim().toLowerCase() ?? '';
      final isAdminLike = role == 'admin' || role == 'super_admin';
      final isDoctor = role == 'doctor';
      final path = state.uri.path;
      const authPaths = {
        '/auth/sign-in',
        '/auth/register',
        '/login',
        '/register',
        '/auth/forgot-password',
        '/auth/verification-code',
      };
      final isAuthRoute = authPaths.contains(path);
      const publicPaths = {
        '/home',
        '/map',
        '/about',
        '/splash',
        '/onboarding',
        '/login',
        '/register',
      };

      if (publicPaths.contains(path)) return null;

      if (!isLoggedIn && !isAuthRoute) return '/auth/sign-in';

      if (isLoggedIn) {
        if (path == '/admin-dashboard' && !isAdminLike) {
          return '/home';
        }
        if (path == '/doctor-dashboard' && !isDoctor) {
          return '/home';
        }

        if (isAuthRoute) {
          if (isAdminLike) return '/admin-dashboard';
          if (isDoctor) return '/doctor-dashboard';
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
                name: AppRoutes.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: AppRoutes.chat.name,
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appointments-hub',
                name: AppRoutes.appointmentsHub.name,
                builder: (context, state) => const AppointmentsOverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/records',
                name: AppRoutes.records.name,
                builder: (context, state) => const RecordsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoutes.profile.name,
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/account',
                name: AppRoutes.account.name,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/map',
        name: AppRoutes.map.name,
        builder: (context, state) => const CentersMapScreen(),
      ),
      GoRoute(
        path: '/blood/find-donor',
        name: AppRoutes.bloodFindDonor.name,
        builder: (context, state) => const FindDonorScreen(),
      ),
      GoRoute(
        path: '/blood/donor',
        name: AppRoutes.bloodDonor.name,
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/blood/register-donor',
        name: AppRoutes.bloodRegisterDonor.name,
        builder: (context, state) => const AddDonorScreen(),
      ),
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoutes.onboarding.name,
        builder: (context, state) => const DonateBloodIntroScreen(),
      ),
      GoRoute(
        path: '/auth/sign-in',
        name: AppRoutes.signIn.name,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login.name,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) {
          return const RegistrationScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register.name,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: AppRoutes.profileSetup.name,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: AppRoutes.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/verification-code',
        name: AppRoutes.verificationCode.name,
        builder: (context, state) => VerificationCodeScreen(
          contact: state.uri.queryParameters['contact'],
          method: state.uri.queryParameters['method'],
        ),
      ),
      GoRoute(
        path: '/donor',
        name: AppRoutes.donorHub.name,
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/recipient',
        name: AppRoutes.recipientHub.name,
        builder: (context, state) => const RecipientHomeScreen(),
      ),
      GoRoute(
        path: '/blood/recipient',
        name: AppRoutes.bloodRecipient.name,
        builder: (context, state) => const RecipientHomeScreen(),
      ),
      // User Management Routes
      GoRoute(
        path: '/add-donor',
        name: AppRoutes.addDonor.name,
        builder: (context, state) => const AddDonorScreen(),
      ),
      GoRoute(
        path: '/blood-group/:group',
        name: AppRoutes.bloodGroupSelected.name,
        builder: (context, state) {
          final group = state.pathParameters['group']!;
          return BloodGroupSelectedScreen(group);
        },
      ),
      GoRoute(
        path: '/donor-details',
        name: AppRoutes.donorDetails.name,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is AppUser) {
            return DonorDetailsScreen(donor: extra);
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Profile Details')),
            body: Center(
              child: FilledButton.tonal(
                onPressed: () => context.goNamed(AppRoutes.home.name),
                child: const Text('Go Home'),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoutes.notifications.name,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/emailed-users',
        name: AppRoutes.emailedUsers.name,
        builder: (context, state) => const DonorsEmailedScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings.name,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: AppRoutes.about.name,
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/request-blood',
        name: AppRoutes.requestBlood.name,
        builder: (context, state) => const RequestBloodScreen(),
      ),
      GoRoute(
        path: '/blood/request',
        builder: (context, state) => const RequestBloodScreen(),
      ),
      GoRoute(
        path: '/emergency/sos',
        name: AppRoutes.emergencySos.name,
        builder: (context, state) => const EmergencySosScreen(),
      ),
      GoRoute(
        path: '/emergency/contacts',
        name: AppRoutes.emergencyContacts.name,
        builder: (context, state) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: '/doctors',
        name: AppRoutes.doctors.name,
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: '/doctor-profile',
        name: AppRoutes.doctorProfile.name,
        builder: (context, state) {
          final extra = state.extra;
          return DoctorProfileScreen(doctor: extra is AppUser ? extra : null);
        },
      ),
      GoRoute(
        path: '/ambulance/request',
        name: AppRoutes.ambulanceRequest.name,
        builder: (context, state) => const AmbulanceRequestScreen(),
      ),
      GoRoute(
        path: '/ambulance/tracking',
        name: AppRoutes.ambulanceTracking.name,
        builder: (context, state) => AmbulanceTrackingScreen(
          requestId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: '/iot/heart-monitor',
        name: AppRoutes.heartMonitor.name,
        builder: (context, state) => const HeartMonitorScreen(),
      ),
      GoRoute(
        path: '/iot/bp-monitor',
        name: AppRoutes.bpMonitor.name,
        builder: (context, state) => const BpMonitorScreen(),
      ),
      GoRoute(
        path: '/community/articles',
        name: AppRoutes.communityArticles.name,
        builder: (context, state) => const CommunityArticlesScreen(),
      ),
      GoRoute(
        path: '/community/events',
        name: AppRoutes.communityEvents.name,
        builder: (context, state) => const CommunityEventsScreen(),
      ),
      GoRoute(
        path: '/request-feed',
        name: AppRoutes.requestFeed.name,
        builder: (context, state) => const BloodRequestsScreen(),
      ),
      GoRoute(
        path: '/request-post/:id',
        name: AppRoutes.requestPostDetails.name,
        builder: (context, state) {
          final requestId = state.pathParameters['id'] ?? '';
          if (requestId.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Post Details')),
              body: const Center(child: Text('Invalid request route.')),
            );
          }
          final extra = state.extra;
          final initial = extra is Map<String, dynamic> ? extra : null;
          return RequestPostDetailsScreen(
            requestId: requestId,
            initialData: initial,
          );
        },
      ),
      GoRoute(
        path: '/inbox',
        name: AppRoutes.inbox.name,
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: '/conversation/:peerId',
        name: AppRoutes.conversation.name,
        builder: (context, state) {
          final peerId = state.pathParameters['peerId'] ?? '';
          final peerName = state.uri.queryParameters['name'] ?? 'User';
          return ConversationScreen(
            peerId: peerId,
            peerName: peerName,
          );
        },
      ),
      GoRoute(
        path: '/book-appointment',
        name: AppRoutes.appointments.name,
        builder: (context, state) => const BookAppointmentScreen(),
      ),
      GoRoute(
        path: '/digital-id',
        name: AppRoutes.digitalId.name,
        builder: (context, state) => const DigitalIdScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        name: AppRoutes.doctorDashboard.name,
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        name: AppRoutes.adminDashboard.name,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
