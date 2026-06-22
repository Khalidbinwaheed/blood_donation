import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityEventsScreen extends StatelessWidget {
  const CommunityEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('events')
        .orderBy('startsAt', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Donation Events')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? const [];
          final items = docs.isEmpty
              ? _seededEvents()
              : docs.map((doc) => _EventCardData.fromMap(doc.data())).toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return GlassCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: Text('${item.dateLabel}\n${item.location}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<_EventCardData> _seededEvents() {
    return const [
      _EventCardData(
          title: 'Campus Blood Drive',
          dateLabel: '12 Apr 2026',
          location: 'Lifeline Community Hall'),
      _EventCardData(
          title: 'First Aid Workshop',
          dateLabel: '19 Apr 2026',
          location: 'City General Hospital'),
      _EventCardData(
          title: 'Heart Health Walk',
          dateLabel: '26 Apr 2026',
          location: 'River Park'),
    ];
  }
}

class _EventCardData {
  const _EventCardData(
      {required this.title, required this.dateLabel, required this.location});

  final String title;
  final String dateLabel;
  final String location;

  factory _EventCardData.fromMap(Map<String, dynamic> map) {
    return _EventCardData(
      title: (map['title'] ?? 'Community event').toString(),
      dateLabel: (map['dateLabel'] ?? map['startsAt'] ?? 'Upcoming').toString(),
      location: (map['location'] ?? map['venue'] ?? 'TBA').toString(),
    );
  }
}
