import 'package:blood_donation/core/storage/cache_boxes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class HomeBannerState {
  const HomeBannerState({
    required this.showVaccinationBanner,
    required this.showBloodDriveBanner,
  });

  final bool showVaccinationBanner;
  final bool showBloodDriveBanner;

  HomeBannerState copyWith({
    bool? showVaccinationBanner,
    bool? showBloodDriveBanner,
  }) {
    return HomeBannerState(
      showVaccinationBanner:
          showVaccinationBanner ?? this.showVaccinationBanner,
      showBloodDriveBanner: showBloodDriveBanner ?? this.showBloodDriveBanner,
    );
  }
}

class HomeBannerController extends StateNotifier<HomeBannerState> {
  HomeBannerController(this._box)
      : super(
          HomeBannerState(
            showVaccinationBanner:
                !(_box.get('dismiss_vaccination') as bool? ?? false),
            showBloodDriveBanner:
                !(_box.get('dismiss_blooddrive') as bool? ?? false),
          ),
        );

  final Box<dynamic> _box;

  Future<void> dismissVaccination() async {
    await _box.put('dismiss_vaccination', true);
    state = state.copyWith(showVaccinationBanner: false);
  }

  Future<void> dismissBloodDrive() async {
    await _box.put('dismiss_blooddrive', true);
    state = state.copyWith(showBloodDriveBanner: false);
  }
}

final homeBannerProvider =
    StateNotifierProvider<HomeBannerController, HomeBannerState>((ref) {
  return HomeBannerController(Hive.box<dynamic>(CacheBoxes.banners));
});
