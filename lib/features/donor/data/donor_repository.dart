import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DonorRepository {
  Future<void> updateEligibility(String uid, Map<String, dynamic> data);
  Future<void> setAvailability(String uid, DateTime start, DateTime end);
  Stream<List<Map<String, dynamic>>> getDonationHistory(String uid);
  Stream<List<Map<String, dynamic>>> getDonationsForDate(DateTime date);
}

class FirestoreDonorRepository implements DonorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> updateEligibility(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('profiles').doc(uid).set(
          data,
          SetOptions(merge: true),
        );
    // Update main user doc status too for easy access
    await _firestore.collection('users').doc(uid).update({
      'donorEligibilityStatus': data['donorEligibilityStatus'] ?? 'pending',
    });
  }

  @override
  Future<void> setAvailability(String uid, DateTime start, DateTime end) async {
    await _firestore.collection('donorAvailabilities').add({
      'donorUid': uid,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getDonationHistory(String uid) {
    return _firestore
        .collection('donations')
        .where('donorUid', isEqualTo: uid)
        .orderBy('donationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getDonationsForDate(DateTime date) {
    // Create start and end of the given date
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('donations')
        .where('donationDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('donationDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return FirestoreDonorRepository();
});

final donationsForDateProvider =
    StreamProvider.family<List<Map<String, dynamic>>, DateTime>((ref, date) {
  return ref.watch(donorRepositoryProvider).getDonationsForDate(date);
});
