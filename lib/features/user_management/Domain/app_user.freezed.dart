// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String get role =>
      throw _privateConstructorUsedError; // patient, donor, recipient, doctor, admin
  String get phoneNumber => throw _privateConstructorUsedError;
  String get bloodGroup => throw _privateConstructorUsedError;
  String? get organType => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<String> get conditions => throw _privateConstructorUsedError;
  DateTime? get lastDonationDate => throw _privateConstructorUsedError;
  String get donorEligibilityStatus =>
      throw _privateConstructorUsedError; // unknown, eligible, ineligible
  String? get locale => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  DateTime? get lastCheckIn =>
      throw _privateConstructorUsedError; // Legacy fields to be refactored or kept for compatibility
  String get type => throw _privateConstructorUsedError;
  String get district => throw _privateConstructorUsedError;
  String? get centerId => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String uid,
      String email,
      String? firstName,
      String? lastName,
      String role,
      String phoneNumber,
      String bloodGroup,
      String? organType,
      List<String> allergies,
      List<String> conditions,
      DateTime? lastDonationDate,
      String donorEligibilityStatus,
      String? locale,
      String? photoUrl,
      String? fcmToken,
      DateTime? lastCheckIn,
      String type,
      String district,
      String? centerId});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? role = null,
    Object? phoneNumber = null,
    Object? bloodGroup = null,
    Object? organType = freezed,
    Object? allergies = null,
    Object? conditions = null,
    Object? lastDonationDate = freezed,
    Object? donorEligibilityStatus = null,
    Object? locale = freezed,
    Object? photoUrl = freezed,
    Object? fcmToken = freezed,
    Object? lastCheckIn = freezed,
    Object? type = null,
    Object? district = null,
    Object? centerId = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bloodGroup: null == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String,
      organType: freezed == organType
          ? _value.organType
          : organType // ignore: cast_nullable_to_non_nullable
              as String?,
      allergies: null == allergies
          ? _value.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      conditions: null == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastDonationDate: freezed == lastDonationDate
          ? _value.lastDonationDate
          : lastDonationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      donorEligibilityStatus: null == donorEligibilityStatus
          ? _value.donorEligibilityStatus
          : donorEligibilityStatus // ignore: cast_nullable_to_non_nullable
              as String,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastCheckIn: freezed == lastCheckIn
          ? _value.lastCheckIn
          : lastCheckIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      centerId: freezed == centerId
          ? _value.centerId
          : centerId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String? firstName,
      String? lastName,
      String role,
      String phoneNumber,
      String bloodGroup,
      String? organType,
      List<String> allergies,
      List<String> conditions,
      DateTime? lastDonationDate,
      String donorEligibilityStatus,
      String? locale,
      String? photoUrl,
      String? fcmToken,
      DateTime? lastCheckIn,
      String type,
      String district,
      String? centerId});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? role = null,
    Object? phoneNumber = null,
    Object? bloodGroup = null,
    Object? organType = freezed,
    Object? allergies = null,
    Object? conditions = null,
    Object? lastDonationDate = freezed,
    Object? donorEligibilityStatus = null,
    Object? locale = freezed,
    Object? photoUrl = freezed,
    Object? fcmToken = freezed,
    Object? lastCheckIn = freezed,
    Object? type = null,
    Object? district = null,
    Object? centerId = freezed,
  }) {
    return _then(_$AppUserImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bloodGroup: null == bloodGroup
          ? _value.bloodGroup
          : bloodGroup // ignore: cast_nullable_to_non_nullable
              as String,
      organType: freezed == organType
          ? _value.organType
          : organType // ignore: cast_nullable_to_non_nullable
              as String?,
      allergies: null == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      conditions: null == conditions
          ? _value._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastDonationDate: freezed == lastDonationDate
          ? _value.lastDonationDate
          : lastDonationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      donorEligibilityStatus: null == donorEligibilityStatus
          ? _value.donorEligibilityStatus
          : donorEligibilityStatus // ignore: cast_nullable_to_non_nullable
              as String,
      locale: freezed == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      lastCheckIn: freezed == lastCheckIn
          ? _value.lastCheckIn
          : lastCheckIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      centerId: freezed == centerId
          ? _value.centerId
          : centerId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl extends _AppUser {
  const _$AppUserImpl(
      {required this.uid,
      required this.email,
      this.firstName,
      this.lastName,
      this.role = 'patient',
      this.phoneNumber = '',
      this.bloodGroup = '',
      this.organType,
      final List<String> allergies = const [],
      final List<String> conditions = const [],
      this.lastDonationDate,
      this.donorEligibilityStatus = 'unknown',
      this.locale,
      this.photoUrl,
      this.fcmToken,
      this.lastCheckIn,
      this.type = '',
      this.district = '',
      this.centerId})
      : _allergies = allergies,
        _conditions = conditions,
        super._();

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  @JsonKey()
  final String role;
// patient, donor, recipient, doctor, admin
  @override
  @JsonKey()
  final String phoneNumber;
  @override
  @JsonKey()
  final String bloodGroup;
  @override
  final String? organType;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _conditions;
  @override
  @JsonKey()
  List<String> get conditions {
    if (_conditions is EqualUnmodifiableListView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conditions);
  }

  @override
  final DateTime? lastDonationDate;
  @override
  @JsonKey()
  final String donorEligibilityStatus;
// unknown, eligible, ineligible
  @override
  final String? locale;
  @override
  final String? photoUrl;
  @override
  final String? fcmToken;
  @override
  final DateTime? lastCheckIn;
// Legacy fields to be refactored or kept for compatibility
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String district;
  @override
  final String? centerId;

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName, role: $role, phoneNumber: $phoneNumber, bloodGroup: $bloodGroup, organType: $organType, allergies: $allergies, conditions: $conditions, lastDonationDate: $lastDonationDate, donorEligibilityStatus: $donorEligibilityStatus, locale: $locale, photoUrl: $photoUrl, fcmToken: $fcmToken, lastCheckIn: $lastCheckIn, type: $type, district: $district, centerId: $centerId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            (identical(other.organType, organType) ||
                other.organType == organType) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions) &&
            (identical(other.lastDonationDate, lastDonationDate) ||
                other.lastDonationDate == lastDonationDate) &&
            (identical(other.donorEligibilityStatus, donorEligibilityStatus) ||
                other.donorEligibilityStatus == donorEligibilityStatus) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.lastCheckIn, lastCheckIn) ||
                other.lastCheckIn == lastCheckIn) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.centerId, centerId) ||
                other.centerId == centerId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        uid,
        email,
        firstName,
        lastName,
        role,
        phoneNumber,
        bloodGroup,
        organType,
        const DeepCollectionEquality().hash(_allergies),
        const DeepCollectionEquality().hash(_conditions),
        lastDonationDate,
        donorEligibilityStatus,
        locale,
        photoUrl,
        fcmToken,
        lastCheckIn,
        type,
        district,
        centerId
      ]);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser extends AppUser {
  const factory _AppUser(
      {required final String uid,
      required final String email,
      final String? firstName,
      final String? lastName,
      final String role,
      final String phoneNumber,
      final String bloodGroup,
      final String? organType,
      final List<String> allergies,
      final List<String> conditions,
      final DateTime? lastDonationDate,
      final String donorEligibilityStatus,
      final String? locale,
      final String? photoUrl,
      final String? fcmToken,
      final DateTime? lastCheckIn,
      final String type,
      final String district,
      final String? centerId}) = _$AppUserImpl;
  const _AppUser._() : super._();

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String get role; // patient, donor, recipient, doctor, admin
  @override
  String get phoneNumber;
  @override
  String get bloodGroup;
  @override
  String? get organType;
  @override
  List<String> get allergies;
  @override
  List<String> get conditions;
  @override
  DateTime? get lastDonationDate;
  @override
  String get donorEligibilityStatus; // unknown, eligible, ineligible
  @override
  String? get locale;
  @override
  String? get photoUrl;
  @override
  String? get fcmToken;
  @override
  DateTime?
      get lastCheckIn; // Legacy fields to be refactored or kept for compatibility
  @override
  String get type;
  @override
  String get district;
  @override
  String? get centerId;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
