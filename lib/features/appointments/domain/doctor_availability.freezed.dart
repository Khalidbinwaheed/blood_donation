// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_availability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DoctorAvailability _$DoctorAvailabilityFromJson(Map<String, dynamic> json) {
  return _DoctorAvailability.fromJson(json);
}

/// @nodoc
mixin _$DoctorAvailability {
  String get id => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<String> get slots => throw _privateConstructorUsedError;

  /// Serializes this DoctorAvailability to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorAvailabilityCopyWith<DoctorAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorAvailabilityCopyWith<$Res> {
  factory $DoctorAvailabilityCopyWith(
          DoctorAvailability value, $Res Function(DoctorAvailability) then) =
      _$DoctorAvailabilityCopyWithImpl<$Res, DoctorAvailability>;
  @useResult
  $Res call({String id, String doctorId, DateTime date, List<String> slots});
}

/// @nodoc
class _$DoctorAvailabilityCopyWithImpl<$Res, $Val extends DoctorAvailability>
    implements $DoctorAvailabilityCopyWith<$Res> {
  _$DoctorAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? doctorId = null,
    Object? date = null,
    Object? slots = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DoctorAvailabilityImplCopyWith<$Res>
    implements $DoctorAvailabilityCopyWith<$Res> {
  factory _$$DoctorAvailabilityImplCopyWith(_$DoctorAvailabilityImpl value,
          $Res Function(_$DoctorAvailabilityImpl) then) =
      __$$DoctorAvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String doctorId, DateTime date, List<String> slots});
}

/// @nodoc
class __$$DoctorAvailabilityImplCopyWithImpl<$Res>
    extends _$DoctorAvailabilityCopyWithImpl<$Res, _$DoctorAvailabilityImpl>
    implements _$$DoctorAvailabilityImplCopyWith<$Res> {
  __$$DoctorAvailabilityImplCopyWithImpl(_$DoctorAvailabilityImpl _value,
      $Res Function(_$DoctorAvailabilityImpl) _then)
      : super(_value, _then);

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? doctorId = null,
    Object? date = null,
    Object? slots = null,
  }) {
    return _then(_$DoctorAvailabilityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      doctorId: null == doctorId
          ? _value.doctorId
          : doctorId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DoctorAvailabilityImpl implements _DoctorAvailability {
  const _$DoctorAvailabilityImpl(
      {required this.id,
      required this.doctorId,
      required this.date,
      required final List<String> slots})
      : _slots = slots;

  factory _$DoctorAvailabilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoctorAvailabilityImplFromJson(json);

  @override
  final String id;
  @override
  final String doctorId;
  @override
  final DateTime date;
  final List<String> _slots;
  @override
  List<String> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  String toString() {
    return 'DoctorAvailability(id: $id, doctorId: $doctorId, date: $date, slots: $slots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorAvailabilityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._slots, _slots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, doctorId, date,
      const DeepCollectionEquality().hash(_slots));

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorAvailabilityImplCopyWith<_$DoctorAvailabilityImpl> get copyWith =>
      __$$DoctorAvailabilityImplCopyWithImpl<_$DoctorAvailabilityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DoctorAvailabilityImplToJson(
      this,
    );
  }
}

abstract class _DoctorAvailability implements DoctorAvailability {
  const factory _DoctorAvailability(
      {required final String id,
      required final String doctorId,
      required final DateTime date,
      required final List<String> slots}) = _$DoctorAvailabilityImpl;

  factory _DoctorAvailability.fromJson(Map<String, dynamic> json) =
      _$DoctorAvailabilityImpl.fromJson;

  @override
  String get id;
  @override
  String get doctorId;
  @override
  DateTime get date;
  @override
  List<String> get slots;

  /// Create a copy of DoctorAvailability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorAvailabilityImplCopyWith<_$DoctorAvailabilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
