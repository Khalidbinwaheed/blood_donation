import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/authentication/presentation/widgets/blood_group_selector.dart';
import 'package:blood_donation/features/settings/data/app_settings_provider.dart';
import 'package:blood_donation/features/settings/presentation/widgets/theme_selector.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:blood_donation/features/user_management/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _ambulanceController = TextEditingController();
  bool _isSavingPrefs = false;

  @override
  void dispose() {
    _ambulanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final notificationPrefsAsync = user == null
        ? null
        : ref.watch(userNotificationPrefsProvider(user.uid));

    if (_ambulanceController.text != appSettings.ambulanceNumber) {
      _ambulanceController.text = appSettings.ambulanceNumber;
    }

    final urgentAlerts = notificationPrefsAsync?.valueOrNull?.urgentAlerts ?? true;
    final appointmentReminders =
        notificationPrefsAsync?.valueOrNull?.appointmentReminders ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.home.name);
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const ThemeSelector(),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Notifications'),
                _buildSwitchTile(
                  title: 'Urgent Blood Alerts',
                  subtitle: 'Get notified for nearby emergencies',
                  value: urgentAlerts,
                  enabled: user != null && !_isSavingPrefs,
                  onChanged: user == null
                      ? null
                      : (val) => _saveNotificationPrefs(
                            uid: user.uid,
                            urgentAlerts: val,
                            appointmentReminders: appointmentReminders,
                          ),
                ),
                _buildSwitchTile(
                  title: 'Appointment Reminders',
                  subtitle: 'Receive reminder before scheduled appointment',
                  value: appointmentReminders,
                  enabled: user != null && !_isSavingPrefs,
                  onChanged: user == null
                      ? null
                      : (val) => _saveNotificationPrefs(
                            uid: user.uid,
                            urgentAlerts: urgentAlerts,
                            appointmentReminders: val,
                          ),
                ),
                _buildSwitchTile(
                  title: 'Show Local News First',
                  subtitle: 'Prioritize local health alerts in home feed',
                  value: appSettings.showLocalNewsFirst,
                  onChanged: (val) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setShowLocalNewsFirst(val);
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      TextField(
                        controller: _ambulanceController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Default Ambulance Number',
                          hintText: '1122',
                        ),
                        onSubmitted: (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setAmbulanceNumber(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonal(
                          onPressed: () {
                            ref
                                .read(appSettingsProvider.notifier)
                                .setAmbulanceNumber(_ambulanceController.text);
                          },
                          child: const Text('Save Number'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Legal'),
                _buildListTile(
                  context,
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                  AppEnv.hasPrivacyPolicy ? _openPrivacyPolicy : null,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Account'),
                _buildListTile(
                  context,
                  'Edit Blood Group',
                  Icons.bloodtype,
                  user == null ? null : () => _editBloodGroup(context, user),
                ),
                _buildListTile(
                  context,
                  'Sign Out',
                  Icons.logout,
                  _signOut,
                  isDestructive: true,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotificationPrefs({
    required String uid,
    required bool urgentAlerts,
    required bool appointmentReminders,
  }) async {
    setState(() => _isSavingPrefs = true);
    try {
      await ref.read(userProfileRepositoryProvider).updateNotificationPrefs(
            uid: uid,
            prefs: UserNotificationPrefs(
              urgentAlerts: urgentAlerts,
              appointmentReminders: appointmentReminders,
            ),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save preferences: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPrefs = false);
      }
    }
  }

  Future<void> _editBloodGroup(BuildContext context, dynamic user) async {
    var selected = (user.bloodGroup ?? 'O+').toString().trim();
    if (selected.isEmpty) {
      selected = 'O+';
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update blood group'),
              content: BloodGroupSelector(
                selectedGroup: selected,
                onSelected: (group) {
                  setDialogState(() => selected = group);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !mounted) {
      return;
    }

    try {
      await ref.read(userProfileRepositoryProvider).updateBloodGroup(
            uid: user.uid,
            bloodGroup: selected,
          );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blood group updated to $selected')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $error')),
      );
    }
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
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

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(AppEnv.privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open privacy policy.')),
      );
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (!mounted) {
      return;
    }
    context.goNamed(AppRoutes.signIn.name);
  }
}
