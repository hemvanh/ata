import 'package:ata/core/services/office_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ata/core/services/auth_service.dart';
import 'package:ata/core/services/ip_info_service.dart';

List<SingleChildWidget> providers = [
  ...services,
  ...uIservices,
  ...proxyServices,
  ...proxyUiServices,
];

List<SingleChildWidget> services = [
  Provider.value(value: IpInfoService()),
];
List<SingleChildWidget> uIservices = [
  Provider.value(value: AuthService()),
];

List<SingleChildWidget> proxyServices = [
  ProxyProvider<AuthService, OfficeService>(
    update: (_, authService, __) =>
        OfficeService()..setAuthToken(authService.idToken),
  ),
];

List<SingleChildWidget> proxyUiServices = [];
