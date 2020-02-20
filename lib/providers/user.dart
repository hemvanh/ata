import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import '../util.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;

  Future<bool> checkLocation() async {
    try {
      var deviceLocation = await fetchDeviceLocation();
      var locationSetting = await fetchOfficeLocationSetting();

      final double startLatitude = deviceLocation.longitude;
      final double startLongitude = deviceLocation.latitude;
      final double endLatitude = double.parse(locationSetting['location']['longs']);
      final double endLongitude = double.parse(locationSetting['location']['lats']);
      final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
      if (distance / 1000 < 50.0) {
        return true;
      }
    } catch (error) {
      return false;
    }
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

  Future<dynamic> fetchOfficeLocationSetting() async {
    final officeUrl = 'https://atapp-7720c.firebaseio.com/office.json?auth=$_idToken';
    var reponseText = await Util.fetch(FetchType.GET, officeUrl);
    return json.decode(reponseText);
  }
}
