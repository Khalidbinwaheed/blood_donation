import 'package:blood_donation/features/home/data/news_repository.dart';
import 'package:blood_donation/features/home/domain/news_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreNewsRepository implements NewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<NewsItem>> getLatestNews() async {
    try {
      final snapshot = await _firestore
          .collection('news')
          .orderBy('publishedAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    } catch (e) {
      // Return empty list or throw, depending on error handling strategy
      // For now, returning empty to avoid crashing UI on initial setup
      return [];
    }
  }

  @override
  Stream<List<NewsItem>> getNewsStream() {
    return _firestore
        .collection('news')
        .orderBy('publishedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    });
  }

  NewsItem _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NewsItem(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        summary: data['summary'] ?? '',
        category: data['category'] ?? 'General',
        sourceName: data['sourceName'] ?? 'CareLink',
        publishedAt:
            (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isBreaking: data['isBreaking'] ?? false,
        imageUrl: data['imageUrl'] // Optional field
        );
  }
}
