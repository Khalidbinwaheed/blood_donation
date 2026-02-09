import 'package:blood_donation/features/user_managment/data/auth_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
              context.go('/auth/sign-in');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (Visible on larger screens, could be drawer on mobile)
          if (MediaQuery.of(context).size.width > 800)
            Container(
              width: 250,
              color: Colors.blueGrey[800],
              child: ListView(
                children: const [
                  const _SidebarItem(
                      icon: Icons.dashboard, title: 'Overview', isActive: true),
                  const _SidebarItem(icon: Icons.people, title: 'Users'),
                  const _SidebarItem(icon: Icons.analytics, title: 'Analytics'),
                  const _SidebarItem(icon: Icons.settings, title: 'Settings'),
                ],
              ),
            ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Overview',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  const Row(
                    children: [
                      _StatsCard(
                        title: 'Total Users',
                        value: '1,234',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 16),
                      _StatsCard(
                        title: 'Active Requests',
                        value: '56',
                        icon: Icons.emergency,
                        color: Colors.red,
                      ),
                      SizedBox(width: 16),
                      _StatsCard(
                        title: 'Donations Today',
                        value: '12',
                        icon: Icons.bloodtype,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // User Management Section
                  Text(
                    'User Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: ListView.separated(
                        itemCount: 10, // Mock data
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                                child: Text('U${index + 1}')), // Initials
                            title: Text('User Name ${index + 1}'),
                            subtitle: Text('user${index + 1}@example.com'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () {
                                    // Verify User Logic
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.block,
                                      color: Colors.red),
                                  onPressed: () {
                                    // Ban User Logic
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const _SidebarItem(
      {required this.icon, required this.title, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isActive ? Colors.blueGrey[700] : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        onTap: () {},
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 30),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}
