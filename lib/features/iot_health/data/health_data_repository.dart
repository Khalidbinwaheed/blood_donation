import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthDataRepository {
  HealthDataRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> recordHeartRate({
    required String userId,
    required int bpm,
  }) {
    return _firestore.collection('health_data').add({
      'userId': userId,
      'type': 'heart_rate',
      'value': bpm,
      'unit': 'bpm',
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> recordBloodPressure({
    required String userId,
    required int systolic,
    required int diastolic,
  }) {
    return _firestore.collection('health_data').add({
      'userId': userId,
      'type': 'blood_pressure',
      'value': {'systolic': systolic, 'diastolic': diastolic},
      'unit': 'mmHg',
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }
}

final healthDataRepositoryProvider = Provider<HealthDataRepository>((ref) {
  return HealthDataRepository(FirebaseFirestore.instance);
});
