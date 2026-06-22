import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _availableSlots = [];
  final Set<String> _selectedSlots = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generatePotentialSlots();
  }

  void _generatePotentialSlots() {
    _availableSlots.clear();
    final start = DateTime(2022, 1, 1, 9, 0); // 9:00 AM
    final end = DateTime(2022, 1, 1, 17, 0); // 5:00 PM
    var current = start;

    while (current.isBefore(end)) {
      _availableSlots.add(DateFormat('hh:mm a').format(current));
      current = current.add(const Duration(minutes: 30));
    }
    // Default select all
    _selectedSlots.addAll(_availableSlots);
    setState(() {});
  }

  Future<void> _saveAvailability() async {
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one slot.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('Not logged in');

      await ref.read(appointmentRepositoryProvider).setAvailability(
            user.uid,
            _selectedDate,
            _selectedSlots.toList(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability Saved Successfully!')),
        );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Availability', icon: Icon(Icons.access_time)),
              Tab(text: 'Appointments', icon: Icon(Icons.calendar_month)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Availability
            Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: _buildDateSelection(),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 2,
                                child: _buildSlotSelection(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildDateSelection(),
                              const SizedBox(height: 24),
                              Expanded(child: _buildSlotSelection()),
                            ],
                          ),
                  );
                },
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Availability'),
                ),
              ),
            ),
            // Tab 2: Appointments
            _buildAppointmentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Center(child: Text('Not logged in'));

    final appointmentsAsync = ref.watch(doctorAppointmentsProvider(user.uid));

    return appointmentsAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const Center(child: Text('No upcoming appointments.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final apt = appointments[index];
            final date = (apt['date'] as dynamic)?.toDate();
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                    'Appointment at ${apt['centerId'] ?? 'Center'}'), // Ideally fetch center name
                subtitle: Text(
                  'Date: ${date != null ? DateFormat.yMMMd().add_jm().format(date) : 'N/A'}\nType: ${apt['type'] ?? 'General'}',
                ),
                isThreeLine: true,
                trailing: Text(apt['status'] ?? 'Scheduled'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildDateSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Slots',
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedSlots.length == _availableSlots.length) {
                        _selectedSlots.clear();
                      } else {
                        _selectedSlots.addAll(_availableSlots);
                      }
                    });
                  },
                  child: Text(_selectedSlots.length == _availableSlots.length
                      ? 'Deselect All'
                      : 'Select All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableSlots.map((slot) {
                    final isSelected = _selectedSlots.contains(slot);
                    return FilterChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSlots.add(slot);
                          } else {
                            _selectedSlots.remove(slot);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
