import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:blood_donation/features/appointments/presentation/availability_controller.dart';
import 'package:blood_donation/features/map/data/location_provider.dart';
import 'package:blood_donation/features/map/presentation/centers_provider.dart';
import 'package:blood_donation/features/user_management/data/auth_repository.dart';
import 'package:blood_donation/features/user_management/data/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCenterId;
  String? _selectedDoctorId;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedSlot;
  bool _isLoading = false;

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a center')),
      );
      return;
    }
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor')),
      );
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('User not logged in');

      await ref.read(appointmentRepositoryProvider).createAppointment(
            userId: user.uid,
            centerId: _selectedCenterId!,
            doctorId: _selectedDoctorId!, // Using selected doctor
            date: _selectedDay,
            timeSlot: _selectedSlot!,
            type: 'Blood Donation',
          );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Booking Failed: ${e.toString().replaceAll("Exception:", "")}')), // Clean error
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text('Appointment Confirmed'),
        content: Text(
          'Your appointment is set for ${DateFormat.yMMMd().format(_selectedDay)} at $_selectedSlot.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Done'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationAsync = ref.watch(userLocationProvider);
    final location =
        locationAsync.valueOrNull ?? (lat: 37.7749, lng: -122.4194);
    final centersAsync = ref.watch(nearbyCentersProvider(
      lat: location.lat,
      lng: location.lng,
    ));

    // Fetch doctors for selected center
    final doctorsAsync = _selectedCenterId != null
        ? ref.watch(loadDoctorsByCenterProvider(_selectedCenterId!))
        : const AsyncValue.data([]);

    // Fetch availability for selected doctor (NOT center) and date
    final availabilityAsync = _selectedDoctorId != null
        ? ref.watch(doctorAvailabilityProvider(
            (doctorId: _selectedDoctorId!, date: _selectedDay)))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Select Center
                Text('Select Donation Center',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                centersAsync.when(
                  data: (centers) {
                    if (centers.isEmpty) {
                      return const Text('No centers found nearby.');
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCenterId,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Choose a center'),
                      items: centers.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.name.length > 30
                                ? '${c.name.substring(0, 27)}...'
                                : c.name,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCenterId = val;
                          _selectedDoctorId = null; // Reset doctor
                          _selectedSlot = null; // Reset slot
                        });
                      },
                      validator: (val) => val == null ? 'Required' : null,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading centers: $err'),
                ),

                const SizedBox(height: 24),

                // 2. Select Doctor (Only if center selected)
                if (_selectedCenterId != null) ...[
                  Text('Select Doctor',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  doctorsAsync.when(
                    data: (doctors) {
                      if (doctors.isEmpty) {
                        return const Text(
                            'No doctors available at this center.');
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedDoctorId,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Choose a doctor'),
                        items: doctors.map<DropdownMenuItem<String>>((d) {
                          final name =
                              'Dr. ${d.firstName ?? ''} ${d.lastName ?? ''}'
                                  .trim();
                          return DropdownMenuItem<String>(
                            value: d.uid,
                            child: Text(name.isNotEmpty ? name : 'Doctor'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDoctorId = val;
                            _selectedSlot = null; // Reset slot
                          });
                        },
                        validator: (val) => val == null ? 'Required' : null,
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, _) => Text('Error loading doctors: $err'),
                  ),
                ],

                const SizedBox(height: 24),

                // 3. Calendar
                if (_selectedDoctorId != null) ...[
                  Text('Select Date',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 60)),
                    focusedDay: _focusedDay,
                    currentDay: DateTime.now(),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedSlot = null; // Reset slot
                        });
                      }
                    },
                    calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.6),
                            shape: BoxShape.circle)),
                    headerStyle: const HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                  ),

                  const SizedBox(height: 24),

                  // 4. Time Slots
                  Text('Available Slots',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  availabilityAsync.when(
                    data: (availability) {
                      final slots = availability?.slots ?? [];
                      if (slots.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No slots available for this date.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: slots.map((slot) {
                          final isSelected = _selectedSlot == slot;
                          return ChoiceChip(
                            label: Text(slot),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(
                                  () => _selectedSlot = selected ? slot : null);
                            },
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface),
                            backgroundColor:
                                theme.colorScheme.surfaceContainerLowest,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade300)),
                          );
                        }).toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Error loading slots: $e'),
                  ),
                ],

                const SizedBox(height: 32),

                // 5. Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading || _selectedSlot == null
                        ? null
                        : _submitAppointment,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Booking',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
