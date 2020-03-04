import 'package:flutter/foundation.dart';

class Location {
  double lng;
  double lat;

  Location({
    @required this.lng,
    @required this.lat,
  });

  factory Location.fromJson(Map<String, dynamic> parsedJson) {
    return Location(
      lng: parsedJson['lng'],
      lat: parsedJson['lat'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'lng': this.lng,
      'lat': this.lat,
    };
  }
}
