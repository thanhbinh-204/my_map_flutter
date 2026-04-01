import 'dart:async';
import '../../api/service/location_search_service.dart';

class LocationSearchController {

  final LocationSearchService searchService = LocationSearchService();

  Timer? debounce;

  Future<List<dynamic>> search(String query) async {
    return await searchService.searchLocation(query);
  }

  void dispose() {
    debounce?.cancel();
  }
}