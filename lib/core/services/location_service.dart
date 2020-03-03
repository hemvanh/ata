import 'package:geolocator/geolocator.dart';

class LocationServide {
  Future<Map<String, dynamic>> fetchDeviceLocation() async {
    bool isEnabled = await Geolocator().isLocationServiceEnabled();
    if (isEnabled) {
      try {
        var deviceLocation = await Geolocator().getCurrentPosition();
        return {
          'longs': deviceLocation.longitude.toString(),
          'lats': deviceLocation.latitude.toString(),
        };
      } catch (error) {
        return {'error': error.message};
      }
    } else {
      return {'error': 'Location settings are inadequate, check your location settings'};
    }
  }
}
