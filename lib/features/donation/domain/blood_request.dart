import 'package:freezed_annotation/freezed_annotation.dart';

part 'blood_request.freezed.dart';
part 'blood_request.g.dart';

@freezed
class BloodRequest with _$BloodRequest {
  const factory BloodRequest({
    required String id,
    required String requesterId,
    required String bloodGroupNeeded,
    @Default('High') String severity, // Critical, High, Moderate
    required DateTime deadline,
    required String contactEmail,
    @Default('Open') String status, // Open, Closed
    required String hospitalName,
    @Default('') String note,
    required DateTime createdAt,
  }) = _BloodRequest;

  factory BloodRequest.fromJson(Map<String, dynamic> json) =>
      _$BloodRequestFromJson(json);
}
