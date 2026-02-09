import 'package:blood_donation/features/home/data/news_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsTicker extends ConsumerWidget {
  const NewsTicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsStreamProvider);

    return Container(
      color:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
      height: 48,
      child: newsAsync.when(
        data: (news) {
          if (news.isEmpty) return const SizedBox.shrink();
          return PageView.builder(
            scrollDirection: Axis.vertical,
            controller: PageController(viewportFraction: 1.0),
            physics:
                const NeverScrollableScrollPhysics(), // Auto-scroll handled by Timer in a real ticker
            itemBuilder: (context, index) {
              final item = news[index % news.length];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.isBreaking)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child:
                              Icon(Icons.campaign, size: 20, color: Colors.red),
                        ),
                      Flexible(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (_, __) => const SizedBox.shrink(),
        loading: () => const Center(
            child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))),
      ),
    );
  }
}
