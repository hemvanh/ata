import 'package:ata/core/services/office_service.dart';
import 'package:dartz/dartz.dart';
import 'package:ata/util.dart';
import 'package:ata/core/models/failure.dart';
import 'package:ata/core/models/ip_info.dart';

class IpInfoService {
  String deviceIp;
  String officeIP;
  OfficeService _officeService;
  IpInfoService _ipInfoService;
  //* Model reference
  Either<Failure, IpInfo> _ipInfo;
  Either<Failure, IpInfo> get ipInfo => _ipInfo;
  void _setIpInfo(Either<Failure, IpInfo> ipInfo) {
    _ipInfo = ipInfo;
  }

  Future<void> fetchDeviceIpInfo() async {
    await Util.requestEither<IpInfo>(
      RequestType.GET,
      'http://ip-api.com/json',
    ).then((value) => _setIpInfo(value));
  }

  Future<void> getDeviceIpAddress() async {
    await _ipInfoService.fetchDeviceIpInfo();
   _ipInfoService.ipInfo.fold(
      (failure) => deviceIp = failure.toString(),
      (ipInfo) => deviceIp = ipInfo.ipAddress,
    );
  }

  Future<void> getOfficeIpAddress() async {
    await _officeService.fetchOfficeSettings();
   _officeService.officeSettings.fold(
      (failure) => officeIP = failure.toString(),
      (ipInfo) => officeIP = ipInfo.ipAddress,
    );
  }
  
  Future<bool> checkIP() async {
    return deviceIp == officeIP ? deviceIp == officeIP : false;
  }
}
