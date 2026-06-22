import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/admin/presentation/admin_ambulance_dispatch_section.dart';
import 'package:blood_donation/features/admin/presentation/admin_analytics_section.dart';
import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:blood_donation/features/donor/data/donor_repository.dart';
import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:blood_donation/features/user_management/data/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _AdminSection {
  overview,
  users,
  appointments,
  dispatch,
  analytics,
  settings,
}

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  _AdminSection _selectedSection = _AdminSection.overview;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final role = (currentUser?.role ?? '').trim().toLowerCase();
    final isAdmin = role == 'admin' || role == 'super_admin';
    final isSuperAdmin = role == 'super_admin';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Restricted')),
        body: Center(
          child: FilledButton.tonalIcon(
            onPressed: () => context.goNamed(AppRoutes.home.name),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Home'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSuperAdmin ? 'Super Admin Dashboard' : 'Admin Dashboard',
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
              context.goNamed(AppRoutes.signIn.name);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;

          if (isWide) {
            return Row(
              children: [
                _AdminSidebar(
                  selected: _selectedSection,
                  onSelect: (section) {
                    setState(() => _selectedSection = section);
                  },
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildContent(
                      isSuperAdmin: isSuperAdmin,
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _AdminSectionTabs(
                selected: _selectedSection,
                onSelect: (section) {
                  setState(() => _selectedSection = section);
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildContent(
                    isSuperAdmin: isSuperAdmin,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent({required bool isSuperAdmin}) {
    switch (_selectedSection) {
      case _AdminSection.overview:
        return _buildOverview();
      case _AdminSection.users:
        return _buildUsers();
      case _AdminSection.appointments:
        return _buildAppointments(isSuperAdmin: isSuperAdmin);
      case _AdminSection.dispatch:
        return const AdminAmbulanceDispatchSection();
      case _AdminSection.analytics:
        return const AdminAnalyticsSection();
      case _AdminSection.settings:
        return _buildSettings();
    }
  }

  Widget _buildOverview() {
    final usersAsync = ref.watch(loadAllUsersProvider);
    final requestsStream =
        ref.watch(donationRepositoryProvider).getOpenRequests();
    final donationsAsync = ref.watch(donationsForDateProvider(DateTime.now()));

    final userCount = usersAsync.asData?.value.length ?? 0;

    return ListView(
      children: [
        Text(
          'Overview',
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
            SizedBox(
              width: 260,
              child: _StatsCard(
                title: 'Total Users',
                value: '$userCount',
                icon: Icons.people_outline,
                color: const Color(0xFF0A84FF),
              ),
            ),
            SizedBox(
              width: 260,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: requestsStream,
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _StatsCard(
                    title: 'Active Requests',
                    value: '$count',
                    icon: Icons.bloodtype_outlined,
                    color: const Color(0xFFFF3B30),
                  );
                },
              ),
            ),
            SizedBox(
              width: 260,
              child: donationsAsync.when(
                data: (donations) => _StatsCard(
                  title: 'Donations Today',
                  value: '${donations.length}',
                  icon: Icons.favorite_outline,
                  color: const Color(0xFF34C759),
                ),
                loading: () => const _StatsCard(
                  title: 'Donations Today',
                  value: '...',
                  icon: Icons.favorite_outline,
                  color: Color(0xFF34C759),
                ),
                error: (_, __) => const _StatsCard(
                  title: 'Donations Today',
                  value: 'Error',
                  icon: Icons.favorite_outline,
                  color: Color(0xFFFF453A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsers() {
    final usersAsync = ref.watch(loadAllUsersProvider);
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = users[index];
            final firstName = user.firstName?.trim() ?? '';
            final lastName = user.lastName?.trim() ?? '';
            final initials = _initials(firstName, lastName);
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(initials)),
                title: Text(
                  '$firstName $lastName'.trim().isEmpty
                      ? user.email
                      : '$firstName $lastName',
                ),
                subtitle: Text(user.email),
                trailing: _StatusPill(text: user.role),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildAppointments({required bool isSuperAdmin}) {
    final appointmentsAsync = ref.watch(allAppointmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Appointments',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (isSuperAdmin)
              FilledButton.icon(
                onPressed: _isSaving ? null : _addAppointment,
                icon: const Icon(Icons.add),
                label: const Text('Add Appointment'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (!isSuperAdmin)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.amber.withValues(alpha: 0.15),
            ),
            child: const Text(
              'Read-only mode: only super_admin can add, edit, or delete appointments.',
            ),
          ),
        Expanded(
          child: appointmentsAsync.when(
            data: (appointments) {
              if (appointments.isEmpty) {
                return const Center(child: Text('No appointments found.'));
              }

              return ListView.separated(
                itemCount: appointments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final id = (appointment['id'] ?? '').toString();
                  final startsAt = _asDateTime(appointment['startsAt']) ??
                      _asDateTime(appointment['date']) ??
                      DateTime.now();
                  final timeSlot = (appointment['timeSlot'] ?? '').toString();
                  final whenText = timeSlot.isEmpty
                      ? DateFormat('EEE, MMM d - h:mm a').format(startsAt)
                      : '${DateFormat('EEE, MMM d').format(startsAt)} - $timeSlot';
                  final status =
                      (appointment['status'] ?? 'booked').toString().trim();

                  return Card(
                    child: ListTile(
                      title: Text(
                        (appointment['type'] ?? 'Appointment').toString(),
                      ),
                      subtitle: Text(
                        '$whenText\nUser: ${(appointment['userId'] ?? appointment['userUid'] ?? 'N/A').toString()}  -  Doctor: ${(appointment['doctorId'] ?? 'N/A').toString()}  -  Center: ${(appointment['centerId'] ?? 'N/A').toString()}',
                      ),
                      isThreeLine: true,
                      trailing: isSuperAdmin
                          ? Wrap(
                              spacing: 6,
                              children: [
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: _isSaving
                                      ? null
                                      : () => _editAppointment(appointment),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: _isSaving || id.isEmpty
                                      ? null
                                      : () => _deleteAppointment(id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            )
                          : _StatusPill(text: status),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: () {
            ref.read(authRepositoryProvider).signOut();
            context.goNamed(AppRoutes.signIn.name);
          },
        ),
      ],
    );
  }

  Future<void> _addAppointment() async {
    final payload = await showDialog<_AppointmentEditorValue>(
      context: context,
      builder: (_) => const _AppointmentEditorDialog(),
    );
    if (payload == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(appointmentRepositoryProvider)
          .createAppointmentBySuperAdmin(
            userId: payload.userId,
            centerId: payload.centerId,
            doctorId: payload.doctorId,
            date: payload.date,
            timeSlot: payload.timeSlot,
            type: payload.type,
            status: payload.status,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Create failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _editAppointment(Map<String, dynamic> appointment) async {
    final payload = await showDialog<_AppointmentEditorValue>(
      context: context,
      builder: (_) => _AppointmentEditorDialog(
        initialValue: _AppointmentEditorValue(
          userId: (appointment['userId'] ?? appointment['userUid'] ?? '')
              .toString(),
          centerId: (appointment['centerId'] ?? '').toString(),
          doctorId: (appointment['doctorId'] ?? '').toString(),
          date: _asDateTime(appointment['date']) ??
              _asDateTime(appointment['startsAt']) ??
              DateTime.now(),
          timeSlot: (appointment['timeSlot'] ?? '').toString(),
          type: (appointment['type'] ?? 'Donation').toString(),
          status: (appointment['status'] ?? 'booked').toString(),
        ),
      ),
    );
    if (payload == null) {
      return;
    }

    final appointmentId = (appointment['id'] ?? '').toString();
    if (appointmentId.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(appointmentRepositoryProvider).updateAppointment(
            appointmentId,
            userId: payload.userId,
            centerId: payload.centerId,
            doctorId: payload.doctorId,
            date: payload.date,
            timeSlot: payload.timeSlot,
            type: payload.type,
            status: payload.status,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(appointmentRepositoryProvider).deleteAppointment(
            appointmentId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selected,
    required this.onSelect,
  });

  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        children: [
          _AdminSidebarItem(
            icon: Icons.dashboard_outlined,
            title: 'Overview',
            selected: selected == _AdminSection.overview,
            onTap: () => onSelect(_AdminSection.overview),
          ),
          _AdminSidebarItem(
            icon: Icons.people_alt_outlined,
            title: 'Users',
            selected: selected == _AdminSection.users,
            onTap: () => onSelect(_AdminSection.users),
          ),
          _AdminSidebarItem(
            icon: Icons.calendar_month_outlined,
            title: 'Appointments',
            selected: selected == _AdminSection.appointments,
            onTap: () => onSelect(_AdminSection.appointments),
          ),
          _AdminSidebarItem(
            icon: Icons.local_hospital_outlined,
            title: 'Ambulance Dispatch',
            selected: selected == _AdminSection.dispatch,
            onTap: () => onSelect(_AdminSection.dispatch),
          ),
          _AdminSidebarItem(
            icon: Icons.insights_outlined,
            title: 'Analytics',
            selected: selected == _AdminSection.analytics,
            onTap: () => onSelect(_AdminSection.analytics),
          ),
          _AdminSidebarItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            selected: selected == _AdminSection.settings,
            onTap: () => onSelect(_AdminSection.settings),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebarItem extends StatelessWidget {
  const _AdminSidebarItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
            : null,
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}

class _AdminSectionTabs extends StatelessWidget {
  const _AdminSectionTabs({
    required this.selected,
    required this.onSelect,
  });

  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: _AdminSection.values.map((section) {
          final label = switch (section) {
            _AdminSection.overview => 'Overview',
            _AdminSection.users => 'Users',
            _AdminSection.appointments => 'Appointments',
            _AdminSection.dispatch => 'Dispatch',
            _AdminSection.analytics => 'Analytics',
            _AdminSection.settings => 'Settings',
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: section == selected,
              onSelected: (_) => onSelect(section),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AppointmentEditorDialog extends StatefulWidget {
  const _AppointmentEditorDialog({
    this.initialValue,
  });

  final _AppointmentEditorValue? initialValue;

  @override
  State<_AppointmentEditorDialog> createState() =>
      _AppointmentEditorDialogState();
}

class _AppointmentEditorDialogState extends State<_AppointmentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdController;
  late final TextEditingController _centerIdController;
  late final TextEditingController _doctorIdController;
  late final TextEditingController _timeSlotController;
  late final TextEditingController _typeController;
  late final TextEditingController _statusController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _userIdController = TextEditingController(text: initial?.userId ?? '');
    _centerIdController = TextEditingController(text: initial?.centerId ?? '');
    _doctorIdController = TextEditingController(text: initial?.doctorId ?? '');
    _timeSlotController =
        TextEditingController(text: initial?.timeSlot ?? '09:00 AM');
    _typeController = TextEditingController(text: initial?.type ?? 'Donation');
    _statusController =
        TextEditingController(text: initial?.status ?? 'booked');
    _selectedDate = initial?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _centerIdController.dispose();
    _doctorIdController.dispose();
    _timeSlotController.dispose();
    _typeController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.initialValue == null ? 'Add Appointment' : 'Edit Appointment'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'User ID'),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _centerIdController,
                  decoration: const InputDecoration(labelText: 'Center ID'),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _doctorIdController,
                  decoration: const InputDecoration(labelText: 'Doctor ID'),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _timeSlotController,
                  decoration: const InputDecoration(
                    labelText: 'Time Slot (e.g. 09:30 AM)',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _statusController,
                  decoration: const InputDecoration(labelText: 'Status'),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label:
                        Text(DateFormat('EEE, MMM d, y').format(_selectedDate)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              _AppointmentEditorValue(
                userId: _userIdController.text.trim(),
                centerId: _centerIdController.text.trim(),
                doctorId: _doctorIdController.text.trim(),
                date: _selectedDate,
                timeSlot: _timeSlotController.text.trim(),
                type: _typeController.text.trim(),
                status: _statusController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _AppointmentEditorValue {
  const _AppointmentEditorValue({
    required this.userId,
    required this.centerId,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.type,
    required this.status,
  });

  final String userId;
  final String centerId;
  final String doctorId;
  final DateTime date;
  final String timeSlot;
  final String type;
  final String status;
}

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value != null && value.runtimeType.toString() == 'Timestamp') {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

String _initials(String firstName, String lastName) {
  final first = firstName.trim().isEmpty ? '' : firstName.trim()[0];
  final last = lastName.trim().isEmpty ? '' : lastName.trim()[0];
  final result = '$first$last'.trim();
  return result.isEmpty ? '?' : result.toUpperCase();
}
