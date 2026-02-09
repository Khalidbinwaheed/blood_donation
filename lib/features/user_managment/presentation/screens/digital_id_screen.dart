import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:qr_flutter/qr_flutter.dart'; // Add if allowed

class DigitalIdScreen extends ConsumerWidget {
  const DigitalIdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Digital ID')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please log in to view ID'));
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Blood Group: ${user.bloodGroup}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      // Mock QR Code Area
                      Container(
                        width: 200,
                        height: 200,
                        color: Colors.white,
                        child: const Center(
                          child: Icon(Icons.qr_code_2,
                              size: 150, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ID: ${user.uid}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          // Copy UID
                          Clipboard.setData(ClipboardData(text: user.uid));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('ID copied to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy ID'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
