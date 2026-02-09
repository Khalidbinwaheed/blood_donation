// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blood_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BloodRequestImpl _$$BloodRequestImplFromJson(Map<String, dynamic> json) =>
    _$BloodRequestImpl(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      bloodGroupNeeded: json['bloodGroupNeeded'] as String,
      severity: json['severity'] as String? ?? 'High',
      deadline: DateTime.parse(json['deadline'] as String),
      contactEmail: json['contactEmail'] as String,
      status: json['status'] as String? ?? 'Open',
      hospitalName: json['hospitalName'] as String,
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$BloodRequestImplToJson(_$BloodRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'bloodGroupNeeded': instance.bloodGroupNeeded,
      'severity': instance.severity,
      'deadline': instance.deadline.toIso8601String(),
      'contactEmail': instance.contactEmail,
      'status': instance.status,
      'hospitalName': instance.hospitalName,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };
