import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_availability.freezed.dart';
part 'doctor_availability.g.dart';

@freezed
class DoctorAvailability with _$DoctorAvailability {
  const factory DoctorAvailability({
    required String id,
    required String doctorId,
    required DateTime date,
    required List<String> slots,
  }) = _DoctorAvailability;

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) =>
      _$DoctorAvailabilityFromJson(json);
}
