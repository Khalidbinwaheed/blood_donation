// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DoctorAvailabilityImpl _$$DoctorAvailabilityImplFromJson(
        Map<String, dynamic> json) =>
    _$DoctorAvailabilityImpl(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      date: DateTime.parse(json['date'] as String),
      slots: (json['slots'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$DoctorAvailabilityImplToJson(
        _$DoctorAvailabilityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorId': instance.doctorId,
      'date': instance.date.toIso8601String(),
      'slots': instance.slots,
    };
