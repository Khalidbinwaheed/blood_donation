import 'package:firebase_auth/firebase_auth.dart';

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
    final cred = _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
  }
}
