import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State class for Auth
class AuthState {
  final bool isLoading;
  final String? error;
  final User? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable override
      user: user ?? this.user,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthViewModel() : super(const AuthState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, user: credential.user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String role,
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Write profile to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'bloodGroup': bloodGroup,
          'role': role,
          'isAvailable': role == 'donor', // Default availability for donors
          'location': lat != null && lng != null
              ? GeoPoint(lat, lng)
              : null, // Pro-Tip: Immediate location
          'createdAt': FieldValue.serverTimestamp(),
        });

        state = state.copyWith(isLoading: false, user: user);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void signOut() async {
    await _auth.signOut();
    state = const AuthState();
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
});
