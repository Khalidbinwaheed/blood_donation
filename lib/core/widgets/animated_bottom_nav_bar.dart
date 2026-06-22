import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBottomNavBarItem {
  const AnimatedBottomNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class AnimatedBottomNavBar extends StatelessWidget {
  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onChanged,
  });

  final int currentIndex;
  final List<AnimatedBottomNavBarItem> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xD41A202B)
                  : Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              selectedIndex: currentIndex,
              height: 74,
              elevation: 0,
              onDestinationSelected: onChanged,
              destinations: [
                for (final item in items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.activeIcon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
