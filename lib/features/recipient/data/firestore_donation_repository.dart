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
    String? title,
    int? amountBags,
    DateTime? neededOn,
    String? country,
    String? city,
    String? contactPersonName,
    String? contactPhone,
  }) async {
    // Estimating deadline as 2 days from now for implementation simplicity
    // in a real app, user should pick this.
    final deadline = DateTime.now().add(const Duration(days: 2));

    await _firestore.collection('requests').add({
      'requesterId': requesterUid,
      'bloodGroupNeeded': bloodGroup,
      'bloodGroup': bloodGroup,
      'hospitalName': hospitalName,
      'severity': urgency,
      'note': note ?? '',
      'reason': note ?? '',
      'status': 'Open',
      'contactEmail': contactEmail,
      'contactPersonName': contactPersonName ?? '',
      'contactPhone': contactPhone ?? '',
      'title': title ?? '$bloodGroup Blood Needed',
      'amount': amountBags ?? 1,
      'country': country ?? '',
      'city': city ?? '',
      'date': neededOn == null ? null : Timestamp.fromDate(neededOn),
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

  @override
  Stream<Map<String, dynamic>?> watchRequestById(String requestId) {
    return _firestore.collection('requests').doc(requestId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        final data = snapshot.data() ?? <String, dynamic>{};
        data['id'] = snapshot.id;
        return data;
      },
    );
  }

  @override
  Future<void> offerToDonate({
    required String requestId,
    required String donorUid,
    required String donorName,
    required String donorPhone,
    required String donorBloodGroup,
  }) async {
    final requestRef = _firestore.collection('requests').doc(requestId);
    final requestSnap = await requestRef.get();
    if (!requestSnap.exists) {
      throw Exception('Request not found');
    }

    final requestData = requestSnap.data() ?? <String, dynamic>{};
    final requesterId = (requestData['requesterId'] ?? '').toString();
    final hospital = (requestData['hospitalName'] ?? 'hospital').toString();

    final offer = {
      'donorUid': donorUid,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'donorBloodGroup': donorBloodGroup,
      'offeredAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    await requestRef.update({
      'offers': FieldValue.arrayUnion([offer]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (requesterId.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(requesterId)
          .collection('notifications')
          .add({
        'title': '$donorName offered to donate',
        'body':
            '$donorBloodGroup donor is available for your request at $hospital.',
        'type': 'blood_offer',
        'requestId': requestId,
        'donorUid': donorUid,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  @override
  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    required String updatedBy,
  }) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
