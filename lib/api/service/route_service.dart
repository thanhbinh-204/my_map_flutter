import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {

  Future<List<LatLng>> getRoute(
      LatLng start,
      LatLng end,
      ) async {

    final url =
        "https://router.project-osrm.org/route/v1/driving/"
        "${start.longitude},${start.latitude};"
        "${end.longitude},${end.latitude}"
        "?overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return [];
    }

    final data = json.decode(response.body);

    // kiểm tra routes
    if (data['routes'] == null || data['routes'].isEmpty) {
      print("No route found");
      return [];
    }

    final coordinates =
        data['routes'][0]['geometry']['coordinates'];

    List<LatLng> points = coordinates.map<LatLng>((coord) {
      return LatLng(coord[1], coord[0]);
    }).toList();

    return points;
  }
}