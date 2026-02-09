import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DonorRepository {
  Future<void> updateEligibility(String uid, Map<String, dynamic> data);
  Future<void> setAvailability(String uid, DateTime start, DateTime end);
  Stream<List<Map<String, dynamic>>> getDonationHistory(String uid);
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
}

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return FirestoreDonorRepository();
});
