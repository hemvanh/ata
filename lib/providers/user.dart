import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util.dart';

enum AttendanceType { In, Out }
enum AttendanceStatus { CheckedIn, CheckedOut, NotCheckIn, NotCheckOut }

class User with ChangeNotifier {
  String _urlReports = "https://atapp-7720c.firebaseio.com/reports/";
  String _idToken; // Firebase ID token of the account.
  String _localId; // The uid of the current user.
  String email;
  String displayName;
  String photoUrl;

  String get currentDateString {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String get urlRecordAttendance {
    return "$_urlReports$_localId/$currentDateString.json?auth=$_idToken";
  }

  Future<Map<String, dynamic>> checkAttendance() async {
    AttendanceStatus status;
    var responseData;
    try {
      var reponseText = await Util.fetch(FetchType.GET, urlRecordAttendance);
      responseData = json.decode(reponseText);
    } catch (error) {
      return {'error': error.toString()};
    }

    if (responseData != null) {
      if (responseData['error'] != null) return {'error': responseData['error']};
      if (responseData['in'] != null) status = AttendanceStatus.CheckedIn;
      if (responseData['out'] != null) status = AttendanceStatus.CheckedOut;
      if (responseData['out'] == null) status = AttendanceStatus.NotCheckOut;
    } else
      status = AttendanceStatus.NotCheckIn;
    return {'result': status};
  }

  Future<String> recordAttendance(AttendanceType attendanceType) async {
    List<bool> lstChecked = await Future.wait([/*checkIP(), checkLocation()*/]);
    if (!lstChecked[0]) return 'Wrong IP';
    if (!lstChecked[1]) return 'Wrong Location';

    final attendanceStatus = await checkAttendance();
    if (attendanceStatus['error'] != null) return attendanceStatus['error'];

    var responseText;
    try {
      switch (attendanceType) {
        case AttendanceType.In:
          if (attendanceStatus['result'] == AttendanceStatus.NotCheckIn) {
            responseText = await Util.fetch(FetchType.PUT, urlRecordAttendance, {
              'in': DateTime.now().toString(),
            });
          } else
            return "Checked In Before !!!";
          break;
        case AttendanceType.Out:
          if (attendanceStatus['result'] == AttendanceStatus.NotCheckOut) {
            responseText = await Util.fetch(FetchType.PATCH, urlRecordAttendance, {
              'out': DateTime.now().toString(),
            });
          } else if (attendanceStatus['result'] == AttendanceStatus.CheckedOut)
            return "Checked Out Before !!!!";
          else
            return "Not Check In !!!";
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
