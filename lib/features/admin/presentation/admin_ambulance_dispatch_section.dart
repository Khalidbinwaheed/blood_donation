import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAmbulanceDispatchSection extends ConsumerWidget {
  const AdminAmbulanceDispatchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = FirebaseFirestore.instance
        .collection('ambulance_requests')
        .orderBy('updatedAt', descending: true)
        .limit(25)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No ambulance requests.'));
        }

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final status = (data['status'] ?? 'requested').toString();
            final hospital = (data['hospitalName'] ?? 'Hospital').toString();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text('Request: ${doc.id}'),
                    Text('Status: $status'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => _updateStatus(doc.reference, 'dispatched'),
                          child: const Text('Dispatch'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _updateStatus(doc.reference, 'en_route'),
                          child: const Text('En route'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => _updateStatus(doc.reference, 'arrived'),
                          child: const Text('Arrived'),
                        ),
                        OutlinedButton(
                          onPressed: () => _updateStatus(doc.reference, 'completed'),
                          child: const Text('Complete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String status,
  ) async {
    final snapshot = await ref.get();
    final data = snapshot.data() ?? {};
    final patientLoc = data['location'] as Map<String, dynamic>?;
    final update = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'dispatched' || status == 'en_route') {
      final baseLat = (patientLoc?['lat'] as num?)?.toDouble() ?? 34.0123;
      final baseLng = (patientLoc?['lng'] as num?)?.toDouble() ?? 71.5678;
      final offset = status == 'dispatched' ? 0.008 : 0.003;
      update['driverLocation'] = {
        'lat': baseLat + offset,
        'lng': baseLng + offset,
      };
    }

    if (status == 'arrived' && patientLoc != null) {
      update['driverLocation'] = patientLoc;
    }

    await ref.update(update);
  }
}
