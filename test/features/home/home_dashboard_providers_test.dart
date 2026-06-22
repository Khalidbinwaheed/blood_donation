import 'package:blood_donation/features/home/data/notifications_repository.dart';
import 'package:blood_donation/features/home/domain/notification_model.dart';
import 'package:blood_donation/features/home/presentation/home_dashboard_providers.dart';
import 'package:blood_donation/features/news/presentation/news_feed_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('news categories include expected tabs', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final categories = container.read(newsCategoriesProvider);
    expect(
        categories,
        containsAll(
            ['All', 'Prevention', 'Nutrition', 'Mental Health', 'Local']));
  });

  test('unread notifications provider counts unread entries', () async {
    final container = ProviderContainer(
      overrides: [
        notificationsStreamProvider.overrideWith((ref) {
          return Stream.value([
            NotificationModel(
              id: '1',
              title: 'A',
              body: 'B',
              timestamp: DateTime.now(),
              isRead: false,
            ),
            NotificationModel(
              id: '2',
              title: 'C',
              body: 'D',
              timestamp: DateTime.now(),
              isRead: true,
            ),
          ]);
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationsStreamProvider.future);
    final count = container.read(unreadNotificationsCountProvider);
    expect(count, 1);
  });
}
