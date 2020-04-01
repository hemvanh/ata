import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

String secretKey = 'aA123Bb321@8*iPg';
String authDomain = 'botest.inus.pw';

class QrCodeScannerDialog extends StatefulWidget {
  @override
  QrCodeScannerDialogState createState() => QrCodeScannerDialogState();
}

class QrCodeScannerDialogState extends State<QrCodeScannerDialog> {
  String scanResult = '';
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(secretKey), mode: encrypt.AESMode.cbc));

  @override
  void initState() {
    super.initState();
  }

  Future scanQRCode() async {
    String cameraScanResult = await scanner.scan();
    if (cameraScanResult != '') scanResult = decrypt(cameraScanResult);
    if (isValidQrCode(scanResult)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {});
    }
  }

  String decrypt(String qrCode) {
    String decryptedCode;
    if (qrCode != '')
      try {
        decryptedCode = encrypter.decrypt64(qrCode, iv: encrypt.IV.fromUtf8(secretKey));
        decryptedCode = isValidQrCode(decryptedCode) ? decryptedCode : 'Error: Invalid QR code (1)';
      } on ArgumentError catch (_) {
        decryptedCode = 'Error: Invalid QR code (2)';
      } on Exception catch (_) {
        decryptedCode = 'Error: Invalid QR code (2)';
      }
    return decryptedCode;
  }

  bool isValidQrCode(String qrCode) {
    return qrCode.contains(authDomain);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quickly Re-Login by Scanning the website QR-Code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton.icon(
                  onPressed: () async {
                    await scanQRCode();
                  },
                  icon: Icon(Icons.crop_free),
                  label: Text('Scan QR'),
                  color: Colors.green,
                  textColor: Colors.white,
                ),
                RaisedButton(
                  child: Text("Cancel"),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              scanResult,
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
