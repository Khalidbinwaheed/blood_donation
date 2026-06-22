import 'package:blood_donation/features/map/data/firestore_centers_repository.dart';
import 'package:blood_donation/features/map/domain/center_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class CentersRepository {
  Future<List<CenterModel>> getNearbyCenters(
      {required double lat, required double lng, double radius = 10.0});
  Future<CenterModel?> getCenterById(String id);
}

class MockCentersRepository implements CentersRepository {
  @override
  Future<List<CenterModel>> getNearbyCenters(
      {required double lat, required double lng, double radius = 10.0}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const CenterModel(
        id: '1',
        name: 'City General Hospital',
        lat: 37.7749,
        lng: -122.4194,
        address: '123 Main St, San Francisco, CA',
        phone: '(555) 123-4567',
        specializations: ['Blood', 'Organ'],
        openNow: true,
        accessibility: ['Wheelchair'],
        hours: 'Mon-Fri: 8am - 8pm',
        distance: 2.5,
      ),
      const CenterModel(
        id: '2',
        name: 'Red Cross Donation Center',
        lat: 37.7849,
        lng: -122.4094,
        address: '456 Market St, San Francisco, CA',
        phone: '(555) 987-6543',
        specializations: ['Blood', 'Plasma'],
        openNow: false,
        accessibility: ['Wheelchair', 'Parking'],
        hours: 'Mon-Sat: 9am - 5pm',
        distance: 3.8,
      ),
      const CenterModel(
        id: '3',
        name: 'Community Health Clinic',
        lat: 37.7649,
        lng: -122.4294,
        address: '789 Mission St, San Francisco, CA',
        phone: '(555) 555-5555',
        specializations: ['Blood'],
        openNow: true,
        accessibility: [],
        hours: '24/7',
        distance: 1.2,
      ),
    ];
  }

  @override
  Future<CenterModel?> getCenterById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final centers = await getNearbyCenters(lat: 0, lng: 0);
    try {
      return centers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

final centersRepositoryProvider = Provider<CentersRepository>((ref) {
  return FirestoreCentersRepository();
});
