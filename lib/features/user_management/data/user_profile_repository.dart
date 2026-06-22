import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotificationPrefs {
  const UserNotificationPrefs({
    required this.urgentAlerts,
    required this.appointmentReminders,
  });

  final bool urgentAlerts;
  final bool appointmentReminders;

  factory UserNotificationPrefs.fromMap(Map<String, dynamic>? data) {
    final prefs = data ?? const <String, dynamic>{};
    return UserNotificationPrefs(
      urgentAlerts: prefs['urgentAlerts'] as bool? ?? true,
      appointmentReminders: prefs['appointmentReminders'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'urgentAlerts': urgentAlerts,
      'appointmentReminders': appointmentReminders,
    };
  }
}

class UserProfileRepository {
  UserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> updateBloodGroup({
    required String uid,
    required String bloodGroup,
  }) async {
    final normalized = bloodGroup.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw ArgumentError('Blood group cannot be empty');
    }

    await _firestore.collection('users').doc(uid).set(
      {'bloodGroup': normalized},
      SetOptions(merge: true),
    );
    await _firestore.collection('profiles').doc(uid).set(
      {'bloodType': normalized},
      SetOptions(merge: true),
    );
  }

  Future<void> updateNotificationPrefs({
    required String uid,
    required UserNotificationPrefs prefs,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {'notificationPrefs': prefs.toMap()},
      SetOptions(merge: true),
    );
  }

  Stream<UserNotificationPrefs> watchNotificationPrefs(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      final prefs = data?['notificationPrefs'];
      if (prefs is Map<String, dynamic>) {
        return UserNotificationPrefs.fromMap(prefs);
      }
      return const UserNotificationPrefs(
        urgentAlerts: true,
        appointmentReminders: false,
      );
    });
  }
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(FirebaseFirestore.instance);
});

final userNotificationPrefsProvider =
    StreamProvider.family<UserNotificationPrefs, String>((ref, uid) {
  return ref.watch(userProfileRepositoryProvider).watchNotificationPrefs(uid);
});
