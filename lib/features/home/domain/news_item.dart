import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

@freezed
abstract class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String id,
    required String title,
    required String summary,
    required String category, // Public Health, Blood Drives, Local Alerts
    required String sourceName,
    String? url,
    required DateTime publishedAt,
    @Default(false) bool isBreaking,
    String? imageUrl,
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json);
}
