import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected blood group filter.
/// If null, the dashboard is shown.
/// If set (e.g., 'A+'), the donor list for that group is shown.
final bloodGroupFilterProvider = StateProvider<String?>((ref) => null);
