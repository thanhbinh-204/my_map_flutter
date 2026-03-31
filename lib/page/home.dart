import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../component/widget/search_suggestion_list.dart';
import '../api/service/location_search_service.dart';
import '../component/widget/bottom_place_card.dart';
import '../api/service/route_service.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? currentLocation;
  // maker tại điểm search
  LatLng? searchedLocation;
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  // khai báo search
  final LocationSearchService searchService = LocationSearchService();
  List<dynamic> searchResults = [];
  Timer? debounce;

  // khai báo tạo biến lưu card thông tin
  // địa điểm search
  Map<String, dynamic>? selectedPlace;

  // chỉ đường
  RouteService routeService = RouteService();
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    LatLng location = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLocation = location;
    });

    mapController.move(location, 16);
  }

  // hàm search
  Future<void> searchLocation(String query) async {
    try {
      final results = await searchService.searchLocation(query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print(e);
    }
  }

  // hàm lấy route
  Future<void> getRoute() async {
    if (currentLocation == null || searchedLocation == null) return;
    final points = await routeService.getRoute(
      currentLocation!,
      searchedLocation!,
    );
    setState(() {
      routePoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    //responsive
    final size = MediaQuery.of(context).size;

    //hiển thị load để chờ lấy vị trí từ thiết bị
    if (currentLocation == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,

            // chọn hiển thị ví trí hiện tại khi bắt đầu
            // hoặc có thể hiển thị ví trị theo tòa độ tùy chỉnh
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 13,
            ),

            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.map_app",
              ),

              MarkerLayer(
                markers: [
                  // marker vị trí hiện tại
                  if (currentLocation != null)
                    Marker(
                      point: currentLocation!,
                      width: size.width * 0.15,
                      height: size.width * 0.15,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: size.width * 0.12,
                      ),
                    ),

                  // marker địa điểm search
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
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),

          // search bar
          Positioned(
            top: size.height * 0.06,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: 10,
              ),
              // height: size.height * 0.08,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Search Location...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: size.width * 0.05,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon:
                            searchController.text.isNotEmpty
                                ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      searchController.clear();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    size: size.width * 0.05,
                                  ),
                                )
                                : null,
                      ),
                      onChanged: (value) {
                        if (debounce?.isActive ?? false) debounce!.cancel();
                        debounce = Timer(const Duration(milliseconds: 500), () {
                          if (value.isNotEmpty) {
                            searchLocation(value);
                          } else {
                            setState(() {
                              searchResults = [];
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // hiển thị search
          if (searchResults.isNotEmpty)
            Positioned(
              top: size.height * 0.12,
              left: size.width * 0.05,
              right: size.width * 0.05,
              child: SearchSuggestionList(
                results: searchResults,
                onSelect: (place) {
                  double lat = double.parse(place['lat']);
                  double lon = double.parse(place['lon']);

                  LatLng location = LatLng(lat, lon);
                  mapController.move(location, 16);

                  setState(() {
                    searchedLocation = location; // lưu maker search
                    selectedPlace = place; // lưu thông tin card search
                    searchResults = [];
                    searchController.text = place['display_name'];
                  });
                },
              ),
            ),

          // bottom place card
          if (selectedPlace != null)
            Positioned(
              bottom: size.height * 0.12,
              left: size.width * 0.04,
              right: size.width * 0.04,
              child: BottomPlaceCard(
                place: selectedPlace!,
                onDirection: () {
                  getRoute();
                },
                onClose: () {
                  setState(() {
                    selectedPlace = null;
                    routePoints = [];
                  });
                },
              ),
            ),

          // locate me ( dẫn về vị trí hiện tại)
          Positioned(
            bottom: size.height * 0.04,
            right: size.width * 0.05,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              mini: true,
              onPressed: () {
                if (currentLocation != null) {
                  mapController.move(currentLocation!, 16);
                  setState(() {
                    searchedLocation = null;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Icon(Icons.my_location, size: size.width * 0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
