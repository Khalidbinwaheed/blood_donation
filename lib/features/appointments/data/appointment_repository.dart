import 'package:blood_donation/features/appointments/data/firestore_appointment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AppointmentRepository {
  Future<void> createAppointment({
    required String userId,
    required String centerId,
    required DateTime date,
    required String timeSlot,
    String? type,
    String? doctorId,
  });

  Future<void> createAppointmentBySuperAdmin({
    required String userId,
    required String centerId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    String? type,
    String? status,
  });

  Stream<List<Map<String, dynamic>>> getUserAppointments(String uid);
  Stream<List<Map<String, dynamic>>> getAllAppointments();

  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots);

  Stream<List<Map<String, dynamic>>> getDoctorAppointments(String doctorId);

  Future<void> updateAppointment(
    String appointmentId, {
    String? userId,
    String? centerId,
    String? doctorId,
    DateTime? date,
    String? timeSlot,
    String? type,
    String? status,
  });

  Future<void> deleteAppointment(String appointmentId);
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return FirestoreAppointmentRepository();
});

final doctorAppointmentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, doctorId) {
  return ref
      .watch(appointmentRepositoryProvider)
      .getDoctorAppointments(doctorId);
});

final userAppointmentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return ref.watch(appointmentRepositoryProvider).getUserAppointments(uid);
});

final allAppointmentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(appointmentRepositoryProvider).getAllAppointments();
});
