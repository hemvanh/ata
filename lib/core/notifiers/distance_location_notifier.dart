import 'package:ata/core/notifiers/base_notifier.dart';
import 'package:ata/core/notifiers/office_settings_notifier.dart';
import 'package:ata/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class DistanceLocationNotifier extends BaseNotifier {
  final LocationServide _locationServide;
  final OfficeSettingsNotifier _officeSetting;
  DistanceLocationNotifier(LocationServide locationServide, OfficeSettingsNotifier officeSetting)
      : _locationServide = locationServide,
        _officeSetting = officeSetting;

  Future<bool> checkDistanceLocation() async {
    try {
      var deviceLocation = await _locationServide.fetchDeviceLocation();
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
}
