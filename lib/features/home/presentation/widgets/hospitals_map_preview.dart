import 'package:blood_donation/core/router/app_routes.dart';
import 'package:blood_donation/features/models/place.dart';
import 'package:blood_donation/features/map/presentation/nearby_places_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HospitalsMapPreview extends ConsumerWidget {
  const HospitalsMapPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(nearbyPlacesProvider);

    return Card(
      key: const Key('map_preview'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Nearby Hospitals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.pushNamed(AppRoutes.map.name),
                  child: const Text('View full map'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 190,
              child: placesAsync.when(
                data: (places) {
                  if (places.isEmpty) {
                    return const Center(
                      child: Text('No nearby hospitals available.'),
                    );
                  }
                  final top = places.take(3).toList();
                  return _SafeMapPreviewPanel(top: top);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                  child: Text('Unable to load map data.'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeMapPreviewPanel extends StatelessWidget {
  const _SafeMapPreviewPanel({required this.top});

  final List<Place> top;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live nearby hospitals',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...top.map((place) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    leading: Icon(
                      place.isOpenNow
                          ? Icons.local_hospital
                          : Icons.local_hospital_outlined,
                      color: place.isOpenNow ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${place.distanceKm.toStringAsFixed(1)} km - ${place.isOpenNow ? 'Open now' : 'Closed'}',
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
