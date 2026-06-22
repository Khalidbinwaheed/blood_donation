import 'package:blood_donation/features/models/news_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NewsItem.fromJson maps expected fields', () {
    final json = {
      'id': 'n_101',
      'title': 'Simple habits that improve heart health',
      'summary': 'Doctors recommend 30 minutes of moderate activity daily...',
      'imageUrl': 'https://example.com/img.jpg',
      'source': 'HealthLine',
      'publishedAt': '2026-02-16T15:32:00Z',
      'url': 'https://example.com/article',
      'category': 'Prevention',
      'isSaved': false,
    };

    final item = NewsItem.fromJson(json);

    expect(item.id, 'n_101');
    expect(item.title, contains('heart health'));
    expect(item.source, 'HealthLine');
    expect(item.category, 'Prevention');
    expect(item.isSaved, isFalse);
    expect(item.publishedAt.toUtc().year, 2026);
  });
}
