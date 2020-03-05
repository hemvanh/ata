import 'package:ata/core/models/auth.dart';
import 'package:ata/core/models/ip_info.dart';
import 'package:ata/core/models/office.dart';
import 'package:ata/core/models/user.dart';

/// Add factory functions for every Type and every constructor you want to make available to `make`
final factories = <Type, Function>{
  IpInfo: (Map<String, dynamic> x) => IpInfo.fromJson(x),
  Auth: (Map<String, dynamic> x) => Auth.fromJson(x),
  Office: (Map<String, dynamic> x) => Office.fromJson(x),
  User: (Map<String, dynamic> x) => User.fromJson(x),
};

T make<T>(Map<String, dynamic> x) {
  return factories[T](x);
}
