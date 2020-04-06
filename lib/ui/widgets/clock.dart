import 'dart:async';

import 'package:analog_clock/analog_clock_painter.dart';
import 'package:ata/core/services/ip_info_service.dart';
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
  IpInfoService _ipInfoService;

  @override
  void initState() {
    super.initState();

    serverDateTime = DateTime.now();
    _ipInfoService = Provider.of<IpInfoService>(context, listen: false);
    _ipInfoService.refreshService().then((_) {
      _ipInfoService.ipInfo.fold((failure) {
        serverDateTime = DateTime.now();
      }, (ipInfo) {
        serverDateTime = DateTime.parse(ipInfo.serverDateTime);
      });
      setState(() {});
    });
    timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void _updateTime() {
    setState(() {
      serverDateTime = serverDateTime.add(Duration(seconds: 1));
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
              shadows: [Shadow(color: Colors.grey, offset: Offset(1.0, 1.0), blurRadius: 5.0)],
            ),
          ),
        )
      ],
    );
  }
}
