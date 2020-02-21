import 'dart:async';
import 'dart:convert';
import 'package:ata/util.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthType { SignUp, SignIn }

class Auth with ChangeNotifier {
  final _apiKey = 'AIzaSyCfrk-pANuYEeE3Npr87FEyyk8TwH6jJ5s';
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  DateTime _expiryDate;

  String _getUrl(AuthType authType) {
    String firebaseAuthType;
    switch (authType) {
      case AuthType.SignUp:
        firebaseAuthType = 'signUp';
        break;
      case AuthType.SignIn:
        firebaseAuthType = 'signInWithPassword';
        break;
    }
    return 'https://identitytoolkit.googleapis.com/v1/accounts:$firebaseAuthType?key=$_apiKey';
  }

  bool get isAuth {
    return _idToken != null;
  }

  Future<String> authenticate(String email, String password, AuthType authType) async {
    // Requesting to Firebase
    try {
      var reponseText = await Util.fetch(FetchType.POST, _getUrl(authType), {
        'email': email,
        'password': password,
        'returnSecureToken': true,
      });

      final responseData = json.decode(reponseText);
      if (responseData['error'] != null) return responseData['error']['message'];

      // Setting login data
      _idToken = responseData['idToken'];
      _localId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      // Saving to shared prefs
      final prefs = await SharedPreferences.getInstance();
      final loginDataJson = json.encode({
        'token': _idToken,
        'localId': _localId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('loginData', loginDataJson);

      // Updating UI
      notifyListeners();
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> signOut() async {
    _idToken = null;
    _expiryDate = null;
    _localId = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  Future<bool> autoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 1), null);
    if (!prefs.containsKey('loginData')) return false;

    final loginData = json.decode(prefs.getString('loginData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(loginData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) return false;
    _idToken = loginData['token'];
    _localId = loginData['localId'];
    _expiryDate = expiryDate;
    return true;
  }

  // Admin features

  Future<void> updateOfficeSettings(String ipAddress, String longs, String lats) async {
    final officeUrl = 'https://atapp-7720c.firebaseio.com/office.json?auth=$_idToken';

    var reponseText = await Util.fetch(FetchType.PUT, officeUrl, {
      'ip': ipAddress,
      'location': {
        'longs': longs,
        'lats': lats,
      },
    });

    print(reponseText);
  }

  Future<dynamic> fetchOfficeSettings() async {
    final officeUrl = 'https://atapp-7720c.firebaseio.com/office.json?auth=$_idToken';
    var reponseText = await Util.fetch(FetchType.GET, officeUrl);

    return json.decode(reponseText);
  }

  Future<bool> checkLocation() async {
    try {
      var deviceLocation = await fetchDeviceLocation();
      var officeSetting = await fetchOfficeSettings();
      // final double startLatitude = deviceLocation;
      // final double startLongitude = deviceLocation.latitude;
      final double endLatitude = double.parse(officeSetting['location']['longs']);
      final double endLongitude = double.parse(officeSetting['location']['lats']);
      //final double distance = await Geolocator().distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
      // return (distance / 1000 <= 50.0) ? true : false;
    } catch (error) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchDeviceLocation() async {
    bool isEnabled = await Geolocator().isLocationServiceEnabled();
    if (isEnabled) {
      try {
        var deviceLocation = await Geolocator().getCurrentPosition();
        return {'result': deviceLocation.latitude.toString(),
        'result2': deviceLocation.latitude.toString(),};
      } catch (error) {
        return {'error': error.message};
      }
    } else {
      return {'error': 'Location settings are inadequate, check your location settings'};
    }
  }
}
