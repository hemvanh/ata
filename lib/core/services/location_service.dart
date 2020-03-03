import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/location.dart';
import 'package:ata/core/notifiers/office_settings_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';



class LocationServide {
  final OfficeSettingsNotifier _officeSetting;
  LocationServide(OfficeSettingsNotifier officeSetting) : _officeSetting = officeSetting;

  Future<bool> checkDistanceLocation() async {
    try {
      var deviceLocation = await fetchDeviceLocation();
      final double startLatitude = double.parse(deviceLocation['lats']);
      final double startLongitude = double.parse(deviceLocation['longs']);
      final double endLatitude = double.parse(_officeSetting.officeLat);
      final double endLongitude = double.parse(_officeSetting.officeLon);
      final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
      return (distance / 1000 <= double.parse(_officeSetting.authRange)) ? true : false;
    } catch (error) {
      return false;
    }
  }
 Either<Failure, Location> _locationDevice;
 Either<Failure, Location> get locationDevice => _locationDevice;
   void _setLocation(Either<Failure, Location> locationDevice) {
    _locationDevice = locationDevice;
  }
  Future<Map<String, dynamic>> fetchDeviceLocation() async {
    bool isEnabled = await Geolocator().isLocationServiceEnabled();
    if (isEnabled) {
      try {
        var deviceLocation = await Geolocator().getCurrentPosition();
        return {
          'Long': deviceLocation.longitude.toString(),
          'Lat': deviceLocation.latitude.toString(),
        };
      } catch (error) {
        return {'error': error.message};
      }
    } else {
      return {'error': 'Location settings are inadequate, check your location settings'};
    }
  }
}
