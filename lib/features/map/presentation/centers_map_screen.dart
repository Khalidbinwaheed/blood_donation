import 'package:blood_donation/features/map/domain/center_model.dart';
import 'package:blood_donation/features/map/presentation/centers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CentersMapScreen extends ConsumerStatefulWidget {
  const CentersMapScreen({super.key});

  @override
  ConsumerState<CentersMapScreen> createState() => _CentersMapScreenState();
}

class _CentersMapScreenState extends ConsumerState<CentersMapScreen> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 13.0,
  );

  CenterModel? _selectedCenter;

  @override
  Widget build(BuildContext context) {
    final centersAsync = ref.watch(nearbyCentersProvider(
      lat: _kInitialPosition.target.latitude,
      lng: _kInitialPosition.target.longitude,
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Centers')),
      body: Stack(
        children: [
          favoritesMap(centersAsync),
          if (_selectedCenter != null) _buildCenterCard(_selectedCenter!),
        ],
      ),
    );
  }

  Widget favoritesMap(AsyncValue<List<CenterModel>> centersAsync) {
    return GoogleMap(
      initialCameraPosition: _kInitialPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onTap: (_) => setState(() => _selectedCenter = null),
      markers: centersAsync.when(
        data: (centers) => centers
            .map(
              (c) => Marker(
                markerId: MarkerId(c.id),
                position: LatLng(c.lat, c.lng),
                infoWindow: InfoWindow(title: c.name),
                onTap: () => setState(() => _selectedCenter = c),
              ),
            )
            .toSet(),
        error: (_, __) => {},
        loading: () => {},
      ),
    );
  }

  Widget _buildCenterCard(CenterModel center) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                center.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16,
                      color: center.openNow ? Colors.green : Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    center.openNow ? 'Open Now' : 'Closed',
                    style: TextStyle(
                      color: center.openNow ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(center.address),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () {}, child: const Text('Call')),
                  const SizedBox(width: 8),
                  FilledButton(
                      onPressed: () {}, child: const Text('Directions')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
