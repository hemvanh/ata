import 'package:ata/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:ata/widgets/ata_text_field.dart';
import 'package:ata/widgets/ata_button.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  final ipController = TextEditingController();
  final longsController = TextEditingController();
  final latsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8.0,
      child: Container(
        height: 320,
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: FutureBuilder(
            future: Provider.of<Auth>(context, listen: false).fetchOfficeSettings(),
            builder: (ctx, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                ipController.text = snapshot.data['ip'];
                longsController.text = snapshot.data['location']['longs'];
                latsController.text = snapshot.data['location']['lats'];
              }
              return snapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      children: <Widget>[
                        AtaTextField(
                          label: 'Office IP Address',
                          type: TextInputType.number,
                          controller: ipController,
                        ),
                        AtaTextField(
                          label: 'Office Location\'s Longitude',
                          type: TextInputType.number,
                          controller: longsController,
                        ),
                        AtaTextField(
                          label: 'Office Location\'s Lattitude',
                          type: TextInputType.number,
                          controller: latsController,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        AtaButton(
                          label: 'Update',
                          handler: () async {
                            await Provider.of<Auth>(context, listen: false).updateOfficeSettings(
                              ipController.text,
                              longsController.text,
                              latsController.text,
                            );
                          },
                        )
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
