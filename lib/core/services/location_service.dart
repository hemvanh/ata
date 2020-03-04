import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/location.dart';
import 'package:ata/core/services/office_service.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final OfficeService _officeService;

  LocationService(OfficeService officeService) : _officeService = officeService;

  Future<Either<Failure, bool>> checkDistanceLocation(Location deviceLocation, Location officeLocation, double authRange) async {
    final double startLatitude = deviceLocation.lat;
    final double startLongitude = deviceLocation.lng;
    final double endLatitude = officeLocation.lat;
    final double endLongitude = officeLocation.lng;
    final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
    return Right((distance / 1000 <= authRange) ? true : false);
  }

  Future<void> getOfficeLocation() async {
    _officeService.officeSettings.fold((failure) => failure.toString(), (local) {
      Location(lng: local.lon, lat: local.lat);
    });
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
