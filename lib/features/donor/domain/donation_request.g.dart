// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DonationRequestImpl _$$DonationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DonationRequestImpl(
      id: json['id'] as String,
      requesterUserId: json['requesterUserId'] as String,
      requestType: json['requestType'] as String,
      bloodType: json['bloodType'] as String,
      organType: json['organType'] as String?,
      status: json['status'] as String,
      priorityScore: (json['priorityScore'] as num?)?.toInt() ?? 0,
      centerId: json['centerId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$DonationRequestImplToJson(
        _$DonationRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterUserId': instance.requesterUserId,
      'requestType': instance.requestType,
      'bloodType': instance.bloodType,
      'organType': instance.organType,
      'status': instance.status,
      'priorityScore': instance.priorityScore,
      'centerId': instance.centerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'note': instance.note,
    };
