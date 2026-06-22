import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  NotificationService();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init(WidgetRef ref) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (_) {},
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      if (notification == null) {
        return;
      }
      await _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'Lifeline',
        body: notification.body ?? '',
      );
    });

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token, ref);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(newToken, ref);
      });
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'lifeline_alerts',
        'Lifeline Alerts',
        channelDescription: 'Blood requests, messages, and emergency updates',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _localNotifications.show(id, title, body, details);
  }

  Future<void> _saveTokenToDatabase(String token, WidgetRef ref) async {
    final user = await ref.read(currentUserProvider.future);
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }
  }

  Future<void> notifyUser({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
