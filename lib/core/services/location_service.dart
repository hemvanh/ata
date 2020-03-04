import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/location.dart';
import 'package:ata/core/models/office.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final Office _officeSetting;

  LocationService(Office officeSetting) : _officeSetting = officeSetting;

  Future<bool> checkDistanceLocation() async {
    try {
      return (await fetchDeviceLocation()).fold((failure) => throw failure.toString(), (location) async {
        final double startLatitude = location.lat;
        final double startLongitude = location.lng;
        final double endLatitude = _officeSetting.lat;
        final double endLongitude = _officeSetting.lon;
        final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
        return (distance / 1000 <= _officeSetting.authRange) ? true : false;
      });
    } catch (error) {
      return throw error.toString();
    }
  }

  Future<Either<Failure, Location>> fetchDeviceLocation() async {
    bool isEnabled = await Geolocator().isLocationServiceEnabled();
    if (isEnabled) {
      try {
        var device = await Geolocator().getCurrentPosition();
        return Right(Location(lat: device.latitude, lng: device.longitude));
      } catch (failure) {
        return Left(failure);
      }
    } else {
      return Left(Failure('Location settings are inadequate, check your location settings'));
    }
  }
}
