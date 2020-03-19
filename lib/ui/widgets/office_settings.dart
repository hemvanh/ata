import 'package:ata/core/notifiers/office_settings_notifier.dart';
import 'package:ata/ui/widgets/ata_button.dart';
import 'package:ata/ui/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'ata_map.dart';

class OfficeSettings extends StatelessWidget {
  final ipAddressController = TextEditingController();
  final lngController = TextEditingController();
  final latController = TextEditingController();
  final authRangeController = TextEditingController();
  final dateIpServiceUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseWidget<OfficeSettingsNotifier>(
      notifier: OfficeSettingsNotifier(Provider.of(context)),
      onNotifierReady: (notifier) => notifier.getOfficeSettings(),
      builder: (context, notifier, child) {
        ipAddressController.text = notifier.busy ? 'Loading ...' : notifier.ipAddress;
        latController.text = notifier.busy ? 'Loading ...' : notifier.officeLat;
        lngController.text = notifier.busy ? 'Loading ...' : notifier.officeLng;
        authRangeController.text = notifier.busy ? 'Loading ...' : notifier.authRange;
        dateIpServiceUrlController.text = notifier.busy ? 'Loading ...' : notifier.dateIpServiceUrl;
        return Column(
          children: <Widget>[
            Text(
              'Admin Settings',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontSize: 30,
                color: Colors.green[800],
                shadows: [Shadow(color: Colors.grey, offset: Offset(1.0, 1.0), blurRadius: 5.0)],
              ),
            ),
            Divider(),
            Text(
              '(Tap and Hold to select Office Location)',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 300.0,
              child: Card(
                elevation: 10.0,
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    color: Colors.white,
                    child: notifier.busy
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : AtaMap(
                            markedLat: double.tryParse(notifier.officeLat),
                            markedLng: double.tryParse(notifier.officeLng),
                            isMoveableMarker: true,
                            authRange: double.tryParse(notifier.authRange),
                            onLongPress: (LatLng point) => notifier.setOfficeLocation(
                              point.latitude.toString(),
                              point.longitude.toString(),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Office Location\'s Lattitude'),
              keyboardType: TextInputType.number,
              controller: latController,
              style: TextStyle(color: notifier.busy ? Colors.grey : Colors.black),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Office Location\'s Longitude'),
              keyboardType: TextInputType.number,
              controller: lngController,
              style: TextStyle(color: notifier.busy ? Colors.grey : Colors.black),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Authentication Range (in meters)'),
              keyboardType: TextInputType.number,
              controller: authRangeController,
              style: TextStyle(color: notifier.busy ? Colors.grey : Colors.black),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Office IP Address'),
              keyboardType: TextInputType.number,
              controller: ipAddressController,
              style: TextStyle(color: notifier.busy ? Colors.grey : Colors.black),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Date IP and Service Url'),
              keyboardType: TextInputType.url,
              controller: dateIpServiceUrlController,
              style: TextStyle(color: notifier.busy ? Colors.grey : Colors.black),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AtaButton(
                  label: 'Refresh',
                  onPressed: notifier.busy ? null : () => notifier.getOfficeSettings(),
                ),
                SizedBox(width: 25.0),
                AtaButton(
                  label: 'Update',
                  icon: Icon(Icons.save),
                  onPressed: notifier.busy
                      ? null
                      : () => notifier.saveOfficeSettings(
                            ipAddressController.text,
                            latController.text,
                            lngController.text,
                            authRangeController.text,
                            dateIpServiceUrlController.text,
                          ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
