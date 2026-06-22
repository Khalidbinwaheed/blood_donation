import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'mail_repository.g.dart';

class Mailrepository {
  Mailrepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> sendEmail({
    required String donorEmail,
    required String recipientEmail,
    required String recipientName,
    required String recipientPhone,
    required String recipientBloodGroup,
    String? donorUid,
    String? recipientUid,
  }) async {
    final title = 'Blood donation request from $recipientName';
    final body = '$recipientName needs $recipientBloodGroup blood.\n'
        'Phone: $recipientPhone\n'
        'Email: $recipientEmail';

    if (donorUid != null && donorUid.trim().isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(donorUid)
          .collection('notifications')
          .add({
        'title': title,
        'body': body,
        'type': 'blood_request',
        'recipientEmail': recipientEmail,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'recipientBloodGroup': recipientBloodGroup,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
      return;
    }

    final donorQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: donorEmail.trim())
        .limit(1)
        .get();
    if (donorQuery.docs.isEmpty) {
      throw Exception('Donor profile not found for $donorEmail');
    }

    await _firestore
        .collection('users')
        .doc(donorQuery.docs.first.id)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'type': 'blood_request',
      'recipientUid': recipientUid,
      'recipientEmail': recipientEmail,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'recipientBloodGroup': recipientBloodGroup,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}

@riverpod
Mailrepository mailRepository(Ref ref) {
  return Mailrepository(FirebaseFirestore.instance);
}
