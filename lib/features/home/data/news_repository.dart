import 'package:blood_donation/features/home/data/firestore_news_repository.dart';
import 'package:blood_donation/features/home/domain/news_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NewsRepository {
  Future<List<NewsItem>> getLatestNews();
  Stream<List<NewsItem>> getNewsStream();
}

class MockNewsRepository implements NewsRepository {
  @override
  Future<List<NewsItem>> getLatestNews() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockNews;
  }

  @override
  Stream<List<NewsItem>> getNewsStream() async* {
    yield _mockNews;
    int count = 0;
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      count++;
      if (count % 2 == 0) {
        yield [
          ..._mockNews,
          NewsItem(
            id: 'new_$count',
            title: 'New Update $count',
            summary: 'Live update received via stream.',
            category: 'Live',
            sourceName: 'CareLink Live',
            publishedAt: DateTime.now(),
            isBreaking: true,
          )
        ];
      }
    }
  }

  final List<NewsItem> _mockNews = [
    NewsItem(
      id: '1',
      title: 'Urgent: O- Blood Needed',
      summary: 'City General Hospital is in critical need of O- blood donors.',
      category: 'Blood Drives',
      sourceName: 'City Hospital',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isBreaking: true,
    ),
    NewsItem(
      id: '2',
      title: 'Flu Season Precautions',
      summary: 'Health officials advise vaccination and hygiene measures.',
      category: 'Public Health',
      sourceName: 'Health Dept',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsItem(
      id: '3',
      title: 'New Donation Center Opens',
      summary: 'A new state-of-the-art center is now open downtown.',
      category: 'Local Alerts',
      sourceName: 'CareLink News',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return FirestoreNewsRepository();
});

final newsStreamProvider = StreamProvider<List<NewsItem>>((ref) {
  return ref.watch(newsRepositoryProvider).getNewsStream();
});
