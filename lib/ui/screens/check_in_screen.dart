import 'package:ata/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:ata/ui/widgets/device_ip.dart';
import 'package:provider/provider.dart';

class CheckInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var authService = Provider.of<LocationService>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(onPressed:()async{
              await authService.checkDistanceLocation();
            } ), //DeviceIp(),
    );
  }
}
