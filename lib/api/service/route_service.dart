import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResultModel {
  final List<LatLng> points;
  final double distance;
  final double duration;

  RouteResultModel({
    required this.points,
    required this.distance,
    required this.duration,
  });
}

class RouteService {
  Future<RouteResultModel?> getRoute(LatLng start, LatLng end) async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/"
        "${start.longitude},${start.latitude};"
        "${end.longitude},${end.latitude}"
        "?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    // kiểm tra API
    if (response.statusCode != 200) {
      print("API error");
      return null;
    }

    final data = json.decode(response.body);

    // kiểm tra route
    if (data['routes'] == null || data['routes'].isEmpty) {
      print("No route found");
      return null;
    }

    final route = data['routes'][0];

    final coordinates = route['geometry']['coordinates'];

    List<LatLng> points =
        coordinates.map<LatLng>((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();

    return RouteResultModel(
      points: points,
      distance: route['distance'].toDouble(),
      duration: route['duration'].toDouble(),
    );
  }
}
