import 'package:ata/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;
  final Auth auth;
  User({@required this.auth});

  Future<bool> checkLocation() async {
    try {
      var deviceLocation = await fetchDeviceLocation();
      var officeSetting = await auth.fetchOfficeSettings();
      final double startLatitude = double.parse(deviceLocation['longs']);
      final double startLongitude = double.parse(deviceLocation['lats']);
      final double endLatitude = double.parse(officeSetting['longs']);
      final double endLongitude = double.parse(officeSetting['lats']);
      final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
      return (distance / 1000 <= 50.0) ? true : false;
    } catch (error) {
      return false;
    }
  }

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
