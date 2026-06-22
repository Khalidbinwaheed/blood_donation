import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _IosGlassNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(index),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _IosGlassNavBar extends StatelessWidget {
  const _IosGlassNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xD41C2230) : Colors.white.withValues(alpha: 0.78);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.10);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: baseColor,
                  border: Border.all(color: borderColor),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.46),
                            Colors.white.withValues(alpha: 0.12),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.44 : 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color:
                          Colors.white.withValues(alpha: isDark ? 0.02 : 0.34),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  selectedIndex: selectedIndex,
                  height: 76,
                  elevation: 0,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  onDestinationSelected: onDestinationSelected,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(CupertinoIcons.house),
                      selectedIcon: Icon(CupertinoIcons.house_fill),
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Icon(CupertinoIcons.chat_bubble),
                      selectedIcon: Icon(CupertinoIcons.chat_bubble_fill),
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.folder_open_outlined),
                      selectedIcon: Icon(Icons.folder_open),
                      label: '',
                    ),
                    NavigationDestination(
                      icon: Icon(CupertinoIcons.person),
                      selectedIcon: Icon(CupertinoIcons.person_fill),
                      label: '',
                    ),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.14 : 0.64),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
