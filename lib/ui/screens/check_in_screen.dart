import 'package:ata/ui/widgets/ata_map_office.dart';
import 'package:ata/ui/widgets/ata_screen.dart';
import 'package:ata/ui/widgets/record_attendance.dart';
import 'package:ata/ui/widgets/clock.dart';
import 'package:flutter/material.dart';
import 'package:ata/ui/widgets/device_ip.dart';

class CheckInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AtaScreen(
      body: Column(
        children: <Widget>[
          AtaMapOffice(),
          DeviceIp(),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Clock(),
                RecordAttendance(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
