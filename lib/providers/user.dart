import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util.dart';

enum AttendanceType { In, Out }
enum AttendanceStatus { CheckedIn, CheckedOut, NotCheckIn, NotCheckOut }

class User with ChangeNotifier {
  String _urlReports = "https://attendance-dcecd.firebaseio.com/reports/";
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

  Future<AttendanceStatus> checkAttendance() async {
    AttendanceStatus message;
    var reponseCheckText = await Util.fetch(FetchType.GET, urlRecordAttendance);
    final responseData = json.decode(reponseCheckText);
    if (responseData != null) {
      if (responseData['error'] != null) throw (responseData['error']);

      if (responseData['in'] != null) message = AttendanceStatus.CheckedIn;
      if (responseData['out'] != null) message = AttendanceStatus.CheckedOut;
      if (responseData['out'] == null) message = AttendanceStatus.NotCheckOut;
    } else
      message = AttendanceStatus.NotCheckIn;
    return message;
  }

  Future<String> recordAttendance(AttendanceType attendanceType) async {
    try {
      List<bool> lstChecked = await Future.wait([/*checkIP(), checkLocation()*/]);
      if (!lstChecked[0]) return 'Wrong IP';
      if (!lstChecked[1]) return 'Wrong Location';

      final attendanceMsg = await checkAttendance();
      var responseText;

      switch (attendanceType) {
        case AttendanceType.In:
          if (attendanceMsg == AttendanceStatus.NotCheckIn) {
            responseText = await Util.fetch(FetchType.PUT, urlRecordAttendance, {
              'in': DateTime.now().toString(),
            });
          } else {
            responseText = "{\"error\": \"Checked In Before !!!\"}";
          }
          break;
        case AttendanceType.Out:
          if (attendanceMsg == AttendanceStatus.NotCheckOut) {
            responseText = await Util.fetch(FetchType.PATCH, urlRecordAttendance, {
              'out': DateTime.now().toString(),
            });
          } else if (attendanceMsg == AttendanceStatus.CheckedOut)
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
