import 'package:blood_donation/features/map/data/centers_repository.dart';
import 'package:blood_donation/features/map/domain/center_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreCentersRepository implements CentersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<CenterModel>> getNearbyCenters(
      {required double lat, required double lng, double radius = 10.0}) async {
    try {
      final snapshot = await _firestore.collection('centers').get();

      if (snapshot.docs.isEmpty) {
        return const [];
      }

      final centers = <CenterModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final centerLat = _toDouble(data['lat']);
        final centerLng = _toDouble(data['lng']);

        if (centerLat == null || centerLng == null) {
          continue;
        }

        final distanceInMeters = Geolocator.distanceBetween(
          lat,
          lng,
          centerLat,
          centerLng,
        );
        final distanceInKm = distanceInMeters / 1000;

        centers.add(_fromFirestore(doc, distanceInKm));
      }

      final nearby = centers
          .where((c) => (c.distance ?? double.infinity) <= radius)
          .toList()
        ..sort((a, b) => (a.distance ?? double.infinity)
            .compareTo(b.distance ?? double.infinity));

      return nearby;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<CenterModel?> getCenterById(String id) async {
    try {
      final doc = await _firestore.collection('centers').doc(id).get();
      if (doc.exists) {
        return _fromFirestore(doc, 0);
      }
    } catch (_) {
      // Caller handles null state.
    }
    return null;
  }

  CenterModel _fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, double distance) {
    final data = doc.data()!;
    final centerLat = _toDouble(data['lat']) ?? 0;
    final centerLng = _toDouble(data['lng']) ?? 0;
    return CenterModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Center',
      lat: centerLat,
      lng: centerLng,
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      hours: data['hours'] ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
      openNow: _toBool(data['openNow']),
      accessibility: List<String>.from(data['accessibility'] ?? []),
      website: data['website']?.toString(),
      distance: distance,
    );
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }
}
