import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;
  static const _themeKey = 'theme_mode';

  ThemeNotifier(this.prefs) : super(_initialTheme(prefs));

  static ThemeMode _initialTheme(SharedPreferences prefs) {
    final savedIndex = prefs.getInt(_themeKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < ThemeMode.values.length) {
      return ThemeMode.values[savedIndex];
    }
    return ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await prefs.setInt(_themeKey, mode.index);
  }
}

// We throw UnimplementedError initially because we override it in main.dart
// with the instance that has the actual SharedPreferences.
final themeServiceProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  throw UnimplementedError(
      'themeServiceProvider must be overridden in main.dart');
});
