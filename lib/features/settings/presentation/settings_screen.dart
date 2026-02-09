import 'package:blood_donation/features/settings/presentation/widgets/theme_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const ThemeSelector(),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Notifications'),
                _buildSwitchTile('Urgent Blood Alerts',
                    'Get notified for nearby emergencies', true, (val) {}),
                _buildSwitchTile('24h Reminder',
                    'Remind me before appointments', false, (val) {}),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'Account'),
                _buildListTile(
                    context, 'Edit Blood Group', Icons.bloodtype, () {}),
                _buildListTile(context, 'Sign Out', Icons.logout, () {
                  // TODO: Implement sign out logic
                }, isDestructive: true),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
