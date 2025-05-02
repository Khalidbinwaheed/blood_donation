import 'package:blood_donation/features/user_managment/Domain/app_user.dart'; // Make sure this path is correct
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_repository.g.dart';

class FirestoreRepository {
  FirestoreRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // --- Firestore Constants ---
  static const String _usersCollection = 'users';
  static const String _typeField = 'type';
  static const String _bloodGroupField = 'bloodGroup';
  static const String _donorType = 'Donor';
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
        .where(_bloodGroupField, isEqualTo: bloodGroup) // Currently filters for exact match
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => AppUser.fromMap(doc.data()))
            .toList());
  }
}

// --- Riverpod Providers ---

/// Provides the FirebaseFirestore instance.
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Provides the FirestoreRepository instance.
@riverpod
FirestoreRepository firestoreRepository(FirestoreRepositoryRef ref) {
  // Get the Firestore instance from its provider and inject it
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreRepository(firestore);
}

/// Provider to stream all donors.
@riverpod
Stream<List<AppUser>> loadDonors(LoadDonorsRef ref) {
  
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadDonors();
}

/// Provider to stream donors of a specific blood group.
@riverpod
Stream<List<AppUser>> loadSpecificBloodGroupDonors(
    LoadSpecificBloodGroupDonorsRef ref, String bloodGroup) {
  // Watch the repository provider
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadSpecificBloodGroupDonors(bloodGroup);
}

@riverpod
Stream<List<AppUser>> loadSimilarBloodGroups(
    LoadSimilarBloodGroupsRef ref, String bloodGroup) {
  // Watch the repository provider
  final firestoreRepository = ref.watch(firestoreRepositoryProvider);
  return firestoreRepository.loadSimilarBloodGroups(bloodGroup);
}