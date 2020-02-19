import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ata/util.dart';
import 'package:ata/screens/loading-screen.dart';

class CheckInScreen extends StatelessWidget {
  Future<Map<String, dynamic>> getDeviceIP() async {
    try {
      var responseText = await Util.fetch(FetchType.GET, 'http://ip-api.com/json');
      final responseData = json.decode(responseText) as Map<String, dynamic>;
      return responseData;
    } catch (error) {
      return {'error': error};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDeviceIP(),
      builder: (ctx, AsyncSnapshot<Map<String, dynamic>> snapshot) => snapshot.connectionState == ConnectionState.waiting
          ? LoadingScreen()
          : Center(
              child: snapshot.data['error'] != null
                  ? Text(snapshot.data['error'].toString())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(snapshot.data['city']),
                        Text(snapshot.data['org']),
                        Text(snapshot.data['query']),
                      ],
                    ),
            ),
    );
  }
}
