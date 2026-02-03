import 'package:blood_donation/features/user_managment/Domain/app_notification.dart';
import 'package:blood_donation/features/user_managment/Domain/app_user.dart'; // Make sure this path is correct
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
  static const String _bloodGroupField = 'bloodGroup';
  static const String _donorType = 'donor';
  // ---

  /// Loads all users marked as donors.
  Stream<List<AppUser>> loadDonors() {
    return _firestore // Use injected instance
        .collection(_usersCollection)
        .where(_typeField, isEqualTo: _donorType)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
  }

  /// Loads donors with a specific blood group.
  Stream<List<AppUser>> loadSpecificBloodGroupDonors(String bloodGroup) {
    return _firestore // Use injected instance
        .collection(_usersCollection)
        .where(_typeField, isEqualTo: _donorType)
        .where(_bloodGroupField, isEqualTo: bloodGroup)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
  }

  Stream<List<AppUser>> loadSimilarBloodGroups(String bloodGroup) {
    return _firestore // Use injected instance
        .collection(_usersCollection) // Corrected collection name
        .where(_typeField, isEqualTo: _donorType)
        .where(_bloodGroupField,
            isEqualTo: bloodGroup) // Currently filters for exact match
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
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
