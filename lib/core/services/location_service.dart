import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/location.dart';
import 'package:ata/core/models/office.dart';
import 'package:ata/core/notifiers/office_settings_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final Office _officeSetting;
  //final Either<Failure, Office> _officeSetting;
  //final Either<Failure, Location> _officeService;
  //final Location _getLocation;
  LocationService(Office officeSetting) : _officeSetting = officeSetting;
  // double get officeLat {
  //   return _officeSetting.fold(
  //     (failure) => throw failure,
  //     (office) => office.lat,
  //   );
  // }
  Future<bool> checkDistanceLocation() async {
    try {
      return (await fetchDeviceLocation()).fold((failure) => throw failure.toString(), (location) async {
        final double startLatitude = location.lat;
        final double startLongitude = location.long;
        final double endLatitude = _officeSetting.lat;
        final double endLongitude = _officeSetting.lon;
        final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
        return (distance / 1000 <= 50.0) ? true : false;
      });
    } catch (error) {
      return throw error.toString();
    }
  }

  // Either<Failure, Location> _locationDevice;
  //Either<Failure, Location> get locationDevice => _locationDevice;

  Future<Either<Failure, Location>> fetchDeviceLocation() async {
    bool isEnabled = await Geolocator().isLocationServiceEnabled();
    if (isEnabled) {
      try {
        var device = await Geolocator().getCurrentPosition();
        return Right(Location(lat: device.latitude, long: device.longitude));
      } catch (failure) {
        return Left(failure);
      }
    } else {
      return Left(Failure('Location settings are inadequate, check your location settings'));
    }
  }
}
