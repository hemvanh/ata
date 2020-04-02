import 'dart:async';

import 'package:analog_clock/analog_clock.dart';
import 'package:analog_clock/analog_clock_painter.dart';
import 'package:ata/core/models/ip_info.dart';
import 'package:ata/core/notifiers/ip_info_notifier.dart';
import 'package:ata/core/services/ip_info_service.dart';
import 'package:ata/ui/widgets/base_widget.dart';
import 'package:ata/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  DateTime serverDateTime;
  Timer timer;
  IpInfoService _infoService;

  @override
  void initState() {
    _infoService = Provider.of<IpInfoService>(context, listen: false);
    serverDateTime = DateTime.parse("2020-04-01 12:07:00");
    timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  Future<void> _getServerDateTime() async {
    await Util.requestEither<IpInfo>(
      RequestType.GET,
      _infoService.getDateIpServiceUrl,
    );
  }

  void _updateTime() {
    String serverDate = DateFormat("yyyy-MM-dd").format(serverDateTime);
    int hour = serverDateTime.hour;
    int minute = serverDateTime.minute;
    int second = serverDateTime.second;
    if (second == 59) {
      second = 0;
      minute++;
      if (minute == 60) {
        minute = 0;
        hour++;
      }
      if (hour == 24) hour = 0;
    } else {
      second++;
    }
    setState(() {
      serverDateTime = DateTime.parse(
          "$serverDate ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}:${second.toString().padLeft(2, "0")}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 150.0,
          height: 150.0,
          child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 20.0,
                        spreadRadius: 0.1,
                        offset: Offset(
                          5.0,
                          10.0,
                        ),
                      )
                    ],
                  ),
                  width: 100.0,
                  height: 100.0,
                  child: CustomPaint(
                    painter: AnalogClockPainter(
                      datetime: serverDateTime,
                      showAllNumbers: true,
                      tickColor: Colors.green[600],
                      secondHandColor: Colors.green[600],
                      numberColor: Colors.green[600],
                      showNumbers: false,
                      showDigitalClock: false,
                      showSecondHand: true,
                    ),
                  ))),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            DateFormat('dd - MMM - yyyy').format(serverDateTime),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: Colors.green[600],
              shadows: [
                Shadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 1.0),
                    blurRadius: 5.0)
              ],
            ),
          ),
        )
      ],
    );
  }
}
