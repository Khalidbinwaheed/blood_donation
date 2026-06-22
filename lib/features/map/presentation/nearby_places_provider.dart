import 'package:blood_donation/features/map/data/location_provider.dart';
import 'package:blood_donation/features/models/place.dart';
import 'package:blood_donation/features/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nearbyPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final location = await ref.watch(userLocationProvider.future);
  if (location == null) {
    return const [];
  }
  final service = ref.watch(placesServiceProvider);
  return service.nearbyHospitals(
    lat: location.lat,
    lng: location.lng,
    radiusMeters: 5000,
  );
});
