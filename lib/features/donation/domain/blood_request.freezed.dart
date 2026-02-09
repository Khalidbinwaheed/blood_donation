// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blood_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BloodRequest _$BloodRequestFromJson(Map<String, dynamic> json) {
  return _BloodRequest.fromJson(json);
}

/// @nodoc
mixin _$BloodRequest {
  String get id => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String get bloodGroupNeeded => throw _privateConstructorUsedError;
  String get severity =>
      throw _privateConstructorUsedError; // Critical, High, Moderate
  DateTime get deadline => throw _privateConstructorUsedError;
  String get contactEmail => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError; // Open, Closed
  String get hospitalName => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this BloodRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BloodRequestCopyWith<BloodRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BloodRequestCopyWith<$Res> {
  factory $BloodRequestCopyWith(
          BloodRequest value, $Res Function(BloodRequest) then) =
      _$BloodRequestCopyWithImpl<$Res, BloodRequest>;
  @useResult
  $Res call(
      {String id,
      String requesterId,
      String bloodGroupNeeded,
      String severity,
      DateTime deadline,
      String contactEmail,
      String status,
      String hospitalName,
      String note,
      DateTime createdAt});
}

/// @nodoc
class _$BloodRequestCopyWithImpl<$Res, $Val extends BloodRequest>
    implements $BloodRequestCopyWith<$Res> {
  _$BloodRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? bloodGroupNeeded = null,
    Object? severity = null,
    Object? deadline = null,
    Object? contactEmail = null,
    Object? status = null,
    Object? hospitalName = null,
    Object? note = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requesterId: null == requesterId
          ? _value.requesterId
          : requesterId // ignore: cast_nullable_to_non_nullable
              as String,
      bloodGroupNeeded: null == bloodGroupNeeded
          ? _value.bloodGroupNeeded
          : bloodGroupNeeded // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: null == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      hospitalName: null == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BloodRequestImplCopyWith<$Res>
    implements $BloodRequestCopyWith<$Res> {
  factory _$$BloodRequestImplCopyWith(
          _$BloodRequestImpl value, $Res Function(_$BloodRequestImpl) then) =
      __$$BloodRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String requesterId,
      String bloodGroupNeeded,
      String severity,
      DateTime deadline,
      String contactEmail,
      String status,
      String hospitalName,
      String note,
      DateTime createdAt});
}

/// @nodoc
class __$$BloodRequestImplCopyWithImpl<$Res>
    extends _$BloodRequestCopyWithImpl<$Res, _$BloodRequestImpl>
    implements _$$BloodRequestImplCopyWith<$Res> {
  __$$BloodRequestImplCopyWithImpl(
      _$BloodRequestImpl _value, $Res Function(_$BloodRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? bloodGroupNeeded = null,
    Object? severity = null,
    Object? deadline = null,
    Object? contactEmail = null,
    Object? status = null,
    Object? hospitalName = null,
    Object? note = null,
    Object? createdAt = null,
  }) {
    return _then(_$BloodRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requesterId: null == requesterId
          ? _value.requesterId
          : requesterId // ignore: cast_nullable_to_non_nullable
              as String,
      bloodGroupNeeded: null == bloodGroupNeeded
          ? _value.bloodGroupNeeded
          : bloodGroupNeeded // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: null == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      hospitalName: null == hospitalName
          ? _value.hospitalName
          : hospitalName // ignore: cast_nullable_to_non_nullable
              as String,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BloodRequestImpl implements _BloodRequest {
  const _$BloodRequestImpl(
      {required this.id,
      required this.requesterId,
      required this.bloodGroupNeeded,
      this.severity = 'High',
      required this.deadline,
      required this.contactEmail,
      this.status = 'Open',
      required this.hospitalName,
      this.note = '',
      required this.createdAt});

  factory _$BloodRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BloodRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String requesterId;
  @override
  final String bloodGroupNeeded;
  @override
  @JsonKey()
  final String severity;
// Critical, High, Moderate
  @override
  final DateTime deadline;
  @override
  final String contactEmail;
  @override
  @JsonKey()
  final String status;
// Open, Closed
  @override
  final String hospitalName;
  @override
  @JsonKey()
  final String note;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'BloodRequest(id: $id, requesterId: $requesterId, bloodGroupNeeded: $bloodGroupNeeded, severity: $severity, deadline: $deadline, contactEmail: $contactEmail, status: $status, hospitalName: $hospitalName, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BloodRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.bloodGroupNeeded, bloodGroupNeeded) ||
                other.bloodGroupNeeded == bloodGroupNeeded) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.hospitalName, hospitalName) ||
                other.hospitalName == hospitalName) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      requesterId,
      bloodGroupNeeded,
      severity,
      deadline,
      contactEmail,
      status,
      hospitalName,
      note,
      createdAt);

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BloodRequestImplCopyWith<_$BloodRequestImpl> get copyWith =>
      __$$BloodRequestImplCopyWithImpl<_$BloodRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BloodRequestImplToJson(
      this,
    );
  }
}

abstract class _BloodRequest implements BloodRequest {
  const factory _BloodRequest(
      {required final String id,
      required final String requesterId,
      required final String bloodGroupNeeded,
      final String severity,
      required final DateTime deadline,
      required final String contactEmail,
      final String status,
      required final String hospitalName,
      final String note,
      required final DateTime createdAt}) = _$BloodRequestImpl;

  factory _BloodRequest.fromJson(Map<String, dynamic> json) =
      _$BloodRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get requesterId;
  @override
  String get bloodGroupNeeded;
  @override
  String get severity; // Critical, High, Moderate
  @override
  DateTime get deadline;
  @override
  String get contactEmail;
  @override
  String get status; // Open, Closed
  @override
  String get hospitalName;
  @override
  String get note;
  @override
  DateTime get createdAt;

  /// Create a copy of BloodRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BloodRequestImplCopyWith<_$BloodRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
