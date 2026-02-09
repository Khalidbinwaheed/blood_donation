import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:blood_donation/features/appointments/presentation/availability_controller.dart';
import 'package:blood_donation/features/map/data/centers_repository.dart';
import 'package:blood_donation/features/map/data/location_provider.dart';
import 'package:blood_donation/features/user_managment/data/auth_repository.dart';
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

      // We treat centerId as doctorId for this implementation based on plan
      // Or we can have a doctor selection. Let's assume CENTER = DOCTOR/PROVIDER for simplicity
      // unless we query doctors at the center.
      // Plan said: "I will add a doctorId field ... but link it to the Center if needed."
      // Let's use centerId as the doctorId for unavailability check for now to match the dashboard logic
      // Ideally, we'd select a Doctor FROM the Center.
      // But let's stick to the prompt's simplicity: Slot booking.

      await ref.read(appointmentRepositoryProvider).createAppointment(
            userId: user.uid,
            centerId: _selectedCenterId!,
            doctorId: _selectedCenterId!, // Using center as provider
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
    final locationAsync = ref.watch(userLocationProvider);
    final location =
        locationAsync.valueOrNull ?? (lat: 37.7749, lng: -122.4194);
    final centersAsync = ref.watch(nearbyCentersProvider(location));

    // Fetch availability for selected center (acting as doctor) and date
    final availabilityAsync = _selectedCenterId != null
        ? ref.watch(doctorAvailabilityProvider(
            (doctorId: _selectedCenterId!, date: _selectedDay)))
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
                          _selectedSlot = null; // Reset slot on center change
                        });
                      },
                      validator: (val) => val == null ? 'Required' : null,
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text('Error loading centers: $err'),
                ),

                const SizedBox(height: 24),

                // 2. Calendar
                if (_selectedCenterId != null) ...[
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
                    calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                            color: Colors.red, // Brand color
                            shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle)),
                    headerStyle: const HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                  ),

                  const SizedBox(height: 24),

                  // 3. Time Slots
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
                              style: TextStyle(color: Colors.grey[600]),
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
                            selectedColor: Colors.red,
                            labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: isSelected
                                        ? Colors.red
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

                // 4. Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading || _selectedSlot == null
                        ? null
                        : _submitAppointment,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red),
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
