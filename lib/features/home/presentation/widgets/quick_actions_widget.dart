import 'package:blood_donation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionItem(
        icon: Icons.volunteer_activism,
        label: AppLocalizations.of(context)!.requestHelp,
        color: const Color(0xFFD32F2F), // Red
        onTap: () {
          context.pushNamed('requestBlood');
        },
      ),
      _QuickActionItem(
        icon: Icons.calendar_month,
        label: AppLocalizations.of(context)!.bookAppointment,
        color: const Color(0xFF009688), // Teal
        onTap: () {
          context.pushNamed('appointments');
        },
      ),
      _QuickActionItem(
        icon: Icons.qr_code,
        label: AppLocalizations.of(context)!.myId,
        color: const Color(0xFF607D8B), // Blue Grey
        onTap: () {
          context.pushNamed('digitalId');
        },
      ),
      _QuickActionItem(
        icon: Icons.sos,
        label: AppLocalizations.of(context)!.emergencySos,
        color: const Color(0xFFB71C1C), // Deep Red
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Emergency SOS'),
              content: const Text(
                  'Are you sure you want to trigger an SOS alert to nearby donors?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: '112', // Emergency number
                    );
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not launch dialer')),
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('TRIGGER SOS'),
                ),
              ],
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((item) => _buildAction(context, item)).toList(),
      ),
    );
  }

  Widget _buildAction(BuildContext context, _QuickActionItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
