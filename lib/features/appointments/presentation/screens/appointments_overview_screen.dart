import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AppointmentsOverviewScreen extends ConsumerWidget {
  const AppointmentsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sign in to view appointments.'),
        ),
      );
    }

    final appointmentsAsync = ref.watch(userAppointmentsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            tooltip: 'Book appointment',
            onPressed: () => context.pushNamed(AppRoutes.appointments.name),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No appointments scheduled yet.'),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () =>
                        context.pushNamed(AppRoutes.appointments.name),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Book now'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = appointments[index];
              final startsAt = _asDateTime(item['startsAt']) ??
                  _asDateTime(item['date']) ??
                  DateTime.now();
              final slot = (item['timeSlot'] ?? '').toString();
              final subtitleDate = slot.isEmpty
                  ? DateFormat('EEE, MMM d - h:mm a').format(startsAt)
                  : '${DateFormat('EEE, MMM d').format(startsAt)} - $slot';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_hospital_outlined),
                  ),
                  title: Text((item['type'] ?? 'Appointment').toString()),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$subtitleDate\nCenter: ${(item['centerId'] ?? 'N/A').toString()} - Doctor: ${(item['doctorId'] ?? 'N/A').toString()}',
                    ),
                  ),
                  isThreeLine: true,
                  trailing: _AppointmentStatusBadge(
                    status: (item['status'] ?? 'booked').toString(),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load appointments.'),
              const SizedBox(height: 10),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(userAppointmentsProvider(user.uid)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentStatusBadge extends StatelessWidget {
  const _AppointmentStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final (bgColor, textColor) = switch (normalized) {
      'completed' => (
          const Color(0xFF34C759).withValues(alpha: 0.18),
          const Color(0xFF1A7F43),
        ),
      'cancelled' => (
          const Color(0xFFFF453A).withValues(alpha: 0.18),
          const Color(0xFFC92D20),
        ),
      _ => (
          const Color(0xFF0A84FF).withValues(alpha: 0.16),
          const Color(0xFF0054D1),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _capitalize(normalized),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
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

String _capitalize(String input) {
  if (input.isEmpty) {
    return input;
  }
  return '${input[0].toUpperCase()}${input.substring(1)}';
}
