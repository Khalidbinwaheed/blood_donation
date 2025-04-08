import 'dart:async';

import 'package:blood_donation/feathers/user_managment/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initialize any necessary resources or state here
  }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = AsyncError('Ensure All fields are filled', StackTrace.current);
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).signInWithEmailAndPassword(
              email: email,
              password: password,
            ));
  }
}
