import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    String? firstName,
    String? lastName,
    @Default('patient')
    String role, // patient, donor, recipient, doctor, admin, super_admin
    @Default('') String phoneNumber,
    @Default('') String bloodGroup,
    String? organType,
    @Default([]) List<String> allergies,
    @Default([]) List<String> conditions,
    DateTime? lastDonationDate,
    @Default('unknown')
    String donorEligibilityStatus, // unknown, eligible, ineligible
    String? locale,
    String? photoUrl,
    String? fcmToken,
    DateTime? lastCheckIn,
    // Legacy fields to be refactored or kept for compatibility
    @Default('') String type,
    @Default('') String district,
    String? centerId, // ID of the center this user (doctor/staff) belongs to
  }) = _AppUser;

  const AppUser._();

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
