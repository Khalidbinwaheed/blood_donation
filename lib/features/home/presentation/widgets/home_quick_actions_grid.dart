import 'package:flutter/material.dart';

enum QuickActionType {
  sos,
  callAmbulance,
  shareLiveLocation,
  nearestHospital,
  bookAppointment,
  medicationReminder,
  myRecords,
  healthTips,
}

class QuickActionItem {
  const QuickActionItem({
    required this.type,
    required this.title,
    required this.icon,
    this.isCritical = false,
  });

  final QuickActionType type;
  final String title;
  final IconData icon;
  final bool isCritical;
}

class HomeQuickActionsGrid extends StatelessWidget {
  const HomeQuickActionsGrid({
    super.key,
    required this.onTap,
  });

  final void Function(QuickActionType type) onTap;

  @override
  Widget build(BuildContext context) {
    final items = <QuickActionItem>[
      const QuickActionItem(
        type: QuickActionType.sos,
        title: 'SOS / Ambulance',
        icon: Icons.sos,
        isCritical: true,
      ),
      const QuickActionItem(
        type: QuickActionType.callAmbulance,
        title: 'Call Ambulance',
        icon: Icons.call,
      ),
      const QuickActionItem(
        type: QuickActionType.shareLiveLocation,
        title: 'Share Live Location',
        icon: Icons.share_location,
      ),
      const QuickActionItem(
        type: QuickActionType.nearestHospital,
        title: 'Nearest Hospital',
        icon: Icons.local_hospital,
      ),
      const QuickActionItem(
        type: QuickActionType.bookAppointment,
        title: 'Book Appointment',
        icon: Icons.calendar_month,
      ),
      const QuickActionItem(
        type: QuickActionType.medicationReminder,
        title: 'Medication Reminder',
        icon: Icons.medication,
      ),
      const QuickActionItem(
        type: QuickActionType.myRecords,
        title: 'My Records',
        icon: Icons.folder_open,
      ),
      const QuickActionItem(
        type: QuickActionType.healthTips,
        title: 'Health Tips',
        icon: Icons.tips_and_updates,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 860
            ? 4
            : width >= 620
                ? 3
                : 2;
        final ratio = columns == 2 ? 1.35 : (columns == 3 ? 1.06 : 0.88);

        return GridView.builder(
          key: const Key('quick_actions_grid'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final color = item.isCritical
                ? Colors.red.shade700
                : Theme.of(context).colorScheme.surfaceContainerHighest;
            final foreground = item.isCritical
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface;

            return Semantics(
              button: true,
              label: item.title,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(item.type),
                child: Ink(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, color: foreground),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: foreground,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
