import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:blood_donation/features/user_management/data/firestore_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DonorsEmailedScreen extends ConsumerWidget {
  const DonorsEmailedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view emailed donors.')),
      );
    }

    final repository = ref.watch(firestoreRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donors Emailed'),
      ),
      body: StreamBuilder<List<String>>(
        stream: repository.loadEmailedUsersIds(user.uid),
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
                  Text('Could not load emailed donors: ${snapshot.error}'),
                ],
              ),
            );
          }

          final ids = (snapshot.data ?? const [])
              .where((id) => id.trim().isNotEmpty)
              .toSet()
              .toList();

          if (ids.isEmpty) {
            return const Center(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 18),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No emailed donors yet.'),
                ),
              ),
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                itemCount: ids.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final id = ids[index];
                  final donorAsync = ref.watch(loadUserInformationProvider(id));
                  return donorAsync.when(
                    data: (donor) {
                      final title = donor == null
                          ? 'User ID: $id'
                          : '${donor.firstName ?? ''} ${donor.lastName ?? ''}'
                              .trim()
                              .ifEmpty('Unnamed Donor');
                      final subtitle = donor == null
                          ? 'Profile unavailable'
                          : '${donor.bloodGroup.ifEmpty('N/A')} - ${donor.email.ifEmpty('No email')}';
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(title.characters.first.toUpperCase()),
                          ),
                          title: Text(title),
                          subtitle: Text(subtitle),
                          trailing: const Icon(Icons.check_circle,
                              color: Colors.green),
                        ),
                      );
                    },
                    loading: () => const Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading:
                            CircleAvatar(child: Icon(Icons.hourglass_empty)),
                        title: Text('Loading donor...'),
                      ),
                    ),
                    error: (_, __) => Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.error_outline)),
                        title: Text('User ID: $id'),
                        subtitle: const Text('Could not load profile'),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
