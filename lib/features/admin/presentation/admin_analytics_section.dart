import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsSection extends ConsumerWidget {
  const AdminAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(_adminAnalyticsProvider);

    return analyticsAsync.when(
      data: (data) => ListView(
        children: [
          Text(
            'Analytics',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                title: 'Donors',
                value: '${data.donorCount}',
                subtitle: '${data.eligibleDonors} eligible',
                color: const Color(0xFF34C759),
              ),
              _MetricCard(
                title: 'Open Requests',
                value: '${data.openRequests}',
                subtitle: '${data.fulfilledRequests} fulfilled',
                color: const Color(0xFFFF3B30),
              ),
              _MetricCard(
                title: 'Appointments',
                value: '${data.appointments}',
                subtitle: '${data.completedAppointments} completed',
                color: const Color(0xFF0A84FF),
              ),
              _MetricCard(
                title: 'Ambulance',
                value: '${data.activeAmbulanceRequests}',
                subtitle: '${data.totalAmbulanceRequests} total',
                color: const Color(0xFFFF9500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Blood group distribution',
            child: Column(
              children: data.bloodGroupCounts.entries.map((entry) {
                final max = data.bloodGroupCounts.values.fold<int>(
                  0,
                  (prev, value) => value > prev ? value : prev,
                );
                final ratio = max == 0 ? 0.0 : entry.value / max;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.value}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Requests by urgency',
            child: Column(
              children: data.urgencyCounts.entries.map((entry) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                  trailing: Text(
                    '${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Donations (last 7 days)',
            child: SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.donationsByDay.entries.map((entry) {
                  final max = data.donationsByDay.values.fold<int>(
                    0,
                    (prev, value) => value > prev ? value : prev,
                  );
                  final height = max == 0 ? 8.0 : (entry.value / max) * 120 + 8;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('E').format(entry.key),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Analytics error: $error')),
    );
  }
}

class _AdminAnalyticsSnapshot {
  const _AdminAnalyticsSnapshot({
    required this.donorCount,
    required this.eligibleDonors,
    required this.openRequests,
    required this.fulfilledRequests,
    required this.appointments,
    required this.completedAppointments,
    required this.activeAmbulanceRequests,
    required this.totalAmbulanceRequests,
    required this.bloodGroupCounts,
    required this.urgencyCounts,
    required this.donationsByDay,
  });

  final int donorCount;
  final int eligibleDonors;
  final int openRequests;
  final int fulfilledRequests;
  final int appointments;
  final int completedAppointments;
  final int activeAmbulanceRequests;
  final int totalAmbulanceRequests;
  final Map<String, int> bloodGroupCounts;
  final Map<String, int> urgencyCounts;
  final Map<DateTime, int> donationsByDay;
}

final _adminAnalyticsProvider =
    StreamProvider<_AdminAnalyticsSnapshot>((ref) async* {
  final firestore = FirebaseFirestore.instance;

  Future<_AdminAnalyticsSnapshot> load() async {
    final users = await firestore.collection('users').get();
    final requests = await firestore.collection('requests').get();
    final appointments = await firestore.collection('appointments').get();
    final ambulance = await firestore.collection('ambulance_requests').get();
    final donations = await firestore.collection('donations').get();

    var donorCount = 0;
    var eligibleDonors = 0;
    final bloodGroupCounts = <String, int>{};

    for (final doc in users.docs) {
      final data = doc.data();
      final role = (data['role'] ?? data['type'] ?? '').toString().toLowerCase();
      if (role.contains('donor')) {
        donorCount++;
        if ((data['donorEligibilityStatus'] ?? '').toString() == 'eligible') {
          eligibleDonors++;
        }
      }
      final group = (data['bloodGroup'] ?? '').toString().trim().toUpperCase();
      if (group.isNotEmpty) {
        bloodGroupCounts[group] = (bloodGroupCounts[group] ?? 0) + 1;
      }
    }

    var openRequests = 0;
    var fulfilledRequests = 0;
    final urgencyCounts = <String, int>{};
    for (final doc in requests.docs) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      if (status == 'open') {
        openRequests++;
      } else if (status == 'fulfilled' || status == 'closed') {
        fulfilledRequests++;
      }
      final urgency =
          (doc.data()['severity'] ?? 'Unknown').toString().trim();
      urgencyCounts[urgency] = (urgencyCounts[urgency] ?? 0) + 1;
    }

    var completedAppointments = 0;
    for (final doc in appointments.docs) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      if (status == 'completed') {
        completedAppointments++;
      }
    }

    var activeAmbulance = 0;
    for (final doc in ambulance.docs) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      if (status != 'completed' && status != 'cancelled') {
        activeAmbulance++;
      }
    }

    final donationsByDay = <DateTime, int>{};
    final today = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      donationsByDay[day] = 0;
    }
    for (final doc in donations.docs) {
      final raw = doc.data()['donationDate'];
      DateTime? date;
      if (raw is Timestamp) {
        date = raw.toDate();
      } else if (raw is DateTime) {
        date = raw;
      }
      if (date == null) {
        continue;
      }
      final key = DateTime(date.year, date.month, date.day);
      if (donationsByDay.containsKey(key)) {
        donationsByDay[key] = (donationsByDay[key] ?? 0) + 1;
      }
    }

    return _AdminAnalyticsSnapshot(
      donorCount: donorCount,
      eligibleDonors: eligibleDonors,
      openRequests: openRequests,
      fulfilledRequests: fulfilledRequests,
      appointments: appointments.docs.length,
      completedAppointments: completedAppointments,
      activeAmbulanceRequests: activeAmbulance,
      totalAmbulanceRequests: ambulance.docs.length,
      bloodGroupCounts: bloodGroupCounts,
      urgencyCounts: urgencyCounts,
      donationsByDay: donationsByDay,
    );
  }

  yield await load();
  yield* Stream.periodic(const Duration(seconds: 20)).asyncMap((_) => load());
});

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
