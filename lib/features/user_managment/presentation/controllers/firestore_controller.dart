import 'dart:async';

import 'package:blood_donation/features/user_managment/Domain/app_notification.dart';
import 'package:blood_donation/features/user_managment/data/firestore_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_controller.g.dart';

@riverpod
class FirestoreController extends _$FirestoreController {
  @override
  FutureOr<void> build() {}

  Future<void> saveIdToDatabase({
    required String recipientId,
    required String donorId,
  }) async {
    final firestoreRepository = ref.read(firestoreRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await firestoreRepository.saveIdToDatabase(
        recipientId: recipientId,
        donorId: donorId,
      );
    });
  }

  Future<void> addNotification({
    required String recipientId,
    required String donorId,
    required AppNotification notification,
  }) async {
    final firestoreRepository = ref.read(firestoreRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await firestoreRepository.addNotification(
        recipientId: recipientId,
        donorId: donorId,
        notification: notification,
      );
    });
  }
}
