import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/features/news/presentation/news_live_section.dart';
import 'package:flutter/material.dart';

class CommunityArticlesScreen extends StatelessWidget {
  const CommunityArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Articles')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health awareness and blood safety',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text(
                    'Education content is updated in real time and cached for offline reading.'),
              ],
            ),
          ),
          SizedBox(height: 12),
          NewsLiveSection(),
        ],
      ),
    );
  }
}
