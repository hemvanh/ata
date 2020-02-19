import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../util.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;

  Future<bool> checkLocation() async {
    try {
      var responseData = await getDeviceLocation();
      var reponseText = await fetchOfficeLocationSetting();

      var jsonStr = json.decode(reponseText);
      final double startLatitude = responseData['lon'];
      final double startLongitude = responseData['lat'];
      final double endLatitude = double.parse(jsonStr['location']['longs']);
      final double endLongitude = double.parse(jsonStr['location']['lats']);
      final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
      if (distance / 1000 < 50.0) {
        return true;
      }
    } catch (error) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDeviceLocation() async {
    try {
      var responseText = await Util.fetch(FetchType.GET, 'http://ip-api.com/json');
      final responseData = json.decode(responseText) as Map<String, dynamic>;
      return responseData;
    } catch (error) {
      return {'error': error};
    }
  }

  Future<dynamic> fetchOfficeLocationSetting() async {
    final officeUrl = 'https://attendance-record-522c8.firebaseio.com/office.json?auth=$_idToken';
    var reponseText = await Util.fetch(FetchType.GET, officeUrl);

    return json.decode(reponseText);
  }
}
