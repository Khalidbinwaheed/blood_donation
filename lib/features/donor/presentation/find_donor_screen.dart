import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/authentication/presentation/widgets/blood_group_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FindDonorScreen extends StatefulWidget {
  const FindDonorScreen({super.key});

  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  String _selectedGroup = 'O+';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Donors'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Search registered donors by blood group. Results update in real time.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          BloodGroupSelector(
            selectedGroup: _selectedGroup,
            onSelected: (group) => setState(() => _selectedGroup = group),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              context.pushNamed(
                AppRoutes.bloodGroupSelected.name,
                pathParameters: {'group': _selectedGroup},
              );
            },
            icon: const Icon(Icons.search),
            label: Text('Find $_selectedGroup donors'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Call donors directly from their profile\n'
                    '• Use Chat Now for secure in-app messaging\n'
                    '• Post a blood request to notify matching donors',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
