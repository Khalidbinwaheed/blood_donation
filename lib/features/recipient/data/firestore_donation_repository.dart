import 'package:blood_donation/features/recipient/data/donation_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDonationRepository implements DonationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createDonationRequest({
    required String requesterUid,
    required String bloodGroup,
    required String hospitalName,
    required String urgency,
    String? note,
    required String contactEmail,
  }) async {
    // Estimating deadline as 2 days from now for implementation simplicity
    // in a real app, user should pick this.
    final deadline = DateTime.now().add(const Duration(days: 2));

    await _firestore.collection('requests').add({
      'requesterId': requesterUid,
      'bloodGroupNeeded': bloodGroup,
      'hospitalName': hospitalName,
      'severity': urgency,
      'note': note ?? '',
      'status': 'Open',
      'contactEmail': contactEmail,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserRequests(String uid) {
    return _firestore
        .collection('requests') // Changed to 'requests' to match new plan
        .where('requesterId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Handle Timestamp conversion if necessary for UI display before freezing
        return data;
      }).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getOpenRequests() {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: 'Open')
        .orderBy('createdAt', descending: true)
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
