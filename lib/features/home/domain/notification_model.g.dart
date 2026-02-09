// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp:
          const TimestampConverter().fromJson(json['timestamp'] as Timestamp),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'info',
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'isRead': instance.isRead,
      'type': instance.type,
    };
