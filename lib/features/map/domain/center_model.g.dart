// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'center_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CenterModelImpl _$$CenterModelImplFromJson(Map<String, dynamic> json) =>
    _$CenterModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
      phone: json['phone'] as String,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      openNow: json['openNow'] as bool? ?? false,
      accessibility: (json['accessibility'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hours: json['hours'] as String?,
      website: json['website'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CenterModelImplToJson(_$CenterModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
      'phone': instance.phone,
      'specializations': instance.specializations,
      'openNow': instance.openNow,
      'accessibility': instance.accessibility,
      'hours': instance.hours,
      'website': instance.website,
      'distance': instance.distance,
    };
