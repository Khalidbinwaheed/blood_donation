import 'package:freezed_annotation/freezed_annotation.dart';

part 'donation_request.freezed.dart';
part 'donation_request.g.dart';

@freezed
class DonationRequest with _$DonationRequest {
  const factory DonationRequest({
    required String id,
    required String requesterUserId,
    required String requestType, // blood, organ
    required String bloodType,
    String? organType,
    required String status, // Pending, Matched, In-Progress, Fulfilled
    @Default(0) int priorityScore,
    String? centerId,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? note,
  }) = _DonationRequest;

  factory DonationRequest.fromJson(Map<String, dynamic> json) =>
      _$DonationRequestFromJson(json);
}
