import 'package:flutter/foundation.dart';

class Location {
  double long;
  double lat;

  Location({
    @required this.long,
    @required this.lat,
  });

  factory Location.fromJson(Map<String, dynamic> parsedJson) {
    return Location(
      long: parsedJson['long'],
      lat: parsedJson['lat'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'long': this.long,
      'lat': this.lat,
    };
  }
}
