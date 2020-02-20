import 'package:ata/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;
  final Auth _auth;
  User({@required Auth auth}) : _auth = auth;
  Future<bool> checkLocation() async {
    var deviceLocation = await fetchDeviceLocation();
    var locationSetting = await _auth.fetchOfficeSettings();
    final double startLatitude = deviceLocation.longitude;
    final double startLongitude = deviceLocation.latitude;
    final double endLatitude = double.parse(locationSetting['longs']);
    final double endLongitude = double.parse(locationSetting['lats']);
    final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
    if (distance / 1000 < 50.0) {
      return true;
    }
    return false;
  }

  Future<LocationData> fetchDeviceLocation() async {
    try {
      var location = new Location();
      var diviceLocation = await location.getLocation();
      return diviceLocation;
    } catch (error) {
      return error;
    }
  }
}
