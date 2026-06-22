import 'package:blood_donation/features/home/data/notifications_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _EmptyNotifications(
              signedIn: user != null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsStreamProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: _getIconColor(notification.type)
                          .withValues(alpha: 0.14),
                      child: Icon(
                        _getIcon(notification.type),
                        color: _getIconColor(notification.type),
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    trailing: Text(
                      _formatTimestamp(notification.timestamp),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    onTap: () {
                      if (user != null) {
                        ref
                            .read(notificationsRepositoryProvider)
                            .markAsRead(user.uid, notification.id);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.exclamationmark_triangle, size: 36),
                const SizedBox(height: 8),
                Text(
                  'Could not load notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(notificationsStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'blood_request':
        return Colors.red;
      case 'alert':
        return Colors.orange;
      case 'info':
      default:
        return const Color(0xFF0A84FF);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'blood_request':
        return CupertinoIcons.drop_fill;
      case 'alert':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'info':
      default:
        return CupertinoIcons.bell_fill;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({
    required this.signedIn,
  });

  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.bell_slash,
                  size: 44,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  signedIn ? 'No notifications yet' : 'Sign in to get alerts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  signedIn
                      ? 'New emergency updates and request activity will appear here in real time.'
                      : 'Notifications for blood requests and emergency actions appear after sign in.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
