import 'package:ata/core/models/ip_info.dart';
import 'package:ata/core/notifiers/base_notifier.dart';
import 'package:ata/core/services/ip_info_service.dart';
import 'package:ata/util.dart';

class IpInfoNotifier extends BaseNotifier {
  final IpInfoService _ipInfoService;

  IpInfoNotifier(IpInfoService ipInfoService) : _ipInfoService = ipInfoService;
  String serverTime=DateTime.now().toString();
  Future<void>  refreshServerTime() async {
    setBusy(true);
    (await Util.requestEither<IpInfo>(
      RequestType.GET,
      _ipInfoService.getDateIpServiceUrl,
    )).fold(
      (failure) => serverTime,
      (ipInfo) {
        serverTime = ipInfo.serverDateTime;
      },
    );
    setBusy(false);
  }
}
