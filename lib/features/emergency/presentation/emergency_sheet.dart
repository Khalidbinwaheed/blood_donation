import 'dart:async';

import 'package:blood_donation/core/services/analytics_service.dart';
import 'package:blood_donation/features/emergency/data/permission_providers.dart';
import 'package:blood_donation/features/emergency/presentation/emergency_controller.dart';
import 'package:blood_donation/features/widgets/permission_required_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showEmergencySheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) {
      return const _EmergencySheetBody();
    },
  );
}

class _EmergencySheetBody extends ConsumerWidget {
  const _EmergencySheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionControllerProvider);
    final emergency = ref.watch(emergencyControllerProvider);
    final primaryContact = ref.watch(primaryContactProvider);

    final locationGranted =
        permissions[AppPermissionType.location]?.granted ?? false;
    final phoneGranted = permissions[AppPermissionType.phone]?.granted ?? false;
    final smsGranted = permissions[AppPermissionType.sms]?.granted ?? false;

    Future<void> showResult(String successText, bool success) async {
      showEmergencyActionSnack(
        context,
        text: success ? successText : 'Action failed. Please try again.',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Help',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Long-press for 3 seconds to confirm SOS.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _HoldToConfirmButton(
            key: const Key('sos_button'),
            label: 'Hold for SOS',
            onConfirmed: () async {
              await ref.read(analyticsServiceProvider).logEvent('sos_pressed');
              final success = await emergency.callAmbulance();
              if (context.mounted) {
                await showResult('Emergency call started.', success);
              }
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  if (!phoneGranted) {
                    await ref
                        .read(permissionControllerProvider.notifier)
                        .request(AppPermissionType.phone);
                  }
                  final success = await emergency.callAmbulance();
                  if (context.mounted) {
                    await showResult('Calling ambulance...', success);
                  }
                },
                icon: const Icon(Icons.call),
                label: Text('Call ${emergency.ambulanceNumber}'),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  if (!smsGranted) {
                    await ref
                        .read(permissionControllerProvider.notifier)
                        .request(AppPermissionType.sms);
                  }
                  final success =
                      await emergency.sendSmsToPrimaryContact(primaryContact);
                  if (context.mounted) {
                    await showResult('Message sent!', success);
                  }
                },
                icon: const Icon(Icons.sms),
                label: const Text('Send SMS'),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final success = await emergency.shareLiveLocation();
                  if (context.mounted) {
                    await showResult('Location shared!', success);
                  }
                },
                icon: const Icon(Icons.share_location),
                label: const Text('Share Location'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!locationGranted || !phoneGranted || !smsGranted)
            PermissionRequiredCard(
              title: 'We need this to help you',
              subtitle:
                  'Location, phone, and SMS permissions allow one-tap emergency actions.',
              onOpenSettings: () {
                ref
                    .read(permissionControllerProvider.notifier)
                    .openSystemSettings();
              },
            ),
        ],
      ),
    );
  }
}

class _HoldToConfirmButton extends StatefulWidget {
  const _HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
  });

  final String label;
  final Future<void> Function() onConfirmed;

  @override
  State<_HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<_HoldToConfirmButton> {
  static const int _holdMillis = 3000;
  Timer? _timer;
  int _elapsed = 0;
  bool _completed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_elapsed / _holdMillis).clamp(0.0, 1.0);
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _stopHold(reset: !_completed),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.sos, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startHold() {
    _completed = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!mounted) {
        return;
      }
      setState(() {
        _elapsed += 100;
      });
      if (_elapsed >= _holdMillis) {
        _completed = true;
        _stopHold(reset: false);
        await widget.onConfirmed();
        if (!mounted) {
          return;
        }
        setState(() {
          _elapsed = 0;
        });
      }
    });
  }

  void _stopHold({required bool reset}) {
    _timer?.cancel();
    if (reset && mounted) {
      setState(() {
        _elapsed = 0;
      });
    }
  }
}
