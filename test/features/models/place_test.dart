import 'package:blood_donation/features/models/place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Place.fromJson maps expected fields', () {
    final json = {
      'id': 'p_201',
      'name': 'City General Hospital',
      'lat': 34.0123,
      'lng': 71.5678,
      'distanceMeters': 1200,
      'isOpenNow': true,
      'phone': '+92-XXX-XXXXXXX',
    };

    final place = Place.fromJson(json);

    expect(place.id, 'p_201');
    expect(place.name, 'City General Hospital');
    expect(place.distanceMeters, 1200);
    expect(place.distanceKm, 1.2);
    expect(place.isOpenNow, isTrue);
  });
}
