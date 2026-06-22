import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:blood_donation/features/home/data/notifications_repository.dart';
import 'package:blood_donation/features/models/news_item.dart';
import 'package:blood_donation/features/news/presentation/news_feed_controller.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GreetingTimeOfDay { morning, afternoon, evening }

final greetingTimeProvider = Provider<GreetingTimeOfDay>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return GreetingTimeOfDay.morning;
  }
  if (hour < 18) {
    return GreetingTimeOfDay.afternoon;
  }
  return GreetingTimeOfDay.evening;
});

final userStreakProvider = Provider<int>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final lastCheckIn = user?.lastCheckIn;
  if (lastCheckIn == null) {
    return 1;
  }
  final diff = DateTime.now().difference(lastCheckIn).inDays;
  if (diff <= 1) {
    return 2;
  }
  return 1;
});

final upcomingAppointmentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return Stream.value(const []);
  }
  return ref.watch(appointmentRepositoryProvider).getUserAppointments(user.uid);
});

final todayHealthTipsProvider = Provider<List<String>>((ref) {
  final news = ref.watch(newsFeedControllerProvider).items;
  final prevention = news.where((item) {
    final category = item.category.toLowerCase();
    return category.contains('prevention') || category.contains('nutrition');
  }).toList();

  if (prevention.isNotEmpty) {
    return prevention.take(5).map((item) => _toTipSentence(item)).toList();
  }

  return news.take(5).map((item) => _toTipSentence(item)).toList();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications =
      ref.watch(notificationsStreamProvider).valueOrNull ?? const [];
  return notifications.where((item) => !item.isRead).length;
});

String _toTipSentence(NewsItem item) {
  final summary = item.summary.trim();
  if (summary.isEmpty) {
    return item.title;
  }
  if (summary.length <= 90) {
    return summary;
  }
  return '${summary.substring(0, 90)}...';
}
