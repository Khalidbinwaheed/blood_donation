import 'package:flutter/material.dart';

class AppMapMarker {
  const AppMapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    this.title,
    this.icon = Icons.location_on,
    this.color = const Color(0xFFE53935),
  });

  final String id;
  final double lat;
  final double lng;
  final String? title;
  final IconData icon;
  final Color color;
}

enum AppMapLayer { street, satellite }
