import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStats {
  final String donors;
  final String posts;
  final String appointments;

  const HomeStats({
    this.donors = '0',
    this.posts = '0',
    this.appointments = '0',
  });

  factory HomeStats.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists) return const HomeStats();
    final data = doc.data() as Map<String, dynamic>;
    return HomeStats(
      donors: data['donors']?.toString() ?? '0',
      posts: data['posts']?.toString() ?? '0',
      appointments: data['appointments']?.toString() ?? '0',
    );
  }
}

final homeStatsProvider = StreamProvider<HomeStats>((ref) {
  return FirebaseFirestore.instance
      .collection('stats')
      .doc('global')
      .snapshots()
      .map((doc) => HomeStats.fromFirestore(doc));
});
