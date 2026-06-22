import 'dart:convert';

import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DigitalIdScreen extends ConsumerWidget {
  const DigitalIdScreen({super.key});

  String _qrPayload({
    required String uid,
    required String name,
    required String bloodGroup,
  }) {
    return jsonEncode({
      'app': 'lifeline',
      'uid': uid,
      'name': name,
      'bloodGroup': bloodGroup,
      'version': 1,
    });
  }

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

          final fullName = '${user.firstName} ${user.lastName}'.trim();
          final payload = _qrPayload(
            uid: user.uid,
            name: fullName,
            bloodGroup: user.bloodGroup,
          );

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fullName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Blood Group: ${user.bloodGroup}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                            child: QrImageView(
                              data: payload,
                              version: QrVersions.auto,
                              size: 196,
                              backgroundColor: Colors.white,
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
                ],
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
