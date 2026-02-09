// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentImpl _$$AppointmentImplFromJson(Map<String, dynamic> json) =>
    _$AppointmentImpl(
      id: json['id'] as String,
      centerId: json['centerId'] as String,
      doctorId: json['doctorId'] as String,
      userId: json['userId'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      status: json['status'] as String,
      type: json['type'] as String? ?? 'Donation',
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$AppointmentImplToJson(_$AppointmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'centerId': instance.centerId,
      'doctorId': instance.doctorId,
      'userId': instance.userId,
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': instance.endsAt.toIso8601String(),
      'status': instance.status,
      'type': instance.type,
      'reason': instance.reason,
      'notes': instance.notes,
    };
