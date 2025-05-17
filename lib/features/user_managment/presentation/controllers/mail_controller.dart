import 'dart:async';

import 'package:blood_donation/features/user_managment/data/mail_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_controller.g.dart';

@riverpod
class MailController extends _$MailController {
  @override
  FutureOr<void> build() {
    // Initialization logic if needed
  }

  Future<bool> sendEmail(
      {required String donorEmail,
      required String recipientEmail,
      required String recipientName,
      required String recipientPhone,
      required String recipientBloodGroup}) async {
    try {
      state = const AsyncLoading();
      await ref.read(mailRepositoryProvider).sendEmail(
          donorEmail: donorEmail,
          recipientEmail: recipientEmail,
          recipientName: recipientName,
          recipientPhone: recipientPhone,
          recipientBloodGroup: recipientBloodGroup);
      state = const AsyncData(null);
      return true;
    } catch (e, StackTrace) {
      state = AsyncError(e, StackTrace);
      return false;
    }
  }
}
