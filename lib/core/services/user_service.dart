import 'package:ata/core/models/auth.dart';
import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/user.dart';
import 'package:ata/factories.dart';
import 'package:ata/util.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

enum AttendanceStatus { CheckedIn, CheckedOut, NotYetCheckedIn, NotYetCheckedOut }
enum UserType { Get, Update }

class UserService {
  String _urlReports = "https://attendance-dcecd.firebaseio.com/reports";
  Either<Failure, Auth> _auth;
  UserService(Either<Failure, Auth> auth) : _auth = auth;

  String get _localId {
    return _auth.fold((failure) => throw (failure.toString()), (auth) => auth.localId);
  }

  String get _idToken {
    return _auth.fold((failure) => throw (failure.toString()), (auth) => auth.idToken);
  }

  String get currentDateString {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String get urlRecordAttendance {
    return "$_urlReports/$_localId/$currentDateString.json?auth=$_idToken";
  }

  String get _apiKey {
    return Auth.apiKey;
  }

  String _getUrlUser(UserType userType) {
    switch (userType) {
      case UserType.Get:
        return "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey";
      default:
        return "https://identitytoolkit.googleapis.com/v1/accounts:update?key=$_apiKey";
    }
  }

  Future<Either<Failure, AttendanceStatus>> getAttendanceStatus() async {
    AttendanceStatus status;
    var responseData;
    try {
      responseData = await Util.request(RequestType.GET, urlRecordAttendance);
    } catch (failure) {
      return Left(failure);
    }

    if (responseData != null) {
      if (responseData['error'] != null) return Left(Failure(responseData['error']));
      if (responseData['in'] != null) status = AttendanceStatus.CheckedIn;
      if (responseData['out'] != null)
        status = AttendanceStatus.CheckedOut;
      else
        status = AttendanceStatus.NotYetCheckedOut;
    } else
      status = AttendanceStatus.NotYetCheckedIn;
    return Right(status);
  }

  Future<String> checkLocationIP() async {
    List<bool> lstChecked = await Future.wait([/*checkIP(), checkLocation()*/]);
    if (!lstChecked[0]) return 'Wrong IP !!!';
    if (!lstChecked[1]) return 'Wrong Location !!!';
    return null;
  }

  Future<String> checkIn() async {
    String checkMsg = await checkLocationIP();
    if (checkMsg != null) return checkMsg;

    return (await getAttendanceStatus()).fold(
      (failure) => failure.toString(),
      (attendanceStatus) async {
        try {
          var responseData;
          switch (attendanceStatus) {
            case AttendanceStatus.NotYetCheckedIn:
              responseData = await Util.request(RequestType.PUT, urlRecordAttendance, {
                'in': DateTime.now().toIso8601String(),
              });
              return responseData['error'] != null ? responseData['error'] : null;
            default:
              return "Already Checked In Before !!!";
          }
        } catch (error) {
          return error.toString();
        }
      },
    );
  }

  Future<String> checkOut() async {
    String checkMsg = await checkLocationIP();
    if (checkMsg != null) return checkMsg;

    return (await getAttendanceStatus()).fold(
      (failure) => failure.toString(),
      (attendanceStatus) async {
        try {
          var responseData;
          switch (attendanceStatus) {
            case AttendanceStatus.NotYetCheckedOut:
              responseData = await Util.request(RequestType.PATCH, urlRecordAttendance, {
                'out': DateTime.now().toIso8601String(),
              });
              return responseData['error'] != null ? responseData['error'] : null;
            case AttendanceStatus.CheckedOut:
              return "Already Checked Out Before !!!";
            default:
              return "Not Yet Checked In !!!";
          }
        } catch (error) {
          return error.toString();
        }
      },
    );
  }

  Future<Either<Failure, User>> fetchUser() async {
    var userData;
    try {
      userData = await Util.request(RequestType.POST, _getUrlUser(UserType.Get), {
        'idToken': _idToken,
      });
    } catch (failure) {
      return Left(failure);
    }

    if (userData['error'] != null) return Left(Failure(userData['error']));
    return Right(make<User>(userData["users"][0]));
  }

  Future<Either<Failure, User>> updateUser(String displayName, String photoUrl) async {
    return await Util.requestEither<User>(RequestType.POST, _getUrlUser(UserType.Update), {
      'idToken': _idToken,
      'displayName': displayName,
      'photoUrl': photoUrl,
    });
  }
}
