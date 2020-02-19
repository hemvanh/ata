import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../util.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;

  Future<Map<String, dynamic>> getDeviceIP() async {
    try {
      var responseDeviceIP = await Util.fetch(FetchType.GET, 'http://ip-api.com/json');
      final responseData = json.decode(responseDeviceIP) as Map<String, dynamic>;
      return responseData;
    } catch (error) {
      return {'error': error};
    }
  }

  Future<Map<String, dynamic>> getOfficeIP() async {
    try {
      var responseOfficeIP = await Util.fetch(FetchType.GET, 'https://ata-et-92453.firebaseio.com/office.json?auth=$_idToken');
      final responseData = json.decode(responseOfficeIP) as Map<String, dynamic>;
      return responseData;
    } catch (error) {
      return {'error': error};
    }
  }

  Future<bool> checkIP() async {
    try {
      var deviceIP = await getDeviceIP();
      var officeIP = await getOfficeIP();
      if (deviceIP.values.last == officeIP.values.first) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }
}
