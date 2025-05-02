import 'dart:async';

import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initialize any necessary resources or state here
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = AsyncError('Ensure all fields are filled', StackTrace.current);
      return; // Add a return to prevent further execution
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String bloodGroup,
    required String type,
    required String district,
  }) async {
    if (email.trim().isEmpty ||
        password.trim().isEmpty ||
        name.trim().isEmpty ||
        phoneNumber.trim().isEmpty ||
        district.trim().isEmpty ||
        bloodGroup.isEmpty) {
      state = AsyncError('Ensure all fields are filled', StackTrace.current);
      return; // Add a return to prevent further execution
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
              email: email,
              password: password,
              name: name,
              bloodGroup: bloodGroup,
              phoneNumber: phoneNumber,
              district: district,
              type: type,
            ));
  }
}
