import 'package:blood_donation/features/user_management/Domain/app_notification.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart'; // Make sure this path is correct
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'firestore_repository.g.dart';

class FirestoreRepository {
  FirestoreRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // --- Firestore Constants ---
  static const String _usersCollection = 'users';
  static const String _typeField = 'type';
  static const String _roleField = 'role';
  static const String _bloodGroupField = 'bloodGroup';
  static const List<String> _bloodGroupFallbackFields = [
    'bloodGroup',
    'blood_group',
    'bloodType',
    'blood_type',
  ];
  static const String _donorType = 'donor';
  // ---

  /// Loads all users marked as donors.
  Stream<List<AppUser>> loadDonors() {
    return _firestore.collection(_usersCollection).snapshots().map(
          (querySnapshot) => querySnapshot.docs
              .where((doc) => _isDonor(doc.data()))
              .map((doc) =>
                  buildAppUserFromFirestore(uid: doc.id, data: doc.data()))
              .toList(),
        );
  }

  /// Loads donors with a specific blood group.
  Stream<List<AppUser>> loadSpecificBloodGroupDonors(String bloodGroup) {
    final normalizedBloodGroup = _normalizeBloodGroup(bloodGroup);
    return _firestore.collection(_usersCollection).snapshots().map(
          (querySnapshot) => querySnapshot.docs.where((doc) {
            final data = doc.data();
            final group = _normalizeBloodGroup(_extractBloodGroup(data));
            return _isDonor(data) && group == normalizedBloodGroup;
          }).map((doc) {
            return buildAppUserFromFirestore(uid: doc.id, data: doc.data());
          }).toList(),
        );
  }

  Stream<List<AppUser>> loadSimilarBloodGroups(String bloodGroup) {
    return loadSpecificBloodGroupDonors(bloodGroup);
  }

  /// Loads doctors associated with a specific center.
  Stream<List<AppUser>> loadDoctorsByCenter(String centerId) {
    return _firestore
        .collection(_usersCollection)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.where((doc) {
        final data = doc.data();
        final role = data[_roleField]?.toString().trim().toLowerCase() ?? '';
        final type = data[_typeField]?.toString().trim().toLowerCase() ?? '';
        final center = data['centerId']?.toString() ?? '';
        return (role == 'doctor' || type == 'doctor') && center == centerId;
      }).map((doc) {
        return buildAppUserFromFirestore(uid: doc.id, data: doc.data());
      }).toList();
    });
  }

  /// Loads all registered users (for Admin Dashboard).
  Stream<List<AppUser>> loadAllUsers() {
    return _firestore
        .collection(_usersCollection)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map(
              (doc) => buildAppUserFromFirestore(uid: doc.id, data: doc.data()))
          .toList();
    });
  }

  Future<void> saveIdToDatabase({
    required String recipientId,
    required String donorId,
  }) async {
    await _firestore
        .collection('emails')
        .doc(recipientId)
        .collection('users emailed')
        .add({donorId: true});
    await _firestore
        .collection('emails')
        .doc(donorId)
        .collection('users emailed')
        .add({recipientId: true});
  }

  Future<void> addNotification(
      {required String recipientId,
      required String donorId,
      required AppNotification notification}) async {
    await _firestore
        .collection('notifications')
        .doc(donorId)
        .collection('users emailed')
        .add(notification.toMap());
    await _firestore
        .collection('notifications')
        .doc(recipientId)
        .collection('users emailed')
        .add(notification.toMap());
  }

  Stream<List<AppNotification>> loadNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('users emailed')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data()))
            .toList());
  }

  Stream<List<String>> loadEmailedUsersIds(String userId) {
    return _firestore
        .collection('emails')
        .doc(userId)
        .collection('users emailed')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => doc.data().keys.toList())
          .expand((keys) => keys)
          .toList();
    });
  }

  bool _isDonor(Map<String, dynamic> data) {
    final role = data[_roleField]?.toString().trim().toLowerCase() ?? '';
    final type = data[_typeField]?.toString().trim().toLowerCase() ?? '';
    final donorLikeValues = <String>{
      _donorType,
      'doner',
      'volunteer',
      'blood_donor',
    };
    return donorLikeValues.contains(role) || donorLikeValues.contains(type);
  }

  String _extractBloodGroup(Map<String, dynamic> data) {
    for (final key in _bloodGroupFallbackFields) {
      final value = data[key]?.toString() ?? '';
      if (value.trim().isNotEmpty) {
        return value;
      }
    }
    return data[_bloodGroupField]?.toString() ?? '';
  }

  String _normalizeBloodGroup(String value) => value.trim().toUpperCase();
}
// --- Riverpod Providers ---

/// Provides the FirebaseFirestore instance.
@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provides the FirestoreRepository instance.
@riverpod
FirestoreRepository firestoreRepository(Ref ref) {
  // Get the Firestore instance from its provider and inject it
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreRepository(firestore);
}

/// Provider to stream all donors.
@riverpod
Stream<List<AppUser>> loadDonors(Ref ref) {
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadDonors();
}

/// Provider to stream donors of a specific blood group.
@riverpod
Stream<List<AppUser>> loadSpecificBloodGroupDonors(Ref ref, String bloodGroup) {
  // Watch the repository provider
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadSpecificBloodGroupDonors(bloodGroup);
}

@riverpod
Stream<List<AppUser>> loadSimilarBloodGroups(Ref ref, String bloodGroup) {
  // Watch the repository provider
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadSimilarBloodGroups(bloodGroup);
}

@riverpod
Stream<List<AppUser>> loadDoctorsByCenter(Ref ref, String centerId) {
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadDoctorsByCenter(centerId);
}

@riverpod
Stream<List<AppUser>> loadAllUsers(Ref ref) {
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadAllUsers();
}
