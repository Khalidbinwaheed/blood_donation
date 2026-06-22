import 'package:flutter/material.dart';

class HealthStatCard extends StatelessWidget {
  const HealthStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.trailing,
    this.emphasisColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Widget? trailing;
  final Color? emphasisColor;

  @override
  Widget build(BuildContext context) {
    final color = emphasisColor ?? Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
