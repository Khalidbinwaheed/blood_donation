import 'package:blood_donation/features/donor/domain/donation_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DonationRepository {
  Future<List<DonationRequest>> getUserRequests(String userId);
  Future<void> createRequest(DonationRequest request);
}

class MockDonationRepository implements DonationRepository {
  final List<DonationRequest> _requests = [];

  @override
  Future<List<DonationRequest>> getUserRequests(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _requests.where((r) => r.requesterUserId == userId).toList();
  }

  @override
  Future<void> createRequest(DonationRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    _requests.add(request);
  }
}

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return MockDonationRepository();
});
