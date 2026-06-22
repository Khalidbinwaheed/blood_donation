import 'package:blood_donation/features/map/domain/app_map_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// OpenStreetMap street tiles with optional Esri satellite imagery.
class OsmSatelliteMap extends StatefulWidget {
  const OsmSatelliteMap({
    required this.center,
    required this.markers,
    this.zoom = 13,
    this.mapController,
    this.showLayerToggle = true,
    this.showAttribution = true,
    this.interactive = true,
    super.key,
  });

  final LatLng center;
  final List<AppMapMarker> markers;
  final double zoom;
  final MapController? mapController;
  final bool showLayerToggle;
  final bool showAttribution;
  final bool interactive;

  @override
  State<OsmSatelliteMap> createState() => _OsmSatelliteMapState();
}

class _OsmSatelliteMapState extends State<OsmSatelliteMap> {
  late final MapController _controller;
  late AppMapLayer _layer;

  @override
  void initState() {
    super.initState();
    _controller = widget.mapController ?? MapController();
    _layer = AppMapLayer.street;
  }

  @override
  void didUpdateWidget(covariant OsmSatelliteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center) {
      _controller.move(widget.center, widget.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: widget.zoom,
            interactionOptions: InteractionOptions(
              flags: widget.interactive ? InteractiveFlag.all : InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _layer == AppMapLayer.street
                  ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                  : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.example.blood_donation',
              maxZoom: 19,
            ),
            if (_layer == AppMapLayer.satellite)
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.blood_donation',
                maxZoom: 19,
              ),
            MarkerLayer(
              markers: widget.markers
                  .map(
                    (marker) => Marker(
                      point: LatLng(marker.lat, marker.lng),
                      width: 42,
                      height: 42,
                      child: Tooltip(
                        message: marker.title ?? '',
                        child: Icon(
                          marker.icon,
                          color: marker.color,
                          size: 34,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (widget.showAttribution)
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                attributions: [
                  TextSourceAttribution(
                    'Leaflet',
                    onTap: () => launchUrl(
                      Uri.parse('https://leafletjs.com'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  TextSourceAttribution(
                    'OpenStreetMap',
                    onTap: () => launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  if (_layer == AppMapLayer.satellite)
                    const TextSourceAttribution('Esri'),
                ],
              ),
          ],
        ),
        if (widget.showLayerToggle)
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LayerChip(
                      label: 'Map',
                      icon: Icons.map_outlined,
                      selected: _layer == AppMapLayer.street,
                      onTap: () => setState(() => _layer = AppMapLayer.street),
                    ),
                    _LayerChip(
                      label: 'Satellite',
                      icon: Icons.satellite_alt_outlined,
                      selected: _layer == AppMapLayer.satellite,
                      onTap: () =>
                          setState(() => _layer = AppMapLayer.satellite),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
