import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/firebase_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

AppUser buildAppUserFromFirestore({
  required String uid,
  required Map<String, dynamic>? data,
  String? fallbackEmail,
}) {
  final normalizedData = Map<String, dynamic>.from(data ?? const {});
  final normalizedRole = _normalizeRole(
    normalizedData['role']?.toString(),
    normalizedData['type']?.toString(),
  );
  final normalizedType =
      _normalizeType(normalizedData['type']?.toString(), normalizedRole);

  normalizedData['uid'] =
      (normalizedData['uid']?.toString().trim().isNotEmpty ?? false)
          ? normalizedData['uid'].toString().trim()
          : uid;
  normalizedData['email'] =
      (normalizedData['email']?.toString().trim().isNotEmpty ?? false)
          ? normalizedData['email'].toString().trim()
          : (fallbackEmail ?? '');
  normalizedData['role'] = normalizedRole;
  normalizedData['type'] = normalizedType;
  normalizedData['phoneNumber'] =
      normalizedData['phoneNumber']?.toString() ?? '';
  normalizedData['bloodGroup'] = normalizedData['bloodGroup']?.toString() ?? '';
  normalizedData['district'] = normalizedData['district']?.toString() ?? '';
  normalizedData['allergies'] = _asStringList(normalizedData['allergies']);
  normalizedData['conditions'] = _asStringList(normalizedData['conditions']);
  normalizedData['lastDonationDate'] =
      _toIsoDateString(normalizedData['lastDonationDate']);
  normalizedData['lastCheckIn'] =
      _toIsoDateString(normalizedData['lastCheckIn']);

  try {
    return AppUser.fromJson(normalizedData);
  } catch (_) {
    return AppUser(
      uid: uid,
      email: normalizedData['email']?.toString() ?? (fallbackEmail ?? ''),
      firstName: normalizedData['firstName']?.toString(),
      lastName: normalizedData['lastName']?.toString(),
      role: normalizedRole,
      type: normalizedType,
      phoneNumber: normalizedData['phoneNumber']?.toString() ?? '',
      bloodGroup: normalizedData['bloodGroup']?.toString() ?? '',
      district: normalizedData['district']?.toString() ?? '',
      donorEligibilityStatus:
          normalizedData['donorEligibilityStatus']?.toString() ?? 'unknown',
      allergies: _asStringList(normalizedData['allergies']),
      conditions: _asStringList(normalizedData['conditions']),
      lastDonationDate: _toDateTime(normalizedData['lastDonationDate']),
      lastCheckIn: _toDateTime(normalizedData['lastCheckIn']),
    );
  }
}

String _normalizeRole(String? role, String? type) {
  final normalizedRole = role?.trim().toLowerCase() ?? '';
  if (normalizedRole.isNotEmpty) {
    return normalizedRole;
  }

  final normalizedType = type?.trim().toLowerCase() ?? '';
  if (normalizedType == 'donor' ||
      normalizedType == 'recipient' ||
      normalizedType == 'doctor' ||
      normalizedType == 'admin' ||
      normalizedType == 'super_admin') {
    return normalizedType;
  }
  return 'recipient';
}

String _normalizeType(String? type, String normalizedRole) {
  final normalizedType = type?.trim().toLowerCase() ?? '';
  if (normalizedType.isNotEmpty) {
    return normalizedType;
  }
  if (normalizedRole == 'donor' ||
      normalizedRole == 'recipient' ||
      normalizedRole == 'doctor' ||
      normalizedRole == 'admin' ||
      normalizedRole == 'super_admin') {
    return normalizedRole;
  }
  return 'recipient';
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const <String>[];
}

String? _toIsoDateString(dynamic value) {
  final date = _toDateTime(value);
  return date?.toIso8601String();
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<void> signInWithGoogle();
  Future<bool> authenticateWithBiometrics();
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String type,
    String? phoneNumber,
    String? district,
  });
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> signIn(String email, String password);
  Future<void> updateProfilePicture(String uid, XFile image);
}

class MockAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> get authStateChanges => Stream.value(
        const AppUser(
          uid: 'mock_uid_123',
          email: 'alex@example.com',
          firstName: 'Alex',
          lastName: 'Doe',
          role: 'patient',
          donorEligibilityStatus: 'eligible',
          phoneNumber: '1234567890',
          bloodGroup: 'O+',
          type: 'donor',
          district: 'Downtown',
        ),
      );

  @override
  Future<AppUser?> getCurrentUser() async {
    return const AppUser(
      uid: 'mock_uid_123',
      email: 'alex@example.com',
      firstName: 'Alex',
      lastName: 'Doe',
      role: 'patient',
      donorEligibilityStatus: 'eligible',
      phoneNumber: '1234567890',
      bloodGroup: 'O+',
      type: 'donor',
      district: 'Downtown',
    );
  }

  @override
  Future<void> signIn(String email, String password) async {
    await signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return true;
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String type,
    String? phoneNumber,
    String? district,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateProfilePicture(String uid, XFile image) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

final loadUserInformationProvider =
    FutureProvider.family<AppUser?, String>((ref, uid) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return buildAppUserFromFirestore(uid: uid, data: doc.data());
    }
  } catch (_) {
    // Let UI fallback gracefully.
  }
  return null;
});

final userProfileStreamProvider = StreamProvider.family<AppUser?, String>(
  (ref, uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }
      return buildAppUserFromFirestore(uid: uid, data: doc.data());
    });
  },
);
