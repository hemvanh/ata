import 'package:flutter/material.dart';

import 'package:ata/providers/auth.dart';

import 'package:ata/util.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;
  final Auth auth;
  User({@required this.auth});
  Future<String> getDeviceIP() async {
    var responseData = await Util.fetchDeviceIP();
    return responseData['result'];
  }

  Future<dynamic> getOfficeIP() async {
    try {
      var responseData = await auth.fetchOfficeSettings();
      return responseData['ip'];
    } catch (error) {
      return {'error': error.toString()}; // Auth token is expired
    }
  }

  Future<bool> checkIP() async {
    List responseData = await Future.wait([getDeviceIP(), getOfficeIP()]);
    if (responseData[0] == responseData[1]) {
      // Compare two string in Array
      return responseData[0] == responseData[1];
    } else {
      return false;
    }
  }
}
