import 'package:flutter/material.dart';

class PermissionRequiredCard extends StatelessWidget {
  const PermissionRequiredCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onOpenSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: onOpenSettings,
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
