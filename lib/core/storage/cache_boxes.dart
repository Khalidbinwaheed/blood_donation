import 'package:hive_flutter/hive_flutter.dart';

class CacheBoxes {
  CacheBoxes._();

  static const String news = 'news_cache_box';
  static const String chat = 'chat_cache_box';
  static const String settings = 'settings_cache_box';
  static const String banners = 'banners_cache_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      if (!Hive.isBoxOpen(news)) Hive.openBox(news),
      if (!Hive.isBoxOpen(chat)) Hive.openBox(chat),
      if (!Hive.isBoxOpen(settings)) Hive.openBox(settings),
      if (!Hive.isBoxOpen(banners)) Hive.openBox(banners),
    ]);
  }
}
