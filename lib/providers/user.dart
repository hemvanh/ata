import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util.dart';

enum AttendanceType { In, Out }

class User with ChangeNotifier {
  String _urlReports = "https://attendance-dcecd.firebaseio.com/reports/";
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;

  Future<dynamic> checkAttendance() async {
    DateFormat formattedDate = DateFormat('yyyy-MM-dd');
    String currentDate = formattedDate.format(DateTime.now());
    String urlCheckAttendance = "$_urlReports$_localId/$currentDate.json?auth=$_idToken";
    var reponseCheckText = await Util.fetch(FetchType.GET, urlCheckAttendance);
    final responseData = json.decode(reponseCheckText);
    return responseData;
  }

  Future<String> recordAttendance(AttendanceType attendanceType) async {
    DateFormat formattedDate = DateFormat('yyyy-MM-dd');
    String currentDate = formattedDate.format(DateTime.now());
    String urlReports = "$_urlReports$_localId/$currentDate.json?auth=$_idToken";

    List<bool> lstChecked = await Future.wait([/*checkIP(),checkLocation*/]);
    bool allCheckedTrue = lstChecked.contains(false);

    if (allCheckedTrue) {
      if (!lstChecked[0]) return 'Wrong IP';
      return 'Wrong Location';
    }

    final checkAttendanceData = await checkAttendance();
    if (checkAttendanceData != null) {
      if (checkAttendanceData['error'] != null) return checkAttendanceData['error'];
    }

    var responseText;
    try {
      switch (attendanceType) {
        case AttendanceType.In:
          if (checkAttendanceData == null) {
            responseText = await Util.fetch(FetchType.PUT, urlReports, {
              'in': DateTime.now().toString(),
            });
          } else {
            responseText = "{\"error\": \"Checked In Before !!!\"}";
          }

          break;
        case AttendanceType.Out:
          if (checkAttendanceData != null && checkAttendanceData['out'] == null) {
            responseText = await Util.fetch(FetchType.PATCH, urlReports, {
              'out': DateTime.now().toString(),
            });
          } else if (checkAttendanceData['out'] != null)
            responseText = "{\"error\": \"Checked Out Before !!!!\"}";
          else
            responseText = "{\"error\": \"Not Check In !!!\"}";
          break;
      }

      final responseData = json.decode(responseText);
      if (responseData['error'] != null) return responseData['error'];

      return null;
    } catch (error) {
      return error.toString();
    }
  }
}
