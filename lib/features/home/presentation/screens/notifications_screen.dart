import 'package:blood_donation/features/home/data/notifications_repository.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:blood_donation/util/appstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppStyle.headingTextStyle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      _getIconColor(notification.type).withValues(alpha: 0.1),
                  child: Icon(_getIcon(notification.type),
                      color: _getIconColor(notification.type)),
                ),
                title: Text(
                  notification.title,
                  style: AppStyle.normalTextStyle.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notification.body,
                  style: AppStyle.normalTextStyle
                      .copyWith(fontSize: 14, color: Colors.grey[600]),
                ),
                trailing: Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                onTap: () {
                  // Mark as read
                  final user = ref.read(currentUserProvider).value;
                  if (user != null) {
                    ref
                        .read(notificationsRepositoryProvider)
                        .markAsRead(user.uid, notification.id);
                  }

                  // basic navigation logic
                  if (notification.type == 'blood_request') {
                    // Navigate to blood request details or similar
                    // For now, maybe just show a snackbar or go to home
                    // context.pushNamed(AppRoutes.bloodRequestDetails.name, extra: notification.relatedId);
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
        return AppStyle.mainColor;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'blood_request':
        return Icons.water_drop;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'info':
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
