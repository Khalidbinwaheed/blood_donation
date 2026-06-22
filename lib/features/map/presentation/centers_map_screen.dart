import 'package:blood_donation/features/emergency/data/permission_providers.dart';
import 'package:blood_donation/features/map/data/location_provider.dart';
import 'package:blood_donation/features/map/domain/app_map_marker.dart';
import 'package:blood_donation/features/map/presentation/nearby_places_provider.dart';
import 'package:blood_donation/features/map/presentation/widgets/osm_satellite_map.dart';
import 'package:blood_donation/features/models/place.dart';
import 'package:blood_donation/features/widgets/permission_required_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class CentersMapScreen extends ConsumerWidget {
  const CentersMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(userLocationProvider);
    final placesAsync = ref.watch(nearbyPlacesProvider);
    final permissions = ref.watch(permissionControllerProvider);
    final locationGranted =
        permissions[AppPermissionType.location]?.granted ?? false;

    final current = location.valueOrNull;
    final fallback = const LatLng(34.0123, 71.5678);
    final initial =
        current == null ? fallback : LatLng(current.lat, current.lng);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(nearbyPlacesProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!locationGranted)
            Padding(
              padding: const EdgeInsets.all(12),
              child: PermissionRequiredCard(
                title: 'We need this to help you',
                subtitle: 'Enable location to see nearby hospitals and routes.',
                onOpenSettings: () {
                  ref
                      .read(permissionControllerProvider.notifier)
                      .openSystemSettings();
                },
              ),
            ),
          Expanded(
            child: placesAsync.when(
              data: (places) {
                final markers = places
                    .map(
                      (place) => AppMapMarker(
                        id: place.id,
                        lat: place.lat,
                        lng: place.lng,
                        title: place.name,
                        icon: Icons.local_hospital,
                        color: place.isOpenNow
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFE53935),
                      ),
                    )
                    .toList();

                if (locationGranted && current != null) {
                  markers.insert(
                    0,
                    AppMapMarker(
                      id: 'you',
                      lat: current.lat,
                      lng: current.lng,
                      title: 'You',
                      icon: Icons.my_location,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }

                return Stack(
                  children: [
                    OsmSatelliteMap(
                      center: initial,
                      zoom: 13.2,
                      markers: markers,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _HospitalsList(places: places),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Could not load hospitals: $error'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => ref.invalidate(nearbyPlacesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalsList extends StatelessWidget {
  const _HospitalsList({required this.places});

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No nearby hospitals found.'),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.23,
      minChildSize: 0.12,
      maxChildSize: 0.55,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [
              BoxShadow(blurRadius: 10, color: Colors.black26),
            ],
          ),
          child: ListView.separated(
            controller: controller,
            padding: const EdgeInsets.all(12),
            itemCount: places.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final place = places[index];
              return ListTile(
                leading: Icon(
                  place.isOpenNow ? Icons.check_circle : Icons.cancel,
                  color: place.isOpenNow ? Colors.green : Colors.red,
                ),
                title: Text(place.name),
                subtitle: Text(
                  '${place.distanceKm.toStringAsFixed(1)} km - ${place.isOpenNow ? 'Open now' : 'Closed'}',
                ),
                trailing: IconButton(
                  onPressed: () => _openDirections(place),
                  icon: const Icon(Icons.directions),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openDirections(Place place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.lat},${place.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
