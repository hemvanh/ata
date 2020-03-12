import 'package:flutter/foundation.dart';

class IpInfo {
  final String ipAddress;
  final double ipLat;
  final double ipLng;
  final String org;
  final String city;
  final String country;
  final String timezone;
  final String serverDate;
  final String serverDateTime;

  IpInfo({
    @required this.ipAddress,
    @required this.ipLat,
    @required this.ipLng,
    @required this.org,
    @required this.city,
    @required this.country,
    @required this.timezone,
    @required this.serverDate,
    @required this.serverDateTime,
  });

  factory IpInfo.fromJson(Map<String, dynamic> parsedJson) {
    return IpInfo(
      city: parsedJson['city'],
      country: parsedJson['country'],
      ipAddress: parsedJson['clientIp'],
      ipLat: parsedJson['lat'],
      ipLng: parsedJson['lng'],
      org: parsedJson['org'],
      timezone: parsedJson['timezone'],
      serverDate: parsedJson['serverDate'],
      serverDateTime: parsedJson['serverDateTime'],
    );
  }
}
