import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RequestBloodScreen extends ConsumerStatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  ConsumerState<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends ConsumerState<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _bloodGroup = 'A+';
  final _hospitalController = TextEditingController();
  String _urgency = 'High';
  final _noteController = TextEditingController();
  bool _isLoading = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _urgencyLevels = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void dispose() {
    _hospitalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not logged in');

      await ref.read(donationRepositoryProvider).createDonationRequest(
            requesterUid: user.uid,
            bloodGroup: _bloodGroup,
            hospitalName: _hospitalController.text,
            urgency: _urgency,
            note: _noteController.text,
            contactEmail: user.email,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _bloodGroup,
              decoration:
                  const InputDecoration(labelText: 'Blood Group Needed'),
              items: _bloodGroups
                  .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                  .toList(),
              onChanged: (val) => setState(() => _bloodGroup = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hospitalController,
              decoration: const InputDecoration(labelText: 'Hospital Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _urgency,
              decoration: const InputDecoration(labelText: 'Urgency Level'),
              items: _urgencyLevels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (val) => setState(() => _urgency = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Unit number, patient condition, etc.',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submitRequest,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
