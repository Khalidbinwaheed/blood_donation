import 'dart:async';

import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/widgets/emergency_button.dart';
import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/features/emergency/data/permission_providers.dart';
import 'package:blood_donation/features/emergency/presentation/emergency_controller.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmergencySosScreen extends ConsumerWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergency = ref.watch(emergencyControllerProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final contactsGranted = ref
            .watch(permissionControllerProvider)[AppPermissionType.sms]
            ?.granted ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        actions: [
          IconButton(
            tooltip: 'Contacts',
            onPressed: () =>
                context.pushNamed(AppRoutes.emergencyContacts.name),
            icon: const Icon(Icons.groups_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Press and hold for 3 seconds',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Emergency actions will call the ambulance line, share GPS location, and alert trusted contacts.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                EmergencyButton(
                  onPressed: () {
                    unawaited(_sendEmergency(ref, context));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final success = await emergency.callAmbulance();
                  if (context.mounted) {
                    showEmergencyActionSnack(
                      context,
                      text: success
                          ? 'Calling ambulance...'
                          : 'Unable to place call',
                    );
                  }
                },
                icon: const Icon(Icons.call),
                label: Text('Call ${emergency.ambulanceNumber}'),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final success = await emergency.shareLiveLocation();
                  if (context.mounted) {
                    showEmergencyActionSnack(
                      context,
                      text: success
                          ? 'Location shared'
                          : 'Location sharing unavailable',
                    );
                  }
                },
                icon: const Icon(Icons.share_location),
                label: const Text('Share location'),
              ),
              FilledButton.tonalIcon(
                onPressed: () =>
                    context.pushNamed(AppRoutes.emergencyContacts.name),
                icon: const Icon(Icons.contact_emergency),
                label: const Text('Trusted contacts'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency readiness',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _ReadinessRow(
                  title: 'Signed in',
                  value: user == null ? 'No' : 'Yes',
                  color: user == null ? Colors.red : Colors.green,
                ),
                _ReadinessRow(
                  title: 'SMS permission',
                  value: contactsGranted ? 'Granted' : 'Not granted',
                  color: contactsGranted ? Colors.green : Colors.orange,
                ),
                const _ReadinessRow(
                  title: 'Location',
                  value: 'Requested on demand',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmergency(WidgetRef ref, BuildContext context) async {
    final emergency = ref.read(emergencyControllerProvider);
    final success = await emergency.callAmbulance();
    if (!context.mounted) return;
    showEmergencyActionSnack(
      context,
      text: success ? 'Emergency call started.' : 'Emergency call failed.',
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow(
      {required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
