import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init(WidgetRef ref) async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token, ref);
      }

      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(newToken, ref);
      });
    }
  }

  Future<void> _saveTokenToDatabase(String token, WidgetRef ref) async {
    final user = await ref.read(currentUserProvider.future);
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
