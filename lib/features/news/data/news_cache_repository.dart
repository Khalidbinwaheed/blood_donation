import 'package:blood_donation/core/storage/cache_boxes.dart';
import 'package:blood_donation/features/models/news_item.dart';
import 'package:hive/hive.dart';

class NewsCacheRepository {
  NewsCacheRepository(this._box);

  final Box<dynamic> _box;

  static String makeKey({
    required String category,
    required String lang,
    required String region,
  }) {
    return 'news::$category::$lang::$region';
  }

  List<NewsItem> load({
    required String category,
    required String lang,
    required String region,
    required Duration maxAge,
  }) {
    final key = makeKey(category: category, lang: lang, region: region);
    final map = _box.get(key);
    if (map is! Map) {
      return const [];
    }
    final storedAtMillis = map['storedAtMillis'];
    if (storedAtMillis is! int) {
      return const [];
    }
    final storedAt = DateTime.fromMillisecondsSinceEpoch(storedAtMillis);
    if (DateTime.now().difference(storedAt) > maxAge) {
      return const [];
    }

    final rawItems = map['items'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map>()
        .map((json) => NewsItem.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> save({
    required String category,
    required String lang,
    required String region,
    required List<NewsItem> items,
  }) async {
    final key = makeKey(category: category, lang: lang, region: region);
    await _box.put(key, {
      'storedAtMillis': DateTime.now().millisecondsSinceEpoch,
      'items': items.map((item) => item.toJson()).toList(),
    });
  }
}

NewsCacheRepository buildDefaultNewsCacheRepository() {
  final box = Hive.box<dynamic>(CacheBoxes.news);
  return NewsCacheRepository(box);
}
