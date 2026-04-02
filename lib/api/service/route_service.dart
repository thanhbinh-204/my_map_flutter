import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../model/travel_model.dart';

class RouteResultModel {
  final List<LatLng> points;
  final double distance;
  final double duration;

  const RouteResultModel({
    required this.points,
    required this.distance,
    required this.duration,
  });
}

class RouteService {
  Future<List<RouteResultModel>?> getRoute(
    LatLng start,
    LatLng end,
    TravelMode mode,
  ) async {
    final url = _buildRouteUrl(start, end, mode);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      print("Route API error: ${response.statusCode}");
      return null;
    }

    final data = json.decode(response.body);

    if (data['routes'] == null || data['routes'].isEmpty) {
      print("No route found");
      return null;
    }

    final routes = data['routes'];

    List<RouteResultModel> results = [];

    for (var route in routes) {
      final points = _parseRoutePoints(route);

      final distance = route['distance'].toDouble();

      final duration = _calculateDuration(distance, mode);

      results.add(
        RouteResultModel(
          points: points,
          distance: distance,
          duration: duration,
        ),
      );
    }

    return results;
  }

  String _buildRouteUrl(LatLng start, LatLng end, TravelMode mode) {
    return "https://router.project-osrm.org/route/v1/${mode.apiMode}/"
        "${start.longitude},${start.latitude};"
        "${end.longitude},${end.latitude}"
        "?overview=full&geometries=geojson&alternatives=true";
  }

  List<LatLng> _parseRoutePoints(dynamic route) {
    final coordinates = route['geometry']['coordinates'];

    return coordinates
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();
  }

  // sử dụng tốc độ trung bình của phương tiện để tính thời gian đi
  // vì api không thực sự tính nên phải làm vậy :))
  double _calculateDuration(double distanceMeter, TravelMode mode) {
    double speedKmH;

    switch (mode) {
      case TravelMode.car:
        speedKmH = 40;
        break;

      case TravelMode.motorbike:
        speedKmH = 35;
        break;

      case TravelMode.bike:
        speedKmH = 15;
        break;

      case TravelMode.walk:
        speedKmH = 5;
        break;
    }

    final distanceKm = distanceMeter / 1000;

    return (distanceKm / speedKmH) * 3600;
  }
}
