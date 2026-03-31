import 'package:geolocator/geolocator.dart';

Future<void> getLocation() async {

  bool serviceEnabled;
  LocationPermission permission;

  // kiểm tra GPS
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return;
  }

  // kiểm tra quyền
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // lấy vị trí
  Position position = await Geolocator.getCurrentPosition();

  print(position.latitude);
  print(position.longitude);
}