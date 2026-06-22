import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view records.')),
      );
    }

    final profileAsync = ref.watch(userProfileStreamProvider(user.uid));
    final requestsStream =
        ref.watch(donationRepositoryProvider).getUserRequests(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Records'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            data: (profile) {
              final data = profile ?? user;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Summary',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Name: ${(data.firstName ?? '').trim()} ${(data.lastName ?? '').trim()}'),
                      Text('Blood Group: ${data.bloodGroup}'),
                      Text('Phone: ${data.phoneNumber}'),
                      Text('Eligibility: ${data.donorEligibilityStatus}'),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(height: 40, child: LinearProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text('Could not load profile records: $error'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: requestsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child:
                        SizedBox(height: 40, child: LinearProgressIndicator()),
                  ),
                );
              }
              final requests = snapshot.data ?? const [];
              if (requests.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('No blood request records yet.'),
                  ),
                );
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Requests',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      ...requests.take(5).map((item) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title:
                              Text((item['bloodGroupNeeded'] ?? '').toString()),
                          subtitle:
                              Text((item['hospitalName'] ?? '').toString()),
                          trailing: Text((item['status'] ?? '').toString()),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
