import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Future<void> signInWithEmailAndPassowrd({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String phoneNumber,
    required String type,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseFireStore = FirebaseFirestore.instance;
    final appUser = AppUser(
      name: name,
      phoneNumber: phoneNumber,
      bloodGroup: bloodGroup,
      email: email,
      type: type,
      userId: cred.user!.uid,
    );

    await firebaseFireStore
        .collection('users')
        .doc(cred.user!.uid)
        .set(appUser.toMap());
  }
}
