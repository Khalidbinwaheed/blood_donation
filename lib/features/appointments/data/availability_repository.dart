import 'package:blood_donation/features/appointments/domain/doctor_availability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AvailabilityRepository {
  Stream<DoctorAvailability?> getAvailability(String doctorId, DateTime date);
  Future<void> setAvailability(
      String doctorId, DateTime date, List<String> slots);
}

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  throw UnimplementedError('impl not provided');
});
