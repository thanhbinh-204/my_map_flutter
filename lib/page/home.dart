import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../component/widget/search_suggestion_list.dart';
import '../component/widget/bottom_place_card.dart';
import '../component/widget/map_widget.dart';
import '../component/widget/search_bar.dart';
import '../component/controller/search_controller.dart';
import '../api/service/location_service.dart';
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
  final LocationSearchController searchControllerLogic =
      LocationSearchController();
  List<dynamic> searchResults = [];
  // khai báo tạo biến lưu card thông tin
  // địa điểm search
  Map<String, dynamic>? selectedPlace;
  // chỉ đường
  final RouteService routeService = RouteService();
  List<LatLng> routePoints = [];
  // thêm biến làm chức năng distance & duration
  double? routeDistance;
  double? routeDuration;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchControllerLogic.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    final location = await LocationService.getCurrentLocation();

    if (location == null) return;

    setState(() {
      currentLocation = location;
    });

    mapController.move(location, 16);
  }

  // hàm search
  Future<void> searchLocation(String query) async {
    final results = await searchControllerLogic.search(query);

    setState(() {
      searchResults = results;
    });
  }

  // hàm lấy route
  Future<void> getRoute() async {
    if (currentLocation == null || searchedLocation == null) return;

    final result = await routeService.getRoute(
      currentLocation!,
      searchedLocation!,
    );

    if (result == null) {
      print("Route not found");
      return;
    }

    setState(() {
      routePoints = result.points;
      routeDistance = result.distance;
      routeDuration = result.duration;
    });
  }

  String formatDistance(double meters) {
    return "${(meters / 1000).toStringAsFixed(1)} km";
  }

  String formatDuration(double second) {
    return "${(second / 60).round()} phút";
  }

  // reset search
  void clearSearch() {
    FocusScope.of(context).unfocus(); // ẩn bàn phím khi chạm

    setState(() {
      searchController.clear();
      searchResults = []; // reset search
      selectedPlace = null; // ẩn bottom place card
      searchedLocation = null; // xóa marker search
      // xóa route chỉ đường khi nhấn close
      routePoints = [];
      routeDistance = null;
      routeDuration = null;
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
          MapWidget(
            mapController: mapController,
            currentLocation: currentLocation!,
            searchedLocation: searchedLocation,
            routePoints: routePoints,
            onTap: () {
              FocusScope.of(context).unfocus(); // khi chạm thì ẩn bàn phím
            },
          ),

          // search bar
          Positioned(
            top: size.height * 0.06,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: SearchBarWidget(
              controller: searchController,
              onClear: clearSearch,
              onChanged: (value) {
                if (searchControllerLogic.debounce?.isActive ?? false) {
                  searchControllerLogic.debounce!.cancel();
                }

                searchControllerLogic.debounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (value.isNotEmpty) {
                      searchLocation(value);
                    } else {
                      setState(() {
                        searchResults = [];
                      });
                    }
                  },
                );
              },
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

                  FocusScope.of(context).unfocus(); // ẩn bàn phím
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
                distance: routeDistance,
                duration: routeDuration,
                place: selectedPlace!,
                onDirection: getRoute,
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
