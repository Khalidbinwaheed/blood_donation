import 'package:blood_donation/features/appointments/data/appointment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreAppointmentRepository implements AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createAppointment({
    required String userId,
    required String centerId,
    required DateTime date,
    required String timeSlot,
    String? type,
    // Doctor ID is required for the new logic, but interface might need update or we infer/pass it
    String? doctorId,
  }) async {
    if (doctorId == null) {
      // Fallback or error if doctorId is mandatory for availability check
      // For now, assuming centerId acts as doctorId or we use a specific doctorId
      throw ArgumentError('doctorId is required for booking');
    }

    final availabilityRef = _firestore.collection('availability');
    // We assume availability docs are stored with a composite ID or queryable
    // Let's use a convention: doctorId_yyyy-MM-dd
    final dateStr = date.toIso8601String().split('T').first;
    final availabilityDocId = '${doctorId}_$dateStr';
    final docRef = availabilityRef.doc(availabilityDocId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Doctor is not available on this date.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      // Manual mapping or use simple cast since it's inside transaction
      final List<dynamic> slots = data['slots'] ?? [];
      final List<String> availableSlots = slots.cast<String>();

      if (!availableSlots.contains(timeSlot)) {
        throw Exception('Slot $timeSlot is no longer available.');
      }

      // Remove the slot
      transaction.update(docRef, {
        'slots': FieldValue.arrayRemove([timeSlot])
      });

      // Create Appointment
      final appointmentRef = _firestore.collection('appointments').doc();
      transaction.set(appointmentRef, {
        'id': appointmentRef.id,
        'userUid': userId,
        'centerId': centerId,
        'doctorId': doctorId,
        'date': Timestamp.fromDate(date),
        'startsAt':
            Timestamp.fromDate(date), // Simplification: actual date + time
        'endsAt': Timestamp.fromDate(date.add(const Duration(minutes: 30))),
        'status': 'booked',
        'type': type ?? 'Donation',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserAppointments(String uid) {
    return _firestore
        .collection('appointments')
        .where('userUid', isEqualTo: uid)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Helper to init availability (internal/testing)
  @override
  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots) async {
    final dateStr = date.toIso8601String().split('T').first;
    final availabilityDocId = '${doctorId}_$dateStr';
    await _firestore.collection('availability').doc(availabilityDocId).set({
      'id': availabilityDocId,
      'doctorId': doctorId,
      'date': Timestamp.fromDate(date),
      'slots': slots,
    });
  }
}

// Provider update needed in main/di or here
final firestoreAppointmentRepositoryProvider =
    Provider<AppointmentRepository>((ref) {
  return FirestoreAppointmentRepository();
});
