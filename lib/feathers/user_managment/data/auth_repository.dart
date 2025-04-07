import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Domain/app_user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// Signs in a user with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Error handling
      throw Exception('Error signing in: $e');
    }
  }

  /// Creates a new user with email, password, and additional details
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String phoneNumber,
    required String type,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseFirestore = FirebaseFirestore.instance;
      final appUser = AppUser(
        name: name,
        phoneNumber: phoneNumber,
        bloodGroup: bloodGroup,
        email: email,
        type: type,
        userId: cred.user!.uid,
      );

      await firebaseFirestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(appUser.toMap());
    } catch (e) {
      // Error handling
      throw Exception('Error creating user: $e');
    }
  }

  /// Gets the currently signed-in user
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      // Error handling
      throw Exception('Error fetching current user: $e');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Error handling
      throw Exception('Error signing out: $e');
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(FirebaseAuth.instance);
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(authRepositoryProvider).currentUser;
}