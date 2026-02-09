import 'package:blood_donation/core/services/theme_service.dart';
import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'App Theme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _ThemeCard(
                mode: ThemeMode.light,
                isSelected: themeMode == ThemeMode.light,
                onTap: () => ref
                    .read(themeServiceProvider.notifier)
                    .setTheme(ThemeMode.light),
                title: 'Light',
                child: _buildLightPreview(),
              ),
              const SizedBox(width: 12),
              _ThemeCard(
                mode: ThemeMode.dark,
                isSelected: themeMode == ThemeMode.dark,
                onTap: () => ref
                    .read(themeServiceProvider.notifier)
                    .setTheme(ThemeMode.dark),
                title: 'Dark',
                child: _buildDarkPreview(),
              ),
              const SizedBox(width: 12),
              _ThemeCard(
                mode: ThemeMode.system,
                isSelected: themeMode == ThemeMode.system,
                onTap: () => ref
                    .read(themeServiceProvider.notifier)
                    .setTheme(ThemeMode.system),
                title: 'System',
                child: _buildSystemPreview(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLightPreview() {
    return Container(
      color: AppTheme.surfaceVariantColor,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wb_sunny_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2)
                    ]),
                child: const Icon(Icons.check_circle,
                    color: AppTheme.primaryColor, size: 16),
              ))
        ],
      ),
    );
  }

  Widget _buildDarkPreview() {
    return Container(
      color: AppTheme.darkSurfaceColor,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.nightlight_round,
                  color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(child: Container(color: AppTheme.surfaceVariantColor)),
              Expanded(child: Container(color: AppTheme.darkSurfaceColor)),
            ],
          ),
          Center(
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1)),
                  child: const Icon(Icons.settings_suggest,
                      color: Colors.blueGrey, size: 20)))
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final Widget child;

  const _ThemeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: child,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppTheme.primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
