import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecipientHomeScreen extends ConsumerWidget {
  const RecipientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipient Hub'),
        actions: [
          IconButton(
            tooltip: 'Live Requests',
            onPressed: () => context.pushNamed(AppRoutes.requestFeed.name),
            icon: const Icon(CupertinoIcons.list_bullet_below_rectangle),
          ),
          IconButton(
            tooltip: 'Inbox',
            onPressed: () => context.pushNamed(AppRoutes.inbox.name),
            icon: const Icon(CupertinoIcons.chat_bubble_2_fill),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.requestBlood.name),
        label: const Text('Request Blood'),
        icon: const Icon(CupertinoIcons.plus_circle_fill),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in'));
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                children: [
                  _buildStatusHeader(context),
                  Expanded(child: _buildRequestList(ref, user.uid)),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Requests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                        'Track status of your blood requirements in real time.'),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Document upload hook is ready for integration.'),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.cloud_upload),
                label: const Text('Upload Docs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestList(WidgetRef ref, String uid) {
    final requestsStream =
        ref.watch(donationRepositoryProvider).getUserRequests(uid);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: requestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.drop_triangle,
                    size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active requests'),
                Text('Tap "Request Blood" to start'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final date = (req['createdAt'] as dynamic)?.toDate();
            final status = req['status'] ?? 'pending';
            final bloodGroup =
                (req['bloodGroup'] ?? req['bloodGroupNeeded'] ?? '').toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text('$bloodGroup for ${req['hospitalName']}'),
                  subtitle: Text(
                    'Urgency: ${req['urgency']}\nDate: ${date != null ? DateFormat.yMMMd().format(date) : "N/A"}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(
                    label: Text(
                      status.toString().toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    backgroundColor: _getStatusColor(status.toString()),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
        return Colors.green.shade100;
      case 'urgent':
        return Colors.red.shade100;
      default:
        return Colors.orange.shade100;
    }
  }
}
