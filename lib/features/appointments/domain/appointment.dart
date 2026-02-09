import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

@freezed
class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String centerId,
    required String doctorId,
    required String userId,
    required DateTime startsAt,
    required DateTime endsAt,
    required String status, // booked, completed, cancelled, no-show
    @Default('Donation') String type,
    String? reason,
    String? notes,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
}
