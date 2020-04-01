import 'package:ata/core/models/attendance_record.dart';
import 'package:ata/core/models/auth.dart';
import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/ip_info.dart';
import 'package:ata/core/models/office.dart';
import 'package:ata/core/models/user.dart';
import 'package:ata/core/services/auth_service.dart';
import 'package:ata/core/services/ip_info_service.dart';
import 'package:ata/core/services/location_service.dart';
import 'package:ata/core/services/office_service.dart';
import 'package:ata/factories.dart';
import 'package:ata/util.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

enum AttendanceStatus {
  CheckedIn,
  CheckedOut,
  NotYetCheckedIn,
  NotYetCheckedOut
}

class UserService {
  String _urlReports = dbUrl + "/reports";

  final AuthService _authService;
  final LocationService _locationService;
  final IpInfoService _ipInfoService;
  final OfficeService _officeService;
  UserService(AuthService authService, LocationService locationService,
      IpInfoService ipInfoService, OfficeService officeService)
      : _authService = authService,
        _locationService = locationService,
        _ipInfoService = ipInfoService,
        _officeService = officeService;

  Either<Failure, Auth> get _auth {
    return _authService.auth;
  }

  Either<Failure, Office> get _officeSettings {
    return _officeService.officeSettings;
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

  Future<String> get currentDateTimeString async {
    return (await Util.requestEither<IpInfo>(
      RequestType.GET,
      _ipInfoService.getDateIpServiceUrl,
    )).fold(
      (failure) => throw (failure.toString()),
      (ipInfo) => ipInfo.serverDateTime,
    );
  }

  String get urlRecordAttendance {
    return "$_urlReports/$_localId/$currentDateString.json?auth=$_idToken";
  }

  String get _urlUserAttendance {
    return "$_urlReports/$_localId.json?auth=$_idToken";
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
      if (responseData['checkInTime'] != null) status = AttendanceStatus.CheckedIn;
      if (responseData['checkOutTime'] != null)
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

  Future<String> checkIn({String lateReason = ''}) async {
    String checkMsg = await checkLocationAndIp();
    if (checkMsg != null) return checkMsg;
    if (isEarlyCheckIn()) return 'Too early! Please check in within Working hours period.';
    String serverDateTime = await currentDateTimeString;

    return (await fetchAttendanceStatus()).fold(
      (failure) => failure.toString(),
      (attendanceStatus) async {
        try {
          var responseData;
          switch (attendanceStatus) {
            case AttendanceStatus.NotYetCheckedIn:
              responseData = await Util.request(RequestType.PUT, urlRecordAttendance, {
                'checkInTime': DateFormat('yyyy-MM-dd HH:mm:ss').parse(serverDateTime).toIso8601String(),
                'lateReason': lateReason
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

  Future<String> checkOut({String earlyReason = ''}) async {
    String checkMsg = await checkLocationAndIp();
    if (checkMsg != null) return checkMsg;
    String serverDateTime = await currentDateTimeString;

    return (await fetchAttendanceStatus()).fold(
      (failure) => failure.toString(),
      (attendanceStatus) async {
        try {
          var responseData;
          switch (attendanceStatus) {
            case AttendanceStatus.NotYetCheckedOut:
              responseData = await Util.request(RequestType.PATCH, urlRecordAttendance, {
                'checkOutTime': DateFormat("yyyy-MM-dd HH:mm:ss").parse(serverDateTime).toIso8601String(),
                'earlyReason': earlyReason
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

  Future<List<AttendanceRecord>> fetchAttendanceRecords() async {
    try {
      var responseData = await Util.request(RequestType.GET, _urlUserAttendance);
      List<AttendanceRecord> attendanceRecordList = new List<AttendanceRecord>();
      if (responseData != null) {
        final jsonParsed = responseData as Map<String, dynamic>;
        jsonParsed.forEach((key, value) {
          if (key != "null") {
            AttendanceRecord ataRecord = AttendanceRecord.fromJson(value);
            attendanceRecordList.add(ataRecord);
          }
        });
      }
      return attendanceRecordList;
    } catch (error) {
      throw error;
    }
  }

  Office _getOfficeInfo() {
    if (_officeSettings == null) _officeService.fetchOfficeSettings();
    return _officeSettings.fold((failure) => null, (office) => office);
  }

  DateTime _genTodayTimeByHhMm(DateTime time) {
    DateTime currentTime = DateTime.now();
    return DateTime(currentTime.year, currentTime.month, currentTime.day, time.hour, time.minute);
  }

  bool isLateCheckIn() {
    Office office = _getOfficeInfo();
    DateTime startTimeToday = _genTodayTimeByHhMm(office.startTime);
    return ((DateTime.now().millisecondsSinceEpoch - startTimeToday.millisecondsSinceEpoch)/60000).round() > office.acceptableLateTime;
  }

  bool isEarlyCheckIn() {
    Office office = _getOfficeInfo();
    DateTime startTimeToday = _genTodayTimeByHhMm(office.startTime);
    return DateTime.now().millisecondsSinceEpoch < startTimeToday.millisecondsSinceEpoch;
  }

  bool isEarlyCheckOut() {
    Office office = _getOfficeInfo();
    DateTime endTimeToday = _genTodayTimeByHhMm(office.endTime);
    return DateTime.now().millisecondsSinceEpoch < endTimeToday.millisecondsSinceEpoch;
  }
}
