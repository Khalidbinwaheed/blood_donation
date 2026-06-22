import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/features/user_management/Domain/app_user.dart';
import 'package:blood_donation/features/user_management/data/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  static const _specializations = [
    'All',
    'Cardiology',
    'Hematology',
    'Internal Medicine',
    'Emergency',
  ];

  final _searchController = TextEditingController();
  String _selectedSpec = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(loadAllUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: doctorsAsync.when(
        data: (users) {
          final query = _searchController.text.trim().toLowerCase();
          final doctors = users.where(_isDoctor).where((doctor) {
            final name = '${doctor.firstName ?? ''} ${doctor.lastName ?? ''}'
                .trim()
                .toLowerCase();
            final location = doctor.district.toLowerCase();
            final matchesSearch = query.isEmpty ||
                name.contains(query) ||
                location.contains(query);
            final matchesSpec = _selectedSpec == 'All' ||
                (doctor.conditions
                    .join(' ')
                    .toLowerCase()
                    .contains(_selectedSpec.toLowerCase()));
            return matchesSearch && matchesSpec;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search doctors or hospital',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final spec in _specializations)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(spec),
                                selected: _selectedSpec == spec,
                                onSelected: (_) =>
                                    setState(() => _selectedSpec = spec),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (doctors.isEmpty)
                const Center(child: Text('No doctors matched your filters.'))
              else
                for (final doctor in doctors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(_initials(doctor)),
                        ),
                        title: Text(_name(doctor)),
                        subtitle: Text(
                            '${_specialization(doctor)}\n${doctor.district.ifEmpty('Hospital network')}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.pushNamed(
                          AppRoutes.doctorProfile.name,
                          extra: doctor,
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load doctors: $error')),
      ),
    );
  }

  bool _isDoctor(AppUser user) {
    final role = user.role.toLowerCase();
    final type = user.type.toLowerCase();
    return role == 'doctor' || type == 'doctor';
  }

  String _name(AppUser user) {
    return '${user.firstName ?? ''} ${user.lastName ?? ''}'
        .trim()
        .ifEmpty('Doctor');
  }

  String _specialization(AppUser user) {
    if (user.conditions.isNotEmpty) {
      return user.conditions.first;
    }
    return 'General Medicine';
  }

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
