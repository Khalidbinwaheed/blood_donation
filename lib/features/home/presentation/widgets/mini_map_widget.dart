import 'package:blood_donation/features/map/data/centers_repository.dart';
import 'package:blood_donation/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMapWidget extends ConsumerStatefulWidget {
  const MiniMapWidget({super.key});

  @override
  ConsumerState<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends ConsumerState<MiniMapWidget> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    final centersAsync = ref.watch(nearbyCentersProvider((
      lat: _kInitialPosition.target.latitude,
      lng: _kInitialPosition.target.longitude,
    )));

    return Card(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // GoogleMap(
                //   mapType: MapType.normal,
                //   initialCameraPosition: _kInitialPosition,
                //   myLocationEnabled: false,
                //   zoomControlsEnabled: false,
                //   liteModeEnabled: false,
                //   markers: centersAsync.when(
                //     data: (centers) => centers
                //         .map(
                //           (c) => Marker(
                //             markerId: MarkerId(c.id),
                //             position: LatLng(c.lat, c.lng),
                //             infoWindow: InfoWindow(title: c.name),
                //           ),
                //         )
                //         .toSet(),
                //     error: (_, __) => {},
                //     loading: () => {},
                //   ),
                // ),
                Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text(
                      'Map Disabled: Add API Key in AndroidManifest.xml',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'map_fab',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add Google Maps API Key first'),
                        ),
                      );
                    },
                    // onPressed: () => context.pushNamed('map'),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          centersAsync.when(
            data: (centers) {
              if (centers.isEmpty) {
                return const ListTile(title: Text('No centers nearby'));
              }
              final nearest = centers.first;
              return ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.red),
                title: Text(nearest.name),
                subtitle: Text(
                    '${nearest.openNow ? AppLocalizations.of(context)!.openNow : "Closed"} • ${nearest.address}'),
                trailing: FilledButton.tonal(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context)!.directions),
                ),
              );
            },
            error: (err, stack) => ListTile(
              leading: const Icon(Icons.error, color: Colors.orange),
              title: const Text('Could not load centers'),
              subtitle: Text(err.toString(), maxLines: 1),
            ),
            loading: () => const ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Finding nearby centers...'),
            ),
          ),
        ],
      ),
    );
  }
}
