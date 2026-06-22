import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/features/models/place.dart';
import 'package:blood_donation/features/services/places_service.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

/// Google Places Nearby Search for hospitals and clinics.
class GooglePlacesApiService implements PlacesService {
  GooglePlacesApiService(this._dio);

  final Dio _dio;

  @override
  Future<List<Place>> nearbyHospitals({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    if (!AppEnv.hasGoogleMapsApi) {
      throw Exception('GOOGLE_MAPS_API_KEY is not configured');
    }

    final response = await _dio.get<Map<String, dynamic>>(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
      queryParameters: {
        'location': '$lat,$lng',
        'radius': radiusMeters.clamp(500, 50000).toInt(),
        'type': 'hospital',
        'key': AppEnv.googleMapsApiKey,
      },
      options: Options(
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    final data = response.data ?? const <String, dynamic>{};
    final status = (data['status'] ?? '').toString();
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception(
        'Google Places error: ${data['error_message'] ?? status}',
      );
    }

    final results = data['results'];
    if (results is! List) {
      return const [];
    }

    final places = results
        .whereType<Map>()
        .map((item) => Place.fromJson(Map<String, dynamic>.from(item)))
        .where((place) => place.lat != 0 && place.lng != 0)
        .map((place) {
          final distance = place.distanceMeters > 0
              ? place.distanceMeters
              : Geolocator.distanceBetween(lat, lng, place.lat, place.lng);
          return place.copyWith(distanceMeters: distance);
        })
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    return places;
  }
}
