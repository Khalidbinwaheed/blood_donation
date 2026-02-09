import 'package:blood_donation/features/map/data/centers_repository.dart';
import 'package:blood_donation/features/map/domain/center_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // For distance calculation

class FirestoreCentersRepository implements CentersRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<CenterModel>> getNearbyCenters(
      {required double lat, required double lng, double radius = 10.0}) async {
    try {
      // In a real production app with GeoHashing, we'd query by bounds.
      // For this implementation, we fetch all (assuming < 100 centers) and filter client-side.
      final snapshot = await _firestore.collection('centers').get();

      final centers = snapshot.docs.map((doc) {
        final data = doc.data();
        final centerLat = (data['lat'] as num).toDouble();
        final centerLng = (data['lng'] as num).toDouble();

        final distanceInMeters = Geolocator.distanceBetween(
          lat,
          lng,
          centerLat,
          centerLng,
        );
        final distanceInKm = distanceInMeters / 1000;

        return _fromFirestore(doc, distanceInKm);
      }).toList();

      // Filter by radius and sort
      final nearby = centers
          .where((c) => (c.distance ?? double.infinity) <= radius)
          .toList();
      nearby.sort((a, b) => (a.distance ?? double.infinity)
          .compareTo(b.distance ?? double.infinity));

      return nearby;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CenterModel?> getCenterById(String id) async {
    try {
      final doc = await _firestore.collection('centers').doc(id).get();
      if (doc.exists) {
        return _fromFirestore(
            doc, 0); // Distance unknown from single fetch without user loc
      }
    } catch (e) {
      // log error
    }
    return null;
  }

  CenterModel _fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, double distance) {
    final data = doc.data()!;
    return CenterModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Center',
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      hours: data['hours'] ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
      openNow: data['openNow'] ?? false,
      accessibility: List<String>.from(data['accessibility'] ?? []),
      distance: distance,
    );
  }
}
