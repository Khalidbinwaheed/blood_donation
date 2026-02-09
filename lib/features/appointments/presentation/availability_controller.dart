import 'package:blood_donation/features/appointments/domain/doctor_availability.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple provider to fetch availability for a specific doctor and date
final doctorAvailabilityProvider = StreamProvider.family
    .autoDispose<DoctorAvailability?, ({String doctorId, DateTime date})>(
        (ref, args) {
  final firestore = FirebaseFirestore.instance;
  // This logic should ideally be in a repository, but for speed and directness we can put it here or use the repository we defined
  // Let's use the repository pattern properly if possible, but we don't have a concrete AvailabilityRepository provider yet.
  // So we use direct firestore or casting for now.

  final dateStr = args.date.toIso8601String().split('T').first;
  final docId = '${args.doctorId}_$dateStr';

  return firestore
      .collection('availability')
      .doc(docId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    // Manual mapping or use generated fromJson if ID is consistent
    return DoctorAvailability(
      id: snapshot.id,
      doctorId: data['doctorId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      slots: List<String>.from(data['slots'] ?? []),
    );
  });
});
