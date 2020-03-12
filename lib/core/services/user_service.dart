import 'package:ata/core/models/auth.dart';
import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/user.dart';
import 'package:ata/core/services/auth_service.dart';
import 'package:ata/core/services/ip_info_service.dart';
import 'package:ata/core/services/location_service.dart';
import 'package:ata/factories.dart';
import 'package:ata/util.dart';
import 'package:dartz/dartz.dart';

enum AttendanceStatus { CheckedIn, CheckedOut, NotYetCheckedIn, NotYetCheckedOut }

class UserService {
  String _urlReports = "https://atapp-7720c.firebaseio.com/reports";

  final AuthService _authService;
  final LocationService _locationService;
  final IpInfoService _ipInfoService;
  UserService(AuthService authService, LocationService locationService, IpInfoService ipInfoService)
      : _authService = authService,
        _locationService = locationService,
        _ipInfoService = ipInfoService;

  Either<Failure, Auth> get _auth {
    return _authService.auth;
  }

  String get _localId {
    return _auth.fold((failure) => throw (failure.toString()), (auth) => auth.localId);
  }

  String get _idToken {
    return _auth.fold((failure) => throw (failure.toString()), (auth) => auth.idToken);
  }

  String get currentDateString {
    return _ipInfoService.getServerDate();
  }

  String get currentDateTimeString {
    return _ipInfoService.getServerDateTime();
  }

  String get urlRecordAttendance {
    print(currentDateString);
    return "$_urlReports/$_localId/$currentDateString.json?auth=$_idToken";
  }

  String get _apiKey {
    return Auth.apiKey;
  }

  String get _urlGetUser {
    return "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey";
  }

  String get _urlUpdateUser {
    return "https://identitytoolkit.googleapis.com/v1/accounts:update?key=$_apiKey";
  }

  Either<Failure, AttendanceStatus> _attendanceStatus;

  //* all async request here
  Future<void> refreshService() async {
    await _ipInfoService.refreshService(); //* get ipInfoService ready first in order to getServerDate()
    _attendanceStatus = await fetchAttendanceStatus();
  }

  AttendanceStatus getAttendanceStatus() {
    return _attendanceStatus.fold(
      (failure) => null,
      (attendanceStatus) => attendanceStatus,
    );
  }

  Future<Either<Failure, AttendanceStatus>> fetchAttendanceStatus() async {
    AttendanceStatus status;
    var responseData;
    try {
      responseData = await Util.request(RequestType.GET, urlRecordAttendance);
    } catch (failure) {
      return Left(Failure(failure.toString()));
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

  Future<String> checkLocationAndIp() async {
    await Future.wait([
      _locationService.refreshService(),
      _ipInfoService.refreshService(),
    ]);

    var isValidLocation = await _locationService.checkLocationForAttendance();
    var isValidIp = _ipInfoService.checkIpForAttendance();

    if (!isValidLocation) return 'Not within Office Location!';
    if (!isValidIp) return 'Not under Offfice Internet!';
    return null;
  }

  Future<String> checkIn() async {
    String checkMsg = await checkLocationAndIp();
    if (checkMsg != null) return checkMsg;

    return (await fetchAttendanceStatus()).fold(
      (failure) => failure.toString(),
      (attendanceStatus) async {
        try {
          var responseData;
          switch (attendanceStatus) {
            case AttendanceStatus.NotYetCheckedIn:
              responseData = await Util.request(RequestType.PUT, urlRecordAttendance, {
                'in': currentDateTimeString,
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
    String checkMsg = await checkLocationAndIp();
    if (checkMsg != null) return checkMsg;

    return (await fetchAttendanceStatus()).fold(
      (failure) => failure.toString(),
      (attendanceStatus) async {
        try {
          var responseData;
          switch (attendanceStatus) {
            case AttendanceStatus.NotYetCheckedOut:
              responseData = await Util.request(RequestType.PATCH, urlRecordAttendance, {
                'out': currentDateTimeString,
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

  Future<Either<Failure, User>> fetchUserInfo() async {
    try {
      var userData = await Util.request(RequestType.POST, _urlGetUser, {
        'idToken': _idToken,
      });
      if (userData['error'] != null) return Left(Failure(userData['error']));
      return Right(make<User>(userData["users"][0]));
    } catch (failure) {
      return Left(Failure(failure.toString()));
    }
  }

  Future<Either<Failure, User>> updateUserInfo(String displayName, String photoUrl) async {
    return await Util.requestEither<User>(RequestType.POST, _urlUpdateUser, {
      'idToken': _idToken,
      'displayName': displayName,
      'photoUrl': photoUrl,
    });
  }
}
