import 'dart:async';
import 'dart:convert';
import 'package:ata/providers/auth.dart';
import 'package:ata/util.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;
  final Auth _auth;
  User({@required Auth auth}) : _auth = auth;
  Future<String> getDeviceIP() async {
    var responseText = await Util.fetch(FetchType.GET, 'http://ip-api.com/json');
    final responseData = json.decode(responseText);
    return responseData['query'];
  }

  Future<String> getOfficeIP() async {
    var responseData = await _auth.fetchOfficeSettings();
    return responseData['ip'];
  }


  Future<bool> checkIP() async {
    var deviceIP = await getDeviceIP();
    var officeIP = await getOfficeIP();
    if (deviceIP == officeIP) {
      return true;
    } else {
      return false;
    }
  }
}
