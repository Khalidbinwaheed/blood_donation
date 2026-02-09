// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'donation_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DonationRequest _$DonationRequestFromJson(Map<String, dynamic> json) {
  return _DonationRequest.fromJson(json);
}

/// @nodoc
mixin _$DonationRequest {
  String get id => throw _privateConstructorUsedError;
  String get requesterUserId => throw _privateConstructorUsedError;
  String get requestType => throw _privateConstructorUsedError; // blood, organ
  String get bloodType => throw _privateConstructorUsedError;
  String? get organType => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // Pending, Matched, In-Progress, Fulfilled
  int get priorityScore => throw _privateConstructorUsedError;
  String? get centerId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this DonationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DonationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DonationRequestCopyWith<DonationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DonationRequestCopyWith<$Res> {
  factory $DonationRequestCopyWith(
          DonationRequest value, $Res Function(DonationRequest) then) =
      _$DonationRequestCopyWithImpl<$Res, DonationRequest>;
  @useResult
  $Res call(
      {String id,
      String requesterUserId,
      String requestType,
      String bloodType,
      String? organType,
      String status,
      int priorityScore,
      String? centerId,
      DateTime createdAt,
      DateTime? updatedAt,
      String? note});
}

/// @nodoc
class _$DonationRequestCopyWithImpl<$Res, $Val extends DonationRequest>
    implements $DonationRequestCopyWith<$Res> {
  _$DonationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DonationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterUserId = null,
    Object? requestType = null,
    Object? bloodType = null,
    Object? organType = freezed,
    Object? status = null,
    Object? priorityScore = null,
    Object? centerId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requesterUserId: null == requesterUserId
          ? _value.requesterUserId
          : requesterUserId // ignore: cast_nullable_to_non_nullable
              as String,
      requestType: null == requestType
          ? _value.requestType
          : requestType // ignore: cast_nullable_to_non_nullable
              as String,
      bloodType: null == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String,
      organType: freezed == organType
          ? _value.organType
          : organType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      priorityScore: null == priorityScore
          ? _value.priorityScore
          : priorityScore // ignore: cast_nullable_to_non_nullable
              as int,
      centerId: freezed == centerId
          ? _value.centerId
          : centerId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DonationRequestImplCopyWith<$Res>
    implements $DonationRequestCopyWith<$Res> {
  factory _$$DonationRequestImplCopyWith(_$DonationRequestImpl value,
          $Res Function(_$DonationRequestImpl) then) =
      __$$DonationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String requesterUserId,
      String requestType,
      String bloodType,
      String? organType,
      String status,
      int priorityScore,
      String? centerId,
      DateTime createdAt,
      DateTime? updatedAt,
      String? note});
}

/// @nodoc
class __$$DonationRequestImplCopyWithImpl<$Res>
    extends _$DonationRequestCopyWithImpl<$Res, _$DonationRequestImpl>
    implements _$$DonationRequestImplCopyWith<$Res> {
  __$$DonationRequestImplCopyWithImpl(
      _$DonationRequestImpl _value, $Res Function(_$DonationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of DonationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterUserId = null,
    Object? requestType = null,
    Object? bloodType = null,
    Object? organType = freezed,
    Object? status = null,
    Object? priorityScore = null,
    Object? centerId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? note = freezed,
  }) {
    return _then(_$DonationRequestImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      requesterUserId: null == requesterUserId
          ? _value.requesterUserId
          : requesterUserId // ignore: cast_nullable_to_non_nullable
              as String,
      requestType: null == requestType
          ? _value.requestType
          : requestType // ignore: cast_nullable_to_non_nullable
              as String,
      bloodType: null == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String,
      organType: freezed == organType
          ? _value.organType
          : organType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      priorityScore: null == priorityScore
          ? _value.priorityScore
          : priorityScore // ignore: cast_nullable_to_non_nullable
              as int,
      centerId: freezed == centerId
          ? _value.centerId
          : centerId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DonationRequestImpl implements _DonationRequest {
  const _$DonationRequestImpl(
      {required this.id,
      required this.requesterUserId,
      required this.requestType,
      required this.bloodType,
      this.organType,
      required this.status,
      this.priorityScore = 0,
      this.centerId,
      required this.createdAt,
      this.updatedAt,
      this.note});

  factory _$DonationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DonationRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String requesterUserId;
  @override
  final String requestType;
// blood, organ
  @override
  final String bloodType;
  @override
  final String? organType;
  @override
  final String status;
// Pending, Matched, In-Progress, Fulfilled
  @override
  @JsonKey()
  final int priorityScore;
  @override
  final String? centerId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? note;

  @override
  String toString() {
    return 'DonationRequest(id: $id, requesterUserId: $requesterUserId, requestType: $requestType, bloodType: $bloodType, organType: $organType, status: $status, priorityScore: $priorityScore, centerId: $centerId, createdAt: $createdAt, updatedAt: $updatedAt, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DonationRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requesterUserId, requesterUserId) ||
                other.requesterUserId == requesterUserId) &&
            (identical(other.requestType, requestType) ||
                other.requestType == requestType) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            (identical(other.organType, organType) ||
                other.organType == organType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priorityScore, priorityScore) ||
                other.priorityScore == priorityScore) &&
            (identical(other.centerId, centerId) ||
                other.centerId == centerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      requesterUserId,
      requestType,
      bloodType,
      organType,
      status,
      priorityScore,
      centerId,
      createdAt,
      updatedAt,
      note);

  /// Create a copy of DonationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DonationRequestImplCopyWith<_$DonationRequestImpl> get copyWith =>
      __$$DonationRequestImplCopyWithImpl<_$DonationRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DonationRequestImplToJson(
      this,
    );
  }
}

abstract class _DonationRequest implements DonationRequest {
  const factory _DonationRequest(
      {required final String id,
      required final String requesterUserId,
      required final String requestType,
      required final String bloodType,
      final String? organType,
      required final String status,
      final int priorityScore,
      final String? centerId,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final String? note}) = _$DonationRequestImpl;

  factory _DonationRequest.fromJson(Map<String, dynamic> json) =
      _$DonationRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get requesterUserId;
  @override
  String get requestType; // blood, organ
  @override
  String get bloodType;
  @override
  String? get organType;
  @override
  String get status; // Pending, Matched, In-Progress, Fulfilled
  @override
  int get priorityScore;
  @override
  String? get centerId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get note;

  /// Create a copy of DonationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DonationRequestImplCopyWith<_$DonationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
