// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String? ?? 'patient',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      bloodGroup: json['bloodGroup'] as String? ?? '',
      organType: json['organType'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastDonationDate: json['lastDonationDate'] == null
          ? null
          : DateTime.parse(json['lastDonationDate'] as String),
      donorEligibilityStatus:
          json['donorEligibilityStatus'] as String? ?? 'unknown',
      locale: json['locale'] as String?,
      photoUrl: json['photoUrl'] as String?,
      fcmToken: json['fcmToken'] as String?,
      lastCheckIn: json['lastCheckIn'] == null
          ? null
          : DateTime.parse(json['lastCheckIn'] as String),
      type: json['type'] as String? ?? '',
      district: json['district'] as String? ?? '',
      centerId: json['centerId'] as String?,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'phoneNumber': instance.phoneNumber,
      'bloodGroup': instance.bloodGroup,
      'organType': instance.organType,
      'allergies': instance.allergies,
      'conditions': instance.conditions,
      'lastDonationDate': instance.lastDonationDate?.toIso8601String(),
      'donorEligibilityStatus': instance.donorEligibilityStatus,
      'locale': instance.locale,
      'photoUrl': instance.photoUrl,
      'fcmToken': instance.fcmToken,
      'lastCheckIn': instance.lastCheckIn?.toIso8601String(),
      'type': instance.type,
      'district': instance.district,
      'centerId': instance.centerId,
    };
