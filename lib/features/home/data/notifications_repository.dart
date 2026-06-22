import 'dart:async';

import 'package:blood_donation/features/home/domain/notification_model.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  NotificationsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<NotificationModel>> getNotifications(AppUser user) {
    final userNotificationsStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .snapshots();

    final legacyNotificationsStream = _firestore
        .collection('notifications')
        .doc(user.uid)
        .collection('users emailed')
        .snapshots();

    final requestsStream = _firestore
        .collection('requests')
        .where('status', isEqualTo: 'Open')
        .snapshots();

    return _mergeNotificationStreams(
      user: user,
      userNotificationsStream: userNotificationsStream,
      legacyNotificationsStream: legacyNotificationsStream,
      requestsStream: requestsStream,
    );
  }

  Stream<List<NotificationModel>> _mergeNotificationStreams({
    required AppUser user,
    required Stream<QuerySnapshot<Map<String, dynamic>>>
        userNotificationsStream,
    required Stream<QuerySnapshot<Map<String, dynamic>>>
        legacyNotificationsStream,
    required Stream<QuerySnapshot<Map<String, dynamic>>> requestsStream,
  }) {
    final controller = StreamController<List<NotificationModel>>();
    QuerySnapshot<Map<String, dynamic>>? userSnapshot;
    QuerySnapshot<Map<String, dynamic>>? legacySnapshot;
    QuerySnapshot<Map<String, dynamic>>? requestSnapshot;

    void emit() {
      final merged = <NotificationModel>[
        if (userSnapshot != null) ..._mapUserNotifications(userSnapshot!),
        if (legacySnapshot != null) ..._mapLegacyNotifications(legacySnapshot!),
        if (requestSnapshot != null)
          ..._mapRequestNotifications(
            requestSnapshot: requestSnapshot!,
            user: user,
          ),
      ];

      controller.add(_deduplicateAndSort(merged));
    }

    final subscriptions =
        <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[
      userNotificationsStream.listen(
        (snapshot) {
          userSnapshot = snapshot;
          emit();
        },
        onError: controller.addError,
      ),
      legacyNotificationsStream.listen(
        (snapshot) {
          legacySnapshot = snapshot;
          emit();
        },
        onError: controller.addError,
      ),
      requestsStream.listen(
        (snapshot) {
          requestSnapshot = snapshot;
          emit();
        },
        onError: controller.addError,
      ),
    ];

    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };

    return controller.stream;
  }

  List<NotificationModel> _mapUserNotifications(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return NotificationModel(
        id: data['id']?.toString().trim().isNotEmpty == true
            ? data['id'].toString().trim()
            : doc.id,
        title: data['title']?.toString().trim().isNotEmpty == true
            ? data['title'].toString().trim()
            : 'Notification',
        body: data['body']?.toString().trim().isNotEmpty == true
            ? data['body'].toString().trim()
            : (data['text']?.toString().trim() ?? ''),
        timestamp: _parseTimestamp(data['timestamp']) ??
            _parseTimestamp(data['createdAt']) ??
            DateTime.now(),
        isRead: _asBool(data['isRead']),
        type: data['type']?.toString().trim().isNotEmpty == true
            ? data['type'].toString().trim()
            : 'info',
      );
    }).toList();
  }

  List<NotificationModel> _mapLegacyNotifications(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return NotificationModel(
        id: 'legacy_${doc.id}',
        title: 'Contact update',
        body: data['text']?.toString().trim().isNotEmpty == true
            ? data['text'].toString().trim()
            : 'A donor or recipient interaction was recorded.',
        timestamp: _parseTimestamp(data['timestamp']) ??
            _parseTimestamp(data['date']) ??
            DateTime.now(),
        isRead: _asBool(data['isRead']),
        type: 'blood_request',
      );
    }).toList();
  }

  List<NotificationModel> _mapRequestNotifications({
    required QuerySnapshot<Map<String, dynamic>> requestSnapshot,
    required AppUser user,
  }) {
    final notifications = <NotificationModel>[];
    final userBloodGroup = user.bloodGroup.trim().toUpperCase();

    for (final doc in requestSnapshot.docs) {
      final data = doc.data();
      final requesterId = data['requesterId']?.toString() ?? '';
      final requestBloodGroup =
          data['bloodGroupNeeded']?.toString().trim().toUpperCase() ?? '';

      final createdByCurrentUser = requesterId == user.uid;
      final matchesUserBloodGroup =
          userBloodGroup.isNotEmpty && requestBloodGroup == userBloodGroup;
      if (!createdByCurrentUser && !matchesUserBloodGroup) {
        continue;
      }

      final hospital =
          data['hospitalName']?.toString().trim().isNotEmpty == true
              ? data['hospitalName'].toString().trim()
              : 'Nearby hospital';
      final severity = data['severity']?.toString().trim().isNotEmpty == true
          ? data['severity'].toString().trim()
          : 'High';

      notifications.add(
        NotificationModel(
          id: 'request_${doc.id}',
          title: createdByCurrentUser
              ? 'Your request is active'
              : '$requestBloodGroup blood needed nearby',
          body: createdByCurrentUser
              ? 'We are matching donors for your request at $hospital.'
              : '$severity priority request at $hospital.',
          timestamp: _parseTimestamp(data['createdAt']) ??
              _parseTimestamp(data['deadline']) ??
              DateTime.now(),
          type: 'blood_request',
        ),
      );
    }

    return notifications;
  }

  List<NotificationModel> _deduplicateAndSort(List<NotificationModel> items) {
    final byId = <String, NotificationModel>{};

    for (final item in items) {
      final existing = byId[item.id];
      if (existing == null) {
        byId[item.id] = item;
        continue;
      }

      final latest =
          item.timestamp.isAfter(existing.timestamp) ? item : existing;
      final other = identical(latest, item) ? existing : item;
      byId[item.id] = latest.copyWith(
        title: _hasMeaningfulText(latest.title) ? latest.title : other.title,
        body: _hasMeaningfulText(latest.body) ? latest.body : other.body,
        type: latest.type == 'info' ? other.type : latest.type,
        isRead: existing.isRead || item.isRead,
      );
    }

    final deduplicated = byId.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return deduplicated;
  }

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  bool _hasMeaningfulText(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'notification';
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    final modernRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId);
    final legacyRef = _firestore
        .collection('notifications')
        .doc(userId)
        .collection('users emailed')
        .doc(notificationId);

    try {
      final modernDoc = await modernRef.get();
      if (modernDoc.exists) {
        await modernRef.update({'isRead': true});
      }
    } catch (_) {
      // Non-blocking UI flow.
    }

    try {
      final legacyDoc = await legacyRef.get();
      if (legacyDoc.exists) {
        await legacyRef.update({'isRead': true});
      }
    } catch (_) {
      // Non-blocking UI flow.
    }
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<NotificationModel>> notificationsStream(Ref ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return Stream.value(const <NotificationModel>[]);
  }
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.getNotifications(user);
}
