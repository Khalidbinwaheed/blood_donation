// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsItemImpl _$$NewsItemImplFromJson(Map<String, dynamic> json) =>
    _$NewsItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      sourceName: json['sourceName'] as String,
      url: json['url'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      isBreaking: json['isBreaking'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$NewsItemImplToJson(_$NewsItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'category': instance.category,
      'sourceName': instance.sourceName,
      'url': instance.url,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'isBreaking': instance.isBreaking,
      'imageUrl': instance.imageUrl,
    };
