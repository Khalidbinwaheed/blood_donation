import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 96,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          CupertinoIcons.heart_fill,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Health Helper',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Our mission is to bridge the gap between donors and recipients with reliable, real-time tools for urgent blood requests.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _FeatureTile(
                icon: CupertinoIcons.search_circle_fill,
                title: 'Find Donors',
                subtitle: 'Filter and locate suitable donors quickly.',
              ),
              const SizedBox(height: 8),
              const _FeatureTile(
                icon: CupertinoIcons.chat_bubble_2_fill,
                title: 'Connect Instantly',
                subtitle: 'Reach users with in-app messaging and alerts.',
              ),
              const SizedBox(height: 8),
              const _FeatureTile(
                icon: CupertinoIcons.heart_circle_fill,
                title: 'Save Lives',
                subtitle: 'Respond to urgent requests with safer workflows.',
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  '© 2026 Code Craft It Solution',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
