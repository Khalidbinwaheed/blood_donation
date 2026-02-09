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

  Stream<List<Map<String, dynamic>>> getUserAppointments(String uid);

  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots);
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return FirestoreAppointmentRepository();
});
