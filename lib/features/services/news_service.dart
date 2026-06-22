import 'dart:async';
import 'dart:convert';

import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/features/models/news_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NewsFetchResult {
  const NewsFetchResult({
    required this.items,
    required this.hasMore,
    required this.nextPage,
  });

  final List<NewsItem> items;
  final bool hasMore;
  final int nextPage;
}

abstract class NewsService {
  Future<NewsFetchResult> fetch({
    required String category,
    required int page,
    required int pageSize,
    required String lang,
    required String region,
  });

  Stream<List<NewsItem>> live({
    required String category,
    required String lang,
    required String region,
  });
}

class ApiNewsService implements NewsService {
  ApiNewsService(this._dio);

  final Dio _dio;

  @override
  Future<NewsFetchResult> fetch({
    required String category,
    required int page,
    required int pageSize,
    required String lang,
    required String region,
  }) async {
    if (!AppEnv.hasNewsApi) {
      throw Exception('NEWS_API_URL is not configured');
    }

    final query = <String, dynamic>{
      'topic': category.toLowerCase() == 'all' ? 'health' : category,
      'lang': lang,
      'region': region,
      'page': page,
      'limit': pageSize,
    };

    final response = await _dio.get<Map<String, dynamic>>(
      AppEnv.newsApiUrl,
      queryParameters: query,
      options: Options(
        headers: {
          if (AppEnv.newsApiKey.trim().isNotEmpty)
            'Authorization': 'Bearer ${AppEnv.newsApiKey}',
        },
      ),
    );

    final data = response.data ?? const <String, dynamic>{};
    final rawList = _extractList(data);
    final items = rawList.map(NewsItem.fromJson).toList();
    final hasMore = _resolveHasMore(data, items.length, pageSize);
    final nextPage = hasMore ? page + 1 : page;

    return NewsFetchResult(
      items: items,
      hasMore: hasMore,
      nextPage: nextPage,
    );
  }

  @override
  Stream<List<NewsItem>> live({
    required String category,
    required String lang,
    required String region,
  }) async* {
    if (AppEnv.newsStreamUrl.trim().isEmpty) {
      return;
    }

    final uri = Uri.parse(AppEnv.newsStreamUrl);
    final channel = WebSocketChannel.connect(uri);
    try {
      await channel.ready;
      channel.sink.add(jsonEncode({
        'topic': category.toLowerCase() == 'all' ? 'health' : category,
        'lang': lang,
        'region': region,
      }));

      await for (final event in channel.stream) {
        final map = jsonDecode(event.toString());
        if (map is Map<String, dynamic>) {
          final payload = _extractList(map);
          yield payload.map(NewsItem.fromJson).toList();
        } else if (map is List) {
          final payload = map
              .whereType<Map<String, dynamic>>()
              .map(NewsItem.fromJson)
              .toList();
          yield payload;
        }
      }
    } finally {
      await channel.sink.close();
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> data) {
    final candidates = [
      data['articles'],
      data['items'],
      data['results'],
      data['data'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }

  bool _resolveHasMore(
    Map<String, dynamic> data,
    int currentCount,
    int pageSize,
  ) {
    final apiHasMore = data['hasMore'];
    if (apiHasMore is bool) {
      return apiHasMore;
    }
    final next = data['nextPage'];
    if (next is int) {
      return next > 0;
    }
    return currentCount >= pageSize;
  }
}

class FirestoreNewsService implements NewsService {
  FirestoreNewsService(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<NewsFetchResult> fetch({
    required String category,
    required int page,
    required int pageSize,
    required String lang,
    required String region,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .limit(page * pageSize);

    if (category.toLowerCase() != 'all') {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;
    final from = (page - 1) * pageSize;
    final slice = docs.skip(from).take(pageSize);
    final items = slice.map((doc) {
      final data = doc.data();
      return NewsItem.fromJson({
        'id': doc.id,
        ...data,
      });
    }).toList();

    final hasMore = docs.length >= page * pageSize;
    return NewsFetchResult(
      items: items,
      hasMore: hasMore,
      nextPage: hasMore ? page + 1 : page,
    );
  }

  @override
  Stream<List<NewsItem>> live({
    required String category,
    required String lang,
    required String region,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .limit(30);
    if (category.toLowerCase() != 'all') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NewsItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }
}

class MockNewsService implements NewsService {
  const MockNewsService();

  @override
  Future<NewsFetchResult> fetch({
    required String category,
    required int page,
    required int pageSize,
    required String lang,
    required String region,
  }) async {
    throw UnimplementedError(
      'MockNewsService is available for tests only.',
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
