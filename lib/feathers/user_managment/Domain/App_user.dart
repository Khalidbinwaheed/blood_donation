import 'package:flutter/foundation.dart';

class AppUser {
  final String name;
  final String phoneNumber;
  final String bloodGroup;
  final String email;
  final String type;
  final String userId;

  const AppUser({
    required this.name,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.email,
    required this.type,
    required this.userId,
  });

  @override
  bool operator ==(Object other) =>
      (identical(this, other)) ||
      (other is AppUser &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          bloodGroup == other.bloodGroup &&
          email == other.email &&
          type == other.type &&
          userId == other.userId);

  @override
  int get hashCode =>
      name.hashCode ^
      phoneNumber.hashCode ^
      bloodGroup.hashCode ^
      email.hashCode ^
      type.hashCode ^
      userId.hashCode;

  @override
  String toString() {
    return 'AppUser{' +
        'name: $name,' +
        'phoneNumber: $phoneNumber,' +
        'bloodGroup: $bloodGroup,' +
        'email: $email,' +
        'type: $type,' +
        'userId: $userId' +
        '}';
  }

  AppUser copyWith({
    String? name,
    String? phoneNumber,
    String? bloodGroup,
    String? email,
    String? type,
    String? userId,
  }) {
    return AppUser(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      email: email ?? this.email,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }
}

Map<String, dynamic> toMap(AppUser user) {
  return <String, dynamic>{
    'name': name,
    'phoneNumber': phoneNumber,
    'bloodGroup': bloodGroup,
    'email': email,
    'type': type,
    'userId': userId,
  };
}

factory AppUser.fromMap(Map<String, dynamic> map) {
  return AppUser(
    name: map['name'] as String,
    phoneNumber: map['phoneNumber'] as String,
    bloodGroup: map['bloodGroup'] as String,
    email: map['email'] as String,
    type: map['type'] as String,
    userId: map['userId'] as String,
  );
}