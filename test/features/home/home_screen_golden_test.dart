import 'dart:io';

import 'package:blood_donation/core/network/connectivity_provider.dart';
import 'package:blood_donation/core/storage/cache_boxes.dart';
import 'package:blood_donation/features/home/data/notifications_repository.dart';
import 'package:blood_donation/features/home/domain/notification_model.dart';
import 'package:blood_donation/features/home/presentation/home_dashboard_providers.dart';
import 'package:blood_donation/features/home/presentation/home_screen.dart';
import 'package:blood_donation/features/map/presentation/nearby_places_provider.dart';
import 'package:blood_donation/features/models/chat_message.dart';
import 'package:blood_donation/features/models/news_item.dart';
import 'package:blood_donation/features/services/chat_service.dart';
import 'package:blood_donation/features/services/news_service.dart';
import 'package:blood_donation/features/services/service_providers.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeNewsService implements NewsService {
  @override
  Future<NewsFetchResult> fetch({
    required String category,
    required int page,
    required int pageSize,
    required String lang,
    required String region,
  }) async {
    return NewsFetchResult(
      items: [
        NewsItem(
          id: 'n1',
          title: 'Simple habits that improve heart health',
          summary: 'Doctors recommend 30 minutes of activity daily',
          imageUrl: '',
          source: 'HealthLine',
          publishedAt: DateTime.now(),
          url: '',
          category: 'Prevention',
          isSaved: false,
        ),
      ],
      hasMore: false,
      nextPage: 1,
    );
  }

  @override
  Stream<List<NewsItem>> live({
    required String category,
    required String lang,
    required String region,
  }) {
    return const Stream.empty();
  }
}

class _FakeChatService implements ChatService {
  @override
  Future<ChatMessage> send({
    required String userId,
    required String message,
    required Map<String, dynamic> context,
  }) async {
    return ChatMessage(
      id: 'assistant_1',
      role: ChatRole.assistant,
      text: 'Drink water and sleep on time.',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  setUpAll(() async {
    final path = Directory.systemTemp.createTempSync('health_helper_test').path;
    Hive.init(path);
    await Hive.openBox<dynamic>(CacheBoxes.news);
    await Hive.openBox<dynamic>(CacheBoxes.chat);
    await Hive.openBox<dynamic>(CacheBoxes.settings);
    await Hive.openBox<dynamic>(CacheBoxes.banners);
  });

  tearDown(() async {
    await Hive.box<dynamic>(CacheBoxes.news).clear();
    await Hive.box<dynamic>(CacheBoxes.chat).clear();
    await Hive.box<dynamic>(CacheBoxes.settings).clear();
    await Hive.box<dynamic>(CacheBoxes.banners).clear();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required ThemeMode mode,
  }) async {
    final user = const AppUser(
      uid: 'u1',
      email: 'demo@example.com',
      firstName: 'Sam',
      role: 'recipient',
      type: 'recipient',
      bloodGroup: 'O+',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
          notificationsStreamProvider.overrideWith((ref) {
            return Stream.value([
              NotificationModel(
                id: 'n_1',
                title: 'Reminder',
                body: 'Stay hydrated',
                timestamp: DateTime.now(),
                isRead: false,
              ),
            ]);
          }),
          newsServiceProvider.overrideWithValue(_FakeNewsService()),
          chatServiceProvider.overrideWithValue(_FakeChatService()),
          todayHealthTipsProvider.overrideWith((ref) => const [
                'Drink water every 2 hours',
                'Take a short walk after meals',
              ]),
          upcomingAppointmentsProvider
              .overrideWith((ref) => Stream.value(const [])),
          unreadNotificationsCountProvider.overrideWith((ref) => 1),
          nearbyPlacesProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Home screen light golden', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpHome(tester, mode: ThemeMode.light);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen_light.png'),
    );
  });

  testWidgets('Home screen dark golden', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpHome(tester, mode: ThemeMode.dark);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen_dark.png'),
    );
  });
}
