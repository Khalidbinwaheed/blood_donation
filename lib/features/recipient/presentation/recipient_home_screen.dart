import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
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
      appBar: AppBar(title: const Text('Recipient Hub')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('requestBlood'),
        label: const Text('Request Blood'),
        icon: const Icon(Icons.add_circle),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please log in'));
          return Column(
            children: [
              _buildStatusHeader(context),
              Expanded(child: _buildRequestList(ref, user.uid)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Requests',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Track status of your blood requirements',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Document Upload Simulated (PDF/Image)')),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Docs'),
          ),
        ],
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
                Icon(Icons.bloodtype_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active requests'),
                Text('Tap "Request Blood" to start'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final date = (req['createdAt'] as dynamic)?.toDate();
            final status = req['status'] ?? 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('${req['bloodGroup']} for ${req['hospitalName']}'),
                subtitle: Text(
                  'Urgency: ${req['urgency']}\nDate: ${date != null ? DateFormat.yMMMd().format(date) : "N/A"}',
                ),
                isThreeLine: true,
                trailing: Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(status),
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
