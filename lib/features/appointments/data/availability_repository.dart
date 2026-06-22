import 'package:blood_donation/features/appointments/domain/doctor_availability.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AvailabilityRepository {
  Stream<DoctorAvailability?> getAvailability(String doctorId, DateTime date);
  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots);
}

class FirestoreAvailabilityRepository implements AvailabilityRepository {
  FirestoreAvailabilityRepository(this._firestore);

  final FirebaseFirestore _firestore;

  String _docId(String doctorId, DateTime date) {
    final dateStr = date.toIso8601String().split('T').first;
    return '${doctorId}_$dateStr';
  }

  @override
  Stream<DoctorAvailability?> getAvailability(
      String doctorId, DateTime date) {
    final docId = _docId(doctorId, date);
    return _firestore.collection('availability').doc(docId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        final data = snapshot.data();
        if (data == null) {
          return null;
        }
        return DoctorAvailability(
          id: snapshot.id,
          doctorId: data['doctorId'] as String,
          date: (data['date'] as Timestamp).toDate(),
          slots: List<String>.from(data['slots'] ?? []),
        );
      },
    );
  }

  @override
  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots) async {
    final docId = _docId(doctorId, date);
    await _firestore.collection('availability').doc(docId).set({
      'doctorId': doctorId,
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ),
      'slots': slots,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return FirestoreAvailabilityRepository(FirebaseFirestore.instance);
});
