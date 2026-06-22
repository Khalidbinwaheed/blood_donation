import 'package:blood_donation/features/recipient/data/firestore_donation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DonationRepository {
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
  });

  Stream<List<Map<String, dynamic>>> getUserRequests(String uid);

  Stream<List<Map<String, dynamic>>> getOpenRequests();

  Stream<Map<String, dynamic>?> watchRequestById(String requestId);

  Future<void> offerToDonate({
    required String requestId,
    required String donorUid,
    required String donorName,
    required String donorPhone,
    required String donorBloodGroup,
  });

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    required String updatedBy,
  });
}

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return FirestoreDonationRepository();
});
