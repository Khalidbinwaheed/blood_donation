import 'package:blood_donation/features/donor/data/donor_repository.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DonorHomeScreen extends ConsumerStatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  ConsumerState<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends ConsumerState<DonorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Donor Hub')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please log in'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildActionCard(
                  context,
                  title: 'Check Eligibility',
                  subtitle: 'Update your health status',
                  icon: Icons.health_and_safety,
                  color: Colors.blue,
                  onTap: () => _showEligibilityDialog(context, user.uid),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: 'Register Availability',
                  subtitle: 'Let centers know when you can donate',
                  icon: Icons.calendar_today,
                  color: Colors.green,
                  onTap: () => _showAvailabilityDialog(context, user.uid),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: 'Find Centers',
                  subtitle: 'Locate nearby donation camps',
                  icon: Icons.map,
                  color: Colors.red,
                  onTap: () => context.pushNamed('map'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Donation History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _buildDonationHistory(ref, user.uid),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDonationHistory(WidgetRef ref, String uid) {
    final historyStream =
        ref.watch(donorRepositoryProvider).getDonationHistory(uid);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: historyStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Could not load history');
        }
        final history = snapshot.data ?? [];
        if (history.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No past donations found.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return Column(
          children: history.map((data) {
            final date = (data['donationDate'] as dynamic)?.toDate();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(
                    'Donation at ${data['centerName'] ?? 'Unknown Center'}'),
                subtitle: Text(date != null
                    ? DateFormat.yMMMd().format(date)
                    : 'Unknown Date'),
                trailing: Text(data['bloodGroup'] ?? ''),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showEligibilityDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Eligibility'),
        content: const Text(
            'Confirm that you meet the criteria:\n\n• Weight > 50kg\n• No recent surgeries\n• No tattoo in last 6 months'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(donorRepositoryProvider).updateEligibility(uid, {
                'donorEligibilityStatus': 'eligible',
                'lastEligibilityCheck': DateTime.now(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status updated to Eligible')));
            },
            child: const Text('I Qualify'),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext context, String uid) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (date != null && context.mounted) {
      // Just storing whole day for simplicity, or add TimePicker
      await ref
          .read(donorRepositoryProvider)
          .setAvailability(uid, date, date.add(const Duration(hours: 8)));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Availability Registered')));
      }
    }
  }
}
