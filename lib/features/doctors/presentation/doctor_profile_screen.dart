import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/core/widgets/gradient_button.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, this.doctor});

  final AppUser? doctor;

  @override
  Widget build(BuildContext context) {
    final model = doctor ??
        const AppUser(
          uid: 'doctor_demo',
          email: 'doctor@lifeline.app',
          firstName: 'Dr. Amina',
          lastName: 'Khan',
          role: 'doctor',
          type: 'doctor',
          bloodGroup: 'N/A',
          district: 'Central Hospital',
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          GlassCard(
            child: Column(
              children: [
                CircleAvatar(radius: 34, child: Text(_initials(model))),
                const SizedBox(height: 10),
                Text(_name(model),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(_specialization(model),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('4.8 Rating')),
                    Chip(label: Text('12 Years Exp')),
                    Chip(label: Text('Online Consult')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hospital',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(model.district.ifEmpty('Lifeline Medical Center')),
                const SizedBox(height: 12),
                Text('Available slots',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Mon 9:00 AM')),
                    Chip(label: Text('Mon 1:00 PM')),
                    Chip(label: Text('Tue 5:30 PM')),
                    Chip(label: Text('Video call')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Book Appointment',
            icon: Icons.calendar_month,
            onPressed: () => context.pushNamed(AppRoutes.appointments.name),
          ),
        ],
      ),
    );
  }

  String _name(AppUser user) =>
      '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().ifEmpty('Doctor');
  String _specialization(AppUser user) =>
      user.conditions.isNotEmpty ? user.conditions.first : 'Internal Medicine';
  String _initials(AppUser user) {
    final name = _name(user);
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
