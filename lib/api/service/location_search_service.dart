import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSearchService {
  Future<List<dynamic>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5"
    );
    final response = await http.get(
      url,
      headers: {"User-Agent" : "flutter_map_app"},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    return [];
  }
}