import 'dart:math' as math;

import 'package:blood_donation/core/widgets/glass_card.dart';
import 'package:blood_donation/features/map/domain/app_map_marker.dart';
import 'package:blood_donation/features/map/presentation/widgets/osm_satellite_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AmbulanceTrackingScreen extends ConsumerStatefulWidget {
  const AmbulanceTrackingScreen({
    this.requestId,
    super.key,
  });

  final String? requestId;

  @override
  ConsumerState<AmbulanceTrackingScreen> createState() =>
      _AmbulanceTrackingScreenState();
}

class _AmbulanceTrackingScreenState
    extends ConsumerState<AmbulanceTrackingScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final requestId = widget.requestId?.trim();
    if (requestId == null || requestId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ambulance Tracking')),
        body: const Center(child: Text('No active ambulance request found.')),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('ambulance_requests')
        .doc(requestId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Ambulance Tracking')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Request not found.'));
          }

          final data = snapshot.data!.data() ?? <String, dynamic>{};
          final patientLocation =
              _readLocation(data['location']) ?? const LatLng(34.0123, 71.5678);
          final driverLocation = _readLocation(data['driverLocation']);
          final status = (data['status'] ?? 'requested').toString();
          final etaMinutes = driverLocation == null
              ? null
              : _estimateEtaMinutes(patientLocation, driverLocation);

          final markers = <AppMapMarker>[
            AppMapMarker(
              id: 'patient',
              lat: patientLocation.latitude,
              lng: patientLocation.longitude,
              title: 'You',
              icon: Icons.person_pin_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ];

          if (driverLocation != null) {
            markers.add(
              AppMapMarker(
                id: 'ambulance',
                lat: driverLocation.latitude,
                lng: driverLocation.longitude,
                title: 'Ambulance',
                icon: Icons.local_taxi,
                color: Colors.blue.shade700,
              ),
            );
          }

          return Stack(
            children: [
              OsmSatelliteMap(
                center: driverLocation ?? patientLocation,
                zoom: 14,
                mapController: _mapController,
                markers: markers,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: GlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(status),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        if (etaMinutes != null)
                          Text(
                            'Estimated arrival: ${etaMinutes.toStringAsFixed(0)} minutes',
                          )
                        else
                          Text(
                            _waitingMessage(status),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          (data['hospitalName'] ?? 'Hospital').toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  LatLng? _readLocation(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final lat = (raw['lat'] as num?)?.toDouble();
      final lng = (raw['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  double _estimateEtaMinutes(LatLng patient, LatLng driver) {
    final meters = Geolocator.distanceBetween(
      patient.latitude,
      patient.longitude,
      driver.latitude,
      driver.longitude,
    );
    return math.max(2, (meters / 500).ceilToDouble());
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'dispatched':
        return 'Ambulance dispatched';
      case 'en_route':
        return 'Driver en route';
      case 'arrived':
        return 'Ambulance arrived';
      case 'completed':
        return 'Trip completed';
      case 'cancelled':
        return 'Request cancelled';
      default:
        return 'Request received';
    }
  }

  String _waitingMessage(String status) {
    if (status == 'cancelled') {
      return 'This request was cancelled.';
    }
    if (status == 'completed') {
      return 'Trip completed.';
    }
    return 'Waiting for dispatch to share live ambulance location.';
  }
}
