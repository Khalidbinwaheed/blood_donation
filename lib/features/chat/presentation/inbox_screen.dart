import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/chat/data/messaging_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        actions: [
          IconButton(
            tooltip: 'Health chat',
            onPressed: () => context.goNamed(AppRoutes.chat.name),
            icon: const Icon(Icons.smart_toy_outlined),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Sign in to view conversations.'))
          : StreamBuilder<List<ConversationSummary>>(
              stream:
                  ref.watch(messagingRepositoryProvider).watchConversations(
                        user.uid,
                      ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.exclamationmark_triangle),
                        const SizedBox(height: 8),
                        Text('Could not load conversations: ${snapshot.error}'),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () => ref.invalidate(
                            messagingRepositoryProvider,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final conversations = snapshot.data ?? const [];
                if (conversations.isEmpty) {
                  return Center(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.chat_bubble_2),
                            const SizedBox(height: 8),
                            const Text('No conversations yet'),
                            const SizedBox(height: 8),
                            const Text(
                              'Open a donor profile and tap Chat Now to start messaging.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonal(
                              onPressed: () => context.pushNamed(
                                AppRoutes.bloodFindDonor.name,
                              ),
                              child: const Text('Find donors'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            conversation.peerName.isEmpty
                                ? '?'
                                : conversation.peerName[0].toUpperCase(),
                          ),
                        ),
                        title: Text(conversation.peerName),
                        subtitle: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: conversation.unreadCount > 0
                            ? CircleAvatar(
                                radius: 11,
                                child: Text(
                                  '${conversation.unreadCount}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                            : Text(
                                _formatTime(conversation.updatedAt),
                                style: const TextStyle(fontSize: 11),
                              ),
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.conversation.name,
                            pathParameters: {
                              'peerId': conversation.peerId,
                            },
                            queryParameters: {
                              'name': conversation.peerName,
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }
}
