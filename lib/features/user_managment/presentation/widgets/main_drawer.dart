import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/home/presentation/home_providers.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final currentFilter = ref.watch(bloodGroupFilterProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Fallback/Guest Drawer
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: AppStyle.mainColor),
                  child: Center(
                    child: Text(
                      'Welcome',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Sign In'),
                  onTap: () => context.goNamed(AppRoutes.signIn.name),
                ),
              ],
            ),
          );
        }
        return Drawer(
          child: Column(
            children: [
              _buildHeader(user),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Dashboard Option
                    ListTile(
                      leading: Icon(
                        Icons.dashboard_rounded,
                        color: currentFilter == null
                            ? AppStyle.mainColor
                            : Colors.grey,
                      ),
                      title: Text(
                        'Dashboard / All',
                        style: TextStyle(
                          fontWeight: currentFilter == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: currentFilter == null
                              ? AppStyle.mainColor
                              : Colors.black,
                        ),
                      ),
                      selected: currentFilter == null,
                      selectedTileColor:
                          AppStyle.mainColor.withValues(alpha: 0.1),
                      onTap: () {
                        ref.read(bloodGroupFilterProvider.notifier).state =
                            null;
                        Navigator.pop(context); // Close drawer
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        'Filter by Blood Group',
                        style: AppStyle.normalTextStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Blood Group List directly in drawer
                    ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map((group) {
                      final isSelected = currentFilter == group;
                      return ListTile(
                        leading: Icon(
                          Icons.water_drop,
                          color: isSelected ? AppStyle.mainColor : Colors.grey,
                        ),
                        title: Text(
                          group,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                isSelected ? AppStyle.mainColor : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor:
                            AppStyle.mainColor.withValues(alpha: 0.1),
                        trailing: isSelected
                            ? const Icon(Icons.check,
                                color: AppStyle.mainColor, size: 20)
                            : null,
                        onTap: () {
                          ref.read(bloodGroupFilterProvider.notifier).state =
                              group;
                          Navigator.pop(context); // Close drawer
                        },
                      );
                    }),
                    const Divider(),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        'Actions',
                        style: AppStyle.normalTextStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications_rounded,
                      text: 'Notifications',
                      onTap: () =>
                          context.goNamed(AppRoutes.notifications.name),
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_rounded,
                      text: 'Settings',
                      onTap: () => context.goNamed(AppRoutes.settings.name),
                    ),
                    _buildDrawerItem(
                      icon: Icons.person_rounded,
                      text: 'My Account',
                      onTap: () => context.goNamed(AppRoutes.account.name),
                    ),
                    const Divider(),
                    _buildDrawerItem(
                      icon: Icons.info_outline_rounded,
                      text: 'About Us',
                      onTap: () => context.goNamed(AppRoutes.about.name),
                    ),
                    _buildDrawerItem(
                      icon: Icons.share_rounded,
                      text: 'Share',
                      onTap: () async {
                        await SharePlus.instance.share(
                          ShareParams(
                            text:
                                'Check out this app to find blood donors and help save lives! [App Link Placeholder]',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.grey),
                      title: const Text('Sign Out'),
                      onTap: () {
                        ref.read(authRepositoryProvider).signOut();
                        context.goNamed(AppRoutes.signIn.name);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Drawer(child: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Drawer(child: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildHeader(AppUser userData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        color: AppStyle.mainColor, // Fallback
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD32F2F), // Main Red
            Color(0xFFEF5350), // Lighter Red
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/logo.png'),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '${userData.firstName ?? ''} ${userData.lastName ?? ''}'.trim(),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            userData.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppStyle.mainColor),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 10,
    );
  }
}
