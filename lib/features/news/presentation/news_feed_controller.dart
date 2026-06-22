import 'dart:async';

import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/core/network/connectivity_provider.dart';
import 'package:blood_donation/core/services/analytics_service.dart';
import 'package:blood_donation/features/models/news_item.dart';
import 'package:blood_donation/features/news/data/news_cache_repository.dart';
import 'package:blood_donation/features/services/news_service.dart';
import 'package:blood_donation/features/services/service_providers.dart';
import 'package:blood_donation/features/settings/data/app_settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class NewsFeedState {
  const NewsFeedState({
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.offlineShowingCache,
    required this.category,
    required this.hasMore,
    required this.nextPage,
    required this.lastUpdatedAt,
  });

  factory NewsFeedState.initial() {
    return const NewsFeedState(
      items: [],
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: null,
      offlineShowingCache: false,
      category: 'All',
      hasMore: true,
      nextPage: 1,
      lastUpdatedAt: null,
    );
  }

  final List<NewsItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool offlineShowingCache;
  final String category;
  final bool hasMore;
  final int nextPage;
  final DateTime? lastUpdatedAt;

  NewsFeedState copyWith({
    List<NewsItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? offlineShowingCache,
    String? category,
    bool? hasMore,
    int? nextPage,
    DateTime? lastUpdatedAt,
  }) {
    return NewsFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      offlineShowingCache: offlineShowingCache ?? this.offlineShowingCache,
      category: category ?? this.category,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

class NewsFeedController extends StateNotifier<NewsFeedState> {
  NewsFeedController({
    required this.service,
    required this.cache,
    required this.analyticsService,
    required this.connectivityRead,
    required this.localeRead,
    required this.settingsRead,
    required this.newsBox,
  }) : super(NewsFeedState.initial()) {
    _startAutoPolling();
    _startLiveStream();
    unawaited(loadInitial());
  }

  final NewsService service;
  final NewsCacheRepository cache;
  final AnalyticsService analyticsService;
  final bool Function() connectivityRead;
  final ({String lang, String region}) Function() localeRead;
  final AppSettingsState Function() settingsRead;
  final Box<dynamic> newsBox;

  Timer? _pollTimer;
  StreamSubscription<List<NewsItem>>? _liveSub;

  @override
  void dispose() {
    _pollTimer?.cancel();
    _liveSub?.cancel();
    super.dispose();
  }

  Future<void> setCategory(String category) async {
    if (state.category == category) {
      return;
    }
    state = state.copyWith(
      category: category,
      isLoading: true,
      items: const [],
      hasMore: true,
      nextPage: 1,
      clearError: true,
    );
    await loadInitial();
    await _restartLiveStream();
  }

  Future<void> loadInitial() async {
    final locale = localeRead();
    final cacheMaxAge = const Duration(minutes: AppEnv.newsRefreshMinutes);
    final cached = cache.load(
      category: state.category,
      lang: locale.lang,
      region: locale.region,
      maxAge: cacheMaxAge,
    );
    final withSaved = _applySaved(cached);
    if (withSaved.isNotEmpty) {
      state = state.copyWith(
        items: withSaved,
        isLoading: false,
        offlineShowingCache: !connectivityRead(),
        clearError: true,
      );
    }

    await _loadPage(page: 1, replace: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    await _loadPage(page: 1, replace: true);
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isRefreshing) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    await _loadPage(page: state.nextPage, replace: false);
    state = state.copyWith(isLoadingMore: false);
  }

  Future<void> toggleSaved(String id) async {
    final savedIds = _savedIds();
    if (savedIds.contains(id)) {
      savedIds.remove(id);
    } else {
      savedIds.add(id);
    }
    await newsBox.put('saved_article_ids', savedIds.toList());
    state = state.copyWith(
      items: _applySaved(state.items),
    );
  }

  Future<void> _loadPage({
    required int page,
    required bool replace,
  }) async {
    final locale = localeRead();
    final online = connectivityRead();
    if (!online && state.items.isNotEmpty) {
      state = state.copyWith(
        isLoading: false,
        offlineShowingCache: true,
      );
      return;
    }

    try {
      final requestedCategory = _resolveCategory(state.category);
      final result = await service.fetch(
        category: requestedCategory,
        page: page,
        pageSize: 10,
        lang: locale.lang,
        region: locale.region,
      );

      final nextItems = replace
          ? result.items
          : <NewsItem>[
              ...state.items,
              ...result.items,
            ];

      final withSaved = _applySaved(nextItems);
      state = state.copyWith(
        items: _dedupeById(withSaved),
        isLoading: false,
        hasMore: result.hasMore,
        nextPage: result.nextPage,
        errorMessage: null,
        offlineShowingCache: false,
        lastUpdatedAt: DateTime.now(),
      );
      await cache.save(
        category: state.category,
        lang: locale.lang,
        region: locale.region,
        items: state.items,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.items.isEmpty
            ? 'No articles yet. Pull to refresh.'
            : state.errorMessage,
        offlineShowingCache: state.items.isNotEmpty,
      );
    }
  }

  String _resolveCategory(String category) {
    if (settingsRead().showLocalNewsFirst && category == 'All') {
      return 'Local';
    }
    return category;
  }

  List<NewsItem> _dedupeById(List<NewsItem> items) {
    final map = <String, NewsItem>{};
    for (final item in items) {
      map[item.id] = item;
    }
    return map.values.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  Set<String> _savedIds() {
    final raw = newsBox.get('saved_article_ids');
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  List<NewsItem> _applySaved(List<NewsItem> items) {
    final saved = _savedIds();
    return items
        .map((item) => item.copyWith(isSaved: saved.contains(item.id)))
        .toList();
  }

  void _startAutoPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(minutes: AppEnv.newsRefreshMinutes),
      (_) => refresh(),
    );
  }

  void _startLiveStream() {
    if (AppEnv.newsStreamUrl.trim().isEmpty) {
      return;
    }
    _liveSub?.cancel();
    final locale = localeRead();
    _liveSub = service
        .live(
      category: state.category,
      lang: locale.lang,
      region: locale.region,
    )
        .listen((liveItems) async {
      if (liveItems.isEmpty) {
        return;
      }
      final merged = _dedupeById(_applySaved([
        ...liveItems,
        ...state.items,
      ]));
      state = state.copyWith(
        items: merged,
        lastUpdatedAt: DateTime.now(),
      );
      await cache.save(
        category: state.category,
        lang: locale.lang,
        region: locale.region,
        items: merged,
      );
    });
  }

  Future<void> _restartLiveStream() async {
    await _liveSub?.cancel();
    _startLiveStream();
  }
}

final newsCategoriesProvider = Provider<List<String>>((ref) {
  return const ['All', 'Prevention', 'Nutrition', 'Mental Health', 'Local'];
});

final newsFeedControllerProvider =
    StateNotifierProvider<NewsFeedController, NewsFeedState>((ref) {
  final cache = buildDefaultNewsCacheRepository();
  final newsBox = Hive.box<dynamic>('news_cache_box');
  return NewsFeedController(
    service: ref.watch(newsServiceProvider),
    cache: cache,
    analyticsService: ref.watch(analyticsServiceProvider),
    connectivityRead: () => ref.read(connectivityProvider).value ?? true,
    localeRead: () {
      final locale = ref.read(currentNewsLocaleProvider);
      return locale;
    },
    settingsRead: () => ref.read(appSettingsProvider),
    newsBox: newsBox,
  );
});

final currentNewsLocaleProvider = StateProvider<({String lang, String region})>(
  (ref) => (
    lang: AppEnv.defaultLang,
    region: AppEnv.defaultRegion,
  ),
);
