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
  });

  Stream<List<Map<String, dynamic>>> getUserRequests(String uid);

  Stream<List<Map<String, dynamic>>> getOpenRequests();
}

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return FirestoreDonationRepository();
});
