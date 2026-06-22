class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
    required this.category,
    required this.isSaved,
  });

  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;
  final String url;
  final String category;
  final bool isSaved;

  NewsItem copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    String? source,
    DateTime? publishedAt,
    String? url,
    String? category,
    bool? isSaved,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      url: url ?? this.url,
      category: category ?? this.category,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageUrl': imageUrl,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'url': url,
      'category': category,
      'isSaved': isSaved,
    };
  }

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? '').toString().trim();
    final summary =
        (json['summary'] ?? json['description'] ?? json['content'] ?? '')
            .toString()
            .trim();
    final imageUrl =
        (json['imageUrl'] ?? json['image'] ?? json['urlToImage'] ?? '')
            .toString()
            .trim();
    final source =
        (json['source'] ?? (json['sourceName']) ?? (json['provider']) ?? '')
            .toString()
            .trim();
    final url = (json['url'] ?? json['link'] ?? '').toString().trim();
    final publishedRaw = json['publishedAt'] ?? json['published_at'];
    final parsedDate = _parseDateTime(publishedRaw) ?? DateTime.now();

    return NewsItem(
      id: (json['id'] ?? json['articleId'] ?? url.hashCode.toString())
          .toString(),
      title: title.isEmpty ? 'Health update' : title,
      summary: summary,
      imageUrl: imageUrl,
      source: source.isEmpty ? 'Unknown source' : source,
      publishedAt: parsedDate,
      url: url,
      category: (json['category'] ?? json['topic'] ?? 'All').toString(),
      isSaved: json['isSaved'] == true,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString());
  }
}
