import 'package:blood_donation/features/appointments/domain/appointment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AppointmentsRepository {
  Future<List<Appointment>> getUserAppointments(String userId);
  Future<void> bookAppointment(Appointment appointment);
  Future<void> cancelAppointment(String appointmentId);
}

class MockAppointmentsRepository implements AppointmentsRepository {
  final List<Appointment> _appointments = [];

  @override
  Future<List<Appointment>> getUserAppointments(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _appointments.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> bookAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(seconds: 1));
    _appointments.add(appointment);
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await Future.delayed(const Duration(seconds: 1));
    _appointments.removeWhere((a) => a.id == appointmentId);
  }
}

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return MockAppointmentsRepository();
});
