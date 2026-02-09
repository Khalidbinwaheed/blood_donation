import 'package:blood_donation/features/user_managment/Domain/app_user.dart';
import 'package:blood_donation/features/user_managment/data/firebase_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String bloodGroup,
    required String type,
    required String district,
  });
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> signIn(String email, String password);
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
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String bloodGroup,
    required String type,
    required String district,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
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
    FutureProvider.family<AppUser, String>((ref, uid) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromJson(doc.data()!);
    }
  } catch (e) {
    // Log error
  }
  // Return a minimal valid user or throw to handle in UI
  throw Exception('User not found');
});
