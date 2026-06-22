import 'package:blood_donation/features/map/data/location_provider.dart';
import 'package:blood_donation/features/map/domain/app_map_marker.dart';
import 'package:blood_donation/features/map/presentation/centers_provider.dart';
import 'package:blood_donation/features/map/presentation/widgets/osm_satellite_map.dart';
import 'package:blood_donation/l10n/app_localizations.dart';
import 'package:blood_donation/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MiniMapWidget extends ConsumerStatefulWidget {
  const MiniMapWidget({super.key});

  @override
  ConsumerState<MiniMapWidget> createState() => _MiniMapWidgetState();
}

class _MiniMapWidgetState extends ConsumerState<MiniMapWidget> {
  static const LatLng _kInitialPosition = LatLng(37.42796133580664, -122.085749655962);

  @override
  Widget build(BuildContext context) {
    final userLocationAsync = ref.watch(userLocationProvider);
    final location = userLocationAsync.valueOrNull;
    final target = location == null
        ? _kInitialPosition
        : LatLng(location.lat, location.lng);

    final centersAsync = ref.watch(nearbyCentersProvider(
      lat: target.latitude,
      lng: target.longitude,
    ));

    final markers = centersAsync.maybeWhen(
      data: (centers) => centers
          .map(
            (center) => AppMapMarker(
              id: center.id,
              lat: center.lat,
              lng: center.lng,
              title: center.name,
              icon: Icons.local_hospital,
            ),
          )
          .toList(),
      orElse: () => <AppMapMarker>[],
    );

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
                OsmSatelliteMap(
                  key: ValueKey(
                    '${target.latitude.toStringAsFixed(4)}:${target.longitude.toStringAsFixed(4)}',
                  ),
                  center: target,
                  zoom: 13,
                  markers: markers,
                  interactive: false,
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'map_fab',
                    onPressed: () => context.pushNamed(AppRoutes.map.name),
                    child: const Icon(Icons.my_location),
                  ),
                ),
                if (userLocationAsync.isLoading)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Chip(
                      avatar: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      label: Text('Locating...'),
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
                leading: Icon(Icons.local_hospital,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(nearest.name),
                subtitle: Text(
                    '${nearest.openNow ? AppLocalizations.of(context)!.openNow : "Closed"} - ${nearest.address}'),
                trailing: FilledButton.tonal(
                  onPressed: () => _openMap(nearest.lat, nearest.lng),
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

  Future<void> _openMap(double lat, double lng) async {
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }
}
