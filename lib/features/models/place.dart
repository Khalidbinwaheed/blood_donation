class Place {
  const Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    required this.isOpenNow,
    required this.phone,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final double distanceMeters;
  final bool isOpenNow;
  final String phone;

  double get distanceKm => distanceMeters / 1000;

  Place copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    double? distanceMeters,
    bool? isOpenNow,
    String? phone,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'distanceMeters': distanceMeters,
      'isOpenNow': isOpenNow,
      'phone': phone,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    final latValue = json['lat'] ??
        json['latitude'] ??
        json['location']?['lat'] ??
        json['geometry']?['location']?['lat'];
    final lngValue = json['lng'] ??
        json['longitude'] ??
        json['location']?['lng'] ??
        json['geometry']?['location']?['lng'];

    return Place(
      id: (json['id'] ?? json['place_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown hospital').toString(),
      lat: _toDouble(latValue),
      lng: _toDouble(lngValue),
      distanceMeters: _toDouble(
        json['distanceMeters'] ?? json['distance'] ?? 0,
      ),
      isOpenNow: _toBool(
        json['isOpenNow'] ??
            json['openNow'] ??
            json['open_now'] ??
            json['opening_hours']?['open_now'],
      ),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == 'yes' || normalized == '1';
    }
    return false;
  }
}
