import 'package:ata/core/services/auth_service.dart';
import 'package:ata/ui/screens/home_screen.dart';
import 'package:ata/ui/screens/login_screen.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;

String secretKey = 'aA123Bb321@8*iPg';
String authDomain = 'botest.inus.pw';

class QrcodeScannerDialog extends StatefulWidget {
  @override
  QrcodeScannerDialogState createState() => QrcodeScannerDialogState();
}

class QrcodeScannerDialogState extends State<QrcodeScannerDialog> {
  String scanResult = '';
  AuthService _authService;
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(secretKey), mode: encrypt.AESMode.cbc));

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  Future<void> _signOutToLoginScreen() async {
    await _authService.signOut();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  Future scanQRCode() async {
    String cameraScanResult = await scanner.scan();
    if (cameraScanResult != '') scanResult = decrypt(cameraScanResult);
    if (isValidQrCode(scanResult)) {
      String tokenError = await _authService.refeshToken();
      if (tokenError != null) await _signOutToLoginScreen();
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
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
                  onPressed: () async {
                    await _signOutToLoginScreen();
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
