import 'package:blood_donation/core/config/app_env.dart';
import 'package:blood_donation/features/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

abstract class PlacesService {
  Future<List<Place>> nearbyHospitals({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  });
}

class ApiPlacesService implements PlacesService {
  ApiPlacesService(this._dio);

  final Dio _dio;

  @override
  Future<List<Place>> nearbyHospitals({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    if (!AppEnv.hasPlacesApi) {
      throw Exception('PLACES_API_URL is not configured');
    }

    final response = await _dio.get<Map<String, dynamic>>(
      AppEnv.placesApiUrl,
      queryParameters: {
        'q': 'hospital',
        'lat': lat,
        'lng': lng,
        'radius': radiusMeters.toInt(),
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final raw = _extractList(data);

    final places = raw
        .map(Place.fromJson)
        .where((place) => place.lat != 0 && place.lng != 0)
        .map((place) {
      final distanceMeters = place.distanceMeters <= 0
          ? Geolocator.distanceBetween(lat, lng, place.lat, place.lng)
          : place.distanceMeters;
      return place.copyWith(distanceMeters: distanceMeters);
    }).toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    return places;
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> data) {
    final candidates = [
      data['results'],
      data['items'],
      data['places'],
      data['data'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }
}

class FirestorePlacesService implements PlacesService {
  FirestorePlacesService(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<Place>> nearbyHospitals({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    final snapshot = await _firestore.collection('centers').get();
    final places = snapshot.docs
        .map((doc) {
          final data = doc.data();
          final place = Place.fromJson({
            'id': doc.id,
            ...data,
          });
          final distance =
              Geolocator.distanceBetween(lat, lng, place.lat, place.lng);
          return place.copyWith(distanceMeters: distance);
        })
        .where((place) => place.distanceMeters <= radiusMeters)
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return places;
  }
}

class MockPlacesService implements PlacesService {
  const MockPlacesService();

  @override
  Future<List<Place>> nearbyHospitals({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    throw UnimplementedError(
      'MockPlacesService is available for tests only.',
    );
  }
}
