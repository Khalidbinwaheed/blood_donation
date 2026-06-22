import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/core/widgets/gradient_button.dart';
import 'package:blood_donation/features/map/presentation/nearby_places_provider.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class AmbulanceRequestScreen extends ConsumerStatefulWidget {
  const AmbulanceRequestScreen({super.key});

  @override
  ConsumerState<AmbulanceRequestScreen> createState() =>
      _AmbulanceRequestScreenState();
}

class _AmbulanceRequestScreenState
    extends ConsumerState<AmbulanceRequestScreen> {
  final _notesController = TextEditingController();
  String? _selectedHospital;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final placesAsync = ref.watch(nearbyPlacesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ambulance Request')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request a nearby ambulance',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(
                    'Share your location and select a hospital to reduce response time.'),
                const SizedBox(height: 14),
                placesAsync.when(
                  data: (places) {
                    final hospitalNames = places.isEmpty
                        ? ['Lifeline Medical Center', 'City General Hospital']
                        : places.map((p) => p.name).toList();
                    _selectedHospital ??= hospitalNames.first;
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedHospital,
                      decoration: const InputDecoration(
                          labelText: 'Preferred hospital'),
                      items: hospitalNames
                          .map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedHospital = value),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => DropdownButtonFormField<String>(
                    initialValue:
                        _selectedHospital ?? 'Lifeline Medical Center',
                    decoration:
                        const InputDecoration(labelText: 'Preferred hospital'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Lifeline Medical Center',
                          child: Text('Lifeline Medical Center')),
                      DropdownMenuItem(
                          value: 'City General Hospital',
                          child: Text('City General Hospital')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedHospital = value),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Symptoms or special instructions',
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(user == null
                              ? 'Sign in to attach your profile'
                              : 'Your current profile will be linked automatically.')),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: _isSubmitting ? 'Submitting...' : 'Request ambulance',
                  icon: Icons.local_taxi,
                  onPressed:
                      _isSubmitting ? null : () => _submitRequest(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(BuildContext context) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sign in first.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      final docRef =
          await FirebaseFirestore.instance.collection('ambulance_requests').add({
        'userId': user.uid,
        'requesterId': user.uid,
        'hospitalName': _selectedHospital ?? 'Lifeline Medical Center',
        'status': 'requested',
        'notes': _notesController.text.trim(),
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'driverLocation': {
          'lat': position.latitude + 0.01,
          'lng': position.longitude + 0.01,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ambulance request submitted.')));
      await context.pushNamed(
        AppRoutes.ambulanceTracking.name,
        queryParameters: {'id': docRef.id},
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Request failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
