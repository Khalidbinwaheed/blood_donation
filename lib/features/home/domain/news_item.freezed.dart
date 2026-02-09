// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) {
  return _NewsItem.fromJson(json);
}

/// @nodoc
mixin _$NewsItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // Public Health, Blood Drives, Local Alerts
  String get sourceName => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  DateTime get publishedAt => throw _privateConstructorUsedError;
  bool get isBreaking => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this NewsItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsItemCopyWith<NewsItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsItemCopyWith<$Res> {
  factory $NewsItemCopyWith(NewsItem value, $Res Function(NewsItem) then) =
      _$NewsItemCopyWithImpl<$Res, NewsItem>;
  @useResult
  $Res call(
      {String id,
      String title,
      String summary,
      String category,
      String sourceName,
      String? url,
      DateTime publishedAt,
      bool isBreaking,
      String? imageUrl});
}

/// @nodoc
class _$NewsItemCopyWithImpl<$Res, $Val extends NewsItem>
    implements $NewsItemCopyWith<$Res> {
  _$NewsItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? summary = null,
    Object? category = null,
    Object? sourceName = null,
    Object? url = freezed,
    Object? publishedAt = null,
    Object? isBreaking = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      sourceName: null == sourceName
          ? _value.sourceName
          : sourceName // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: null == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isBreaking: null == isBreaking
          ? _value.isBreaking
          : isBreaking // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsItemImplCopyWith<$Res>
    implements $NewsItemCopyWith<$Res> {
  factory _$$NewsItemImplCopyWith(
          _$NewsItemImpl value, $Res Function(_$NewsItemImpl) then) =
      __$$NewsItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String summary,
      String category,
      String sourceName,
      String? url,
      DateTime publishedAt,
      bool isBreaking,
      String? imageUrl});
}

/// @nodoc
class __$$NewsItemImplCopyWithImpl<$Res>
    extends _$NewsItemCopyWithImpl<$Res, _$NewsItemImpl>
    implements _$$NewsItemImplCopyWith<$Res> {
  __$$NewsItemImplCopyWithImpl(
      _$NewsItemImpl _value, $Res Function(_$NewsItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? summary = null,
    Object? category = null,
    Object? sourceName = null,
    Object? url = freezed,
    Object? publishedAt = null,
    Object? isBreaking = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$NewsItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      sourceName: null == sourceName
          ? _value.sourceName
          : sourceName // ignore: cast_nullable_to_non_nullable
              as String,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      publishedAt: null == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isBreaking: null == isBreaking
          ? _value.isBreaking
          : isBreaking // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsItemImpl implements _NewsItem {
  const _$NewsItemImpl(
      {required this.id,
      required this.title,
      required this.summary,
      required this.category,
      required this.sourceName,
      this.url,
      required this.publishedAt,
      this.isBreaking = false,
      this.imageUrl});

  factory _$NewsItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String summary;
  @override
  final String category;
// Public Health, Blood Drives, Local Alerts
  @override
  final String sourceName;
  @override
  final String? url;
  @override
  final DateTime publishedAt;
  @override
  @JsonKey()
  final bool isBreaking;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'NewsItem(id: $id, title: $title, summary: $summary, category: $category, sourceName: $sourceName, url: $url, publishedAt: $publishedAt, isBreaking: $isBreaking, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sourceName, sourceName) ||
                other.sourceName == sourceName) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isBreaking, isBreaking) ||
                other.isBreaking == isBreaking) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, summary, category,
      sourceName, url, publishedAt, isBreaking, imageUrl);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      __$$NewsItemImplCopyWithImpl<_$NewsItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsItemImplToJson(
      this,
    );
  }
}

abstract class _NewsItem implements NewsItem {
  const factory _NewsItem(
      {required final String id,
      required final String title,
      required final String summary,
      required final String category,
      required final String sourceName,
      final String? url,
      required final DateTime publishedAt,
      final bool isBreaking,
      final String? imageUrl}) = _$NewsItemImpl;

  factory _NewsItem.fromJson(Map<String, dynamic> json) =
      _$NewsItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get summary;
  @override
  String get category; // Public Health, Blood Drives, Local Alerts
  @override
  String get sourceName;
  @override
  String? get url;
  @override
  DateTime get publishedAt;
  @override
  bool get isBreaking;
  @override
  String? get imageUrl;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
