import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/core/storage/cache_boxes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class AppSettingsState {
  const AppSettingsState({
    required this.showLocalNewsFirst,
    required this.ambulanceNumber,
  });

  final bool showLocalNewsFirst;
  final String ambulanceNumber;

  AppSettingsState copyWith({
    bool? showLocalNewsFirst,
    String? ambulanceNumber,
  }) {
    return AppSettingsState(
      showLocalNewsFirst: showLocalNewsFirst ?? this.showLocalNewsFirst,
      ambulanceNumber: ambulanceNumber ?? this.ambulanceNumber,
    );
  }
}

class AppSettingsController extends StateNotifier<AppSettingsState> {
  AppSettingsController(this._box)
      : super(
          AppSettingsState(
            showLocalNewsFirst:
                _box.get('showLocalNewsFirst') as bool? ?? false,
            ambulanceNumber:
                (_box.get('ambulanceNumber') as String?)?.trim().isNotEmpty ==
                        true
                    ? (_box.get('ambulanceNumber') as String).trim()
                    : AppEnv.ambulanceNumber,
          ),
        );

  final Box<dynamic> _box;

  Future<void> setShowLocalNewsFirst(bool value) async {
    await _box.put('showLocalNewsFirst', value);
    state = state.copyWith(showLocalNewsFirst: value);
  }

  Future<void> setAmbulanceNumber(String value) async {
    final sanitized = value.trim();
    if (sanitized.isEmpty) {
      return;
    }
    await _box.put('ambulanceNumber', sanitized);
    state = state.copyWith(ambulanceNumber: sanitized);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsController, AppSettingsState>((ref) {
  final box = Hive.box<dynamic>(CacheBoxes.settings);
  return AppSettingsController(box);
});
