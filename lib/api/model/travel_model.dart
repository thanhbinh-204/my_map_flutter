enum TravelMode {
  car,
  motorbike,
  bike,
  walk,
}

extension TravelModeExtension on TravelMode {
  String get apiMode {
    switch (this) {
      case TravelMode.car:
        return "driving";
      case TravelMode.motorbike:
        return "driving";
      case TravelMode.bike:
        return "cycling";
      case TravelMode.walk:
        return "foot";
    }
  }
}