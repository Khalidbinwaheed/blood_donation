import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends ConsumerWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency Contacts')),
        body:
            const Center(child: Text('Sign in to manage emergency contacts.')),
      );
    }

    final contactsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('contacts');
    final contactsQuery =
        contactsCollection.orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            onPressed: () => _openContactForm(context, contactsCollection),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: contactsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return Center(
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.contact_phone_outlined, size: 40),
                    const SizedBox(height: 10),
                    Text('No contacts yet',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    const Text(
                        'Add family or hospital contacts for emergency use.'),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () =>
                          _openContactForm(context, contactsCollection),
                      icon: const Icon(Icons.add),
                      label: const Text('Add contact'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final name = (data['name'] ?? 'Unknown').toString();
              final phone = (data['phone'] ?? '').toString();
              final relation =
                  (data['relation'] ?? 'Trusted contact').toString();

              return GlassCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(name.isEmpty ? 'U' : name[0].toUpperCase()),
                  ),
                  title: Text(name),
                  subtitle: Text('$relation\n$phone'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _openContactForm(context, contactsCollection,
                            docId: doc.id, current: data);
                      } else if (value == 'call') {
                        await _call(phone);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'call', child: Text('Call')),
                    ],
                  ),
                  onTap: () => _call(phone),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openContactForm(context, contactsCollection),
        icon: const Icon(Icons.add),
        label: const Text('Add contact'),
      ),
    );
  }

  Future<void> _openContactForm(
    BuildContext context,
    CollectionReference<Map<String, dynamic>> contactsRef, {
    String? docId,
    Map<String, dynamic>? current,
  }) async {
    final nameController =
        TextEditingController(text: current?['name']?.toString() ?? '');
    final phoneController =
        TextEditingController(text: current?['phone']?.toString() ?? '');
    final relationController =
        TextEditingController(text: current?['relation']?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Add contact' : 'Edit contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone),
              TextField(
                  controller: relationController,
                  decoration: const InputDecoration(labelText: 'Relation')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (saved != true) {
      return;
    }

    final payload = <String, dynamic>{
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'relation': relationController.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (docId == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      await contactsRef.add(payload);
    } else {
      await contactsRef.doc(docId).set(payload, SetOptions(merge: true));
    }
  }

  Future<void> _call(String phone) async {
    final sanitized = phone.trim();
    if (sanitized.isEmpty) return;
    final uri = Uri.parse('tel:$sanitized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
