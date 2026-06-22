import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:blood_donation/core/config/app_env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      return _fetchUserProfile(firebaseUser);
    });
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return _fetchUserProfile(firebaseUser);
  }

  Future<AppUser?> _fetchUserProfile(User firebaseUser) async {
    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return buildAppUserFromFirestore(
          uid: firebaseUser.uid,
          data: doc.data(),
          fallbackEmail: firebaseUser.email,
        );
      }
    } catch (_) {
      // UI gracefully falls back to auth user data below.
    }

    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      firstName: firebaseUser.displayName,
      role: 'recipient',
      type: 'recipient',
    );
  }

  @override
  Future<void> signIn(String email, String password) async {
    await signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: AppEnv.hasGoogleWebClientId ? AppEnv.googleWebClientId : null,
      serverClientId:
          AppEnv.hasGoogleWebClientId ? AppEnv.googleWebClientId : null,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _ensureGoogleUserProfile(userCredential.user, googleUser);
  }

  Future<void> _ensureGoogleUserProfile(
    User? firebaseUser,
    GoogleSignInAccount googleUser,
  ) async {
    if (firebaseUser == null) {
      return;
    }

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return;
    }

    final displayName = (googleUser.displayName ?? firebaseUser.displayName ?? '')
        .trim();
    final parts = displayName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final newUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? googleUser.email,
      firstName: firstName,
      lastName: lastName,
      photoUrl: googleUser.photoUrl ?? firebaseUser.photoURL,
      role: 'recipient',
      type: 'recipient',
      donorEligibilityStatus: 'unknown',
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set(
          newUser.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    if (kIsWeb) {
      return false;
    }

    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics;
    final supported = await localAuth.isDeviceSupported();
    if (!canCheck && !supported) {
      return false;
    }

    return localAuth.authenticate(
      localizedReason: 'Authenticate with biometrics to access Lifeline',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
      ),
    );
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
    // 1. Create Auth User
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    // 2. Parse Name
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final normalizedType = type.trim().toLowerCase();
    String normalizedRole;
    switch (normalizedType) {
      case 'donor':
        normalizedRole = 'donor';
        break;
      case 'recipient':
        normalizedRole = 'recipient';
        break;
      case 'doctor':
        normalizedRole = 'doctor';
        break;
      case 'admin':
        normalizedRole = 'admin';
        break;
      case 'super_admin':
        normalizedRole = 'super_admin';
        break;
      default:
        normalizedRole = 'recipient';
    }

    // 3. Create AppUser Object
    final newUser = AppUser(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber ?? '',
      bloodGroup: bloodGroup,
      role: normalizedRole,
      type: normalizedType,
      district: district ?? '',
      donorEligibilityStatus: 'pending', // Default
    );

    // 4. Write to Firestore
    await _firestore.collection('users').doc(uid).set(newUser.toJson());

    // 5. Best-effort profile init. Registration should still succeed even if
    // profile rules are stricter in some environments.
    try {
      await _firestore.collection('profiles').doc(uid).set({
        'bloodType': bloodGroup,
        'conditions': [],
        'allergies': [],
        'donorEligibilityStatus': 'pending',
      });
    } catch (_) {
      // Ignore profile bootstrap failures.
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> updateProfilePicture(String uid, XFile image) async {
    final ref =
        FirebaseStorage.instance.ref().child('user_profiles').child('$uid.jpg');
    final uploadTask = await ref.putFile(File(image.path));
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).update({
      'photoUrl': downloadUrl,
    });
  }
}
