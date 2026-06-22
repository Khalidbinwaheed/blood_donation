import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({
    super.key,
    required this.onPressed,
    this.label = 'SOS',
    this.subtitle = 'Hold 3 seconds to trigger emergency alert',
  });

  final VoidCallback onPressed;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF3B30), Color(0xFFCC2B20)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.white, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
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
