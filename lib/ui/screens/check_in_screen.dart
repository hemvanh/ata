import 'package:flutter/material.dart';
import 'package:ata/ui/widgets/device_ip.dart';

class CheckInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DeviceIp(),
    );
  }
}
