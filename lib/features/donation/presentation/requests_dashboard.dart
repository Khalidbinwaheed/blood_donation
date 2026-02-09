import 'package:blood_donation/features/donation/domain/blood_request.dart';
import 'package:blood_donation/features/donation/presentation/widgets/request_card.dart';
import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage the filter state (false = show matching only, true = show all)
final showAllRequestsProvider = StateProvider<bool>((ref) => false);

class RequestsDashboard extends ConsumerWidget {
  const RequestsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAll = ref.watch(showAllRequestsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Urgent Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text('View All'),
                  Switch(
                    value: showAll,
                    onChanged: (value) {
                      ref.read(showAllRequestsProvider.notifier).state = value;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: ref.watch(donationRepositoryProvider).getOpenRequests(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final requestMaps = snapshot.data ?? [];

              if (requestMaps.isEmpty) {
                return const Center(
                    child: Text('No open requests at the moment.'));
              }

              // Manual filtering on the client side based on user's blood group
              // Ideally, this could be a separate filtered stream from Firestore
              return userAsync.when(
                data: (user) {
                  final filteredRequests = requestMaps.where((data) {
                    if (showAll) return true;
                    // Auto-filter: Show requests matching user's blood group
                    if (user != null && user.bloodGroup.isNotEmpty) {
                      return data['bloodGroupNeeded'] == user.bloodGroup;
                    }
                    return true; // Fallback if user data incomplete
                  }).toList();

                  if (filteredRequests.isEmpty) {
                    return const Center(
                        child: Text(
                            'No requests matching your blood group.\nToggle "View All" to see others.'));
                  }

                  return ListView.builder(
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final data = filteredRequests[index];
                      // Convert Timestamp to DateTime
                      final deadline =
                          (data['deadline'] as Timestamp?)?.toDate() ??
                              DateTime.now();

                      final request = BloodRequest(
                        id: data['id'] ?? '',
                        requesterId: data['requesterId'] ?? '',
                        bloodGroupNeeded: data['bloodGroupNeeded'] ?? 'Unknown',
                        severity: data['severity'] ?? 'High',
                        deadline: deadline,
                        contactEmail: data['contactEmail'] ?? '',
                        status: data['status'] ?? 'Open',
                        hospitalName:
                            data['hospitalName'] ?? 'Unknown Hospital',
                        note: data['note'] ?? '',
                        createdAt:
                            (data['createdAt'] as Timestamp?)?.toDate() ??
                                DateTime.now(),
                      );

                      return RequestCard(request: request);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('User Error: $e')),
              );
            },
          ),
        ),
      ],
    );
  }
}
