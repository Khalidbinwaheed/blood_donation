import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blood_donation/features/home/domain/notification_model.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore;

  NotificationsRepository(this._firestore);

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Ideally data has all fields, but we ensure ID is correct
        // The id from doc.id overrides whatever might be in data['id'] if we use copyWith
        // But fromJson expects 'id' if required.
        // Let's modify fromJson usage a bit or ensure data has id.
        // Actually, if we make ID not required in json or handle it manually.
        // Let's passed data and then copyWith.
        // Note: fromJson will throw if 'id' is missing and it's required.
        // We should probably make 'id' optional in constructor or nullable, OR add it to map before parsing.
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<NotificationModel>> notificationsStream(Ref ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final repository = ref.watch(notificationsRepositoryProvider);
      return repository.getNotifications(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}
