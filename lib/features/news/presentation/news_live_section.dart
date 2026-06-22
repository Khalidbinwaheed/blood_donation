import 'package:blood_donation/core/services/analytics_service.dart';
import 'package:blood_donation/features/models/news_item.dart';
import 'package:blood_donation/features/news/presentation/news_feed_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsLiveSection extends ConsumerWidget {
  const NewsLiveSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newsFeedControllerProvider);
    final categories = ref.watch(newsCategoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Real-time Health News',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                if (state.offlineShowingCache)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Offline - showing saved news',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final selected = state.category == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        ref
                            .read(newsFeedControllerProvider.notifier)
                            .setCategory(category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if ((state.errorMessage ?? '').isNotEmpty &&
                state.items.isEmpty)
              _NewsEmptyState(
                onRefresh: () {
                  ref.read(newsFeedControllerProvider.notifier).refresh();
                },
              )
            else
              ListView.separated(
                key: const Key('news_list'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _NewsListTile(item: item);
                },
              ),
            if (state.isLoadingMore)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewsListTile extends ConsumerWidget {
  const _NewsListTile({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: item.title,
      child: InkWell(
        onTap: () async {
          await ref.read(analyticsServiceProvider).logEvent('news_opened');
          final url = item.url.trim();
          if (url.isNotEmpty) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _NewsImage(imageUrl: item.imageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Text(
                          item.source,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          _timeAgo(item.publishedAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Save',
                          onPressed: () async {
                            await ref
                                .read(newsFeedControllerProvider.notifier)
                                .toggleSaved(item.id);
                            await ref
                                .read(analyticsServiceProvider)
                                .logEvent('article_saved');
                          },
                          icon: Icon(
                            item.isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Share',
                          onPressed: () async {
                            await SharePlus.instance.share(
                              ShareParams(
                                text: '${item.title}\n${item.url}',
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: 110,
        height: 86,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.health_and_safety),
      );
    }
    return Image.network(
      imageUrl,
      width: 110,
      height: 86,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          width: 110,
          height: 86,
          color: Colors.grey.shade300,
          alignment: Alignment.center,
          child: const Icon(Icons.health_and_safety),
        );
      },
    );
  }
}

class _NewsEmptyState extends StatelessWidget {
  const _NewsEmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text('No articles yet'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: onRefresh,
                child: const Text('Refresh'),
              ),
              FilledButton.tonal(
                onPressed: onRefresh,
                child: const Text('Change filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 0) {
    return '${diff.inDays}d ago';
  }
  if (diff.inHours > 0) {
    return '${diff.inHours}h ago';
  }
  if (diff.inMinutes > 0) {
    return '${diff.inMinutes}m ago';
  }
  return 'Just now';
}
