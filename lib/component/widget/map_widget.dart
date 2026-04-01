import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final LatLng? searchedLocation;
  final List<LatLng> routePoints;
  final Function() onTap;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentLocation,
    required this.searchedLocation,
    required this.routePoints,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 13,
        onTap: (_, __) => onTap(),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.example.map_app",
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: currentLocation,
              width: size.width * 0.15,
              height: size.width * 0.15,
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: size.width * 0.12,
              ),
            ),

            if (searchedLocation != null)
              Marker(
                point: searchedLocation!,
                width: size.width * 0.15,
                height: size.width * 0.15,
                child: Icon(
                  Icons.place,
                  color: Colors.blue,
                  size: size.width * 0.11,
                ),
              ),
          ],
        ),

        PolylineLayer(
          polylines: [
            Polyline(points: routePoints, strokeWidth: 5, color: Colors.blue),
          ],
        ),
      ],
    );
  }
}
